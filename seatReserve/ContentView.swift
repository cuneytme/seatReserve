//
//  ContentView.swift
//  seatReserve
//
//  Created by Cüneyt Elbastı on 27.02.2025.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = SeatsViewModel()
    @GestureState private var magnificationRate = 1.0
    @GestureState private var dragOffset: CGSize = .zero
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.white
                    .contentShape(Rectangle())
                    .onTapGesture {
                        viewModel.clearSelection()
                    }
                
                Group {
                    VStack(spacing: viewModel.seatSpacing) {
                        ForEach(1...viewModel.maxRow, id: \.self) { row in
                            HStack(spacing: viewModel.seatSpacing) {
                                ForEach(1...viewModel.maxColumn, id: \.self) { column in
                                    if let seat = viewModel.getSeatAt(row: row, column: column) {
                                        if viewModel.selectedSeat?.id != seat.id {
                                            SeatView(seat: seat, 
                                                   isSelected: false,
                                                   size: viewModel.seatSize)
                                                .onTapGesture {
                                                    viewModel.selectSeat(seat)
                                                }
                                        } else {
                                            Color.clear
                                                .frame(width: viewModel.seatSize * 1.5, 
                                                       height: viewModel.seatSize * 0.8)
                                        }
                                    } else {
                                        Color.clear
                                            .frame(width: viewModel.seatSize * 1.5, 
                                                   height: viewModel.seatSize * 0.8)
                                    }
                                }
                                Spacer()
                            }
                        }
                    }
                    if let selectedSeat = viewModel.selectedSeat {
                        VStack(spacing: viewModel.seatSpacing) {
                            ForEach(1...viewModel.maxRow, id: \.self) { row in
                                HStack(spacing: viewModel.seatSpacing) {
                                    ForEach(1...viewModel.maxColumn, id: \.self) { column in
                                        if viewModel.getSeatAt(row: row, column: column)?.id == selectedSeat.id {
                                            SeatView(seat: selectedSeat, 
                                                   isSelected: true,
                                                   size: viewModel.seatSize)
                                                .onTapGesture {
                                                    viewModel.selectSeat(selectedSeat)
                                                }
                                                .popover(
                                                    isPresented: $viewModel.showPopup,
                                                    attachmentAnchor: .point(.init(x: 0.5, y: -0.6)),
                                                    arrowEdge: .bottom,
                                                    content: {
                                                        SeatDetailPopupView(
                                                            seat: selectedSeat,
                                                            seatSize: viewModel.seatSize
                                                        )
                                                        .presentationCompactAdaptation(.popover)
                                                    }
                                                )
                                                .onChange(of: viewModel.showPopup) { newValue in
                                                    if !newValue {
                                                        viewModel.selectedSeat = nil
                                                    }
                                                }
                                        } else {
                                            Color.clear
                                                .frame(width: viewModel.seatSize * 1.5, 
                                                       height: viewModel.seatSize * 0.8)
                                        }
                                    }
                                    Spacer()
                                }
                            }
                        }
                    }
                }
                .scaleEffect(viewModel.scale * magnificationRate)
                .offset(viewModel.offset)
                .offset(dragOffset)
                .onAppear {
                    viewModel.calculateOptimalSeatSize(for: geometry.size)
                }
                .onChange(of: geometry.size) { newSize in
                    viewModel.calculateOptimalSeatSize(for: newSize)
                }
            }
            
            .gesture(
                SimultaneousGesture(
                    MagnificationGesture()
                        .updating($magnificationRate) { currentState, gestureState, _ in
                            gestureState = currentState
                            viewModel.updateZoomCenter(geometry.frame(in: .local).center, in: geometry)
                        }
                        .onEnded { value in
                            let newScale = viewModel.validateScale(viewModel.scale * value)
                            viewModel.scale = newScale
                            viewModel.offset = viewModel.calculateNewOffset(for: newScale, in: geometry)
                            viewModel.updateOffset(.zero)
                        },
                    DragGesture(minimumDistance: 0)
                        .updating($dragOffset) { value, state, _ in
                            state = value.translation
                        }
                        .onEnded { value in
                            viewModel.updateOffset(value.translation)
                            viewModel.endDragging()
                        }
                )
            )
        }
    }
}

extension CGRect {
    var center: CGPoint {
        CGPoint(x: midX, y: midY)
    }
}

#Preview {
    ContentView()
}
