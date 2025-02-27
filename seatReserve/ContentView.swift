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
                    .edgesIgnoringSafeArea(.all)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        viewModel.selectSeat(nil)
                    }
                
                GridLayout
                    .scaleEffect(viewModel.scale * magnificationRate)
                    .offset(viewModel.offset)
                    .offset(dragOffset)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .clipped()
            .gesture(
                SimultaneousGesture(
                    MagnificationGesture()
                        .updating($magnificationRate) { currentState, gestureState, _ in
                            gestureState = currentState
                        }
                        .onEnded { value in
                            viewModel.scale = viewModel.validateScale(viewModel.scale * value)
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
    
    private var GridLayout: some View {
        VStack(spacing: 24) {
            ForEach(1...viewModel.maxRow, id: \.self) { row in
                HStack(spacing: 10) {
                    ForEach(1...viewModel.maxColumn, id: \.self) { column in
                        //eger koltuk var ise SeatView'i cagirir yoksa ayni boyutta bos bir view gelir.
                        if let seat = viewModel.getSeatAt(row: row, column: column) {
                            SeatView(seat: seat, isSelected: viewModel.selectedSeat?.id == seat.id)
                                .onTapGesture {
                                    viewModel.selectSeat(seat)
                                }
                        } else {
                            Color.clear
                                .frame(width: 40, height: 40)
                        }
                    }
                }
            }
        }
        .padding(.top, -220)
        .padding(.horizontal, -250)
    }
}

#Preview {
    ContentView()
}
