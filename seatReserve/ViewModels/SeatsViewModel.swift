//
//  SeatsViewModel.swift
//  seatReserve
//
//  Created by Cüneyt Elbastı on 27.02.2025.
//



import Foundation
import SwiftUI

class SeatsViewModel: ObservableObject {
    @Published var seats: [Seat] = []
    @Published var selectedSeat: Seat?
    @Published var showPopup: Bool = false
    @Published var popoverAnchor: PopoverAttachmentAnchor = .rect(.bounds)
    @Published var scale: CGFloat = 1.0
    @Published var offset: CGSize = .zero
    @Published var lastOffset: CGSize = .zero
    @Published var zoomCenter: CGPoint = .zero
    
    @Published var maxRow: Int = 0
    @Published var maxColumn: Int = 0
    
    let minScale: CGFloat = 0.5
    let maxScale: CGFloat = 3.0
    
    @Published var seatSize: CGFloat = 40.0
    @Published var seatSpacing: CGFloat = 10.0
    
    private var dragLimits: CGRect = .zero
    private var screenSize: CGSize = .zero
    
    init() {
        loadSeats()
    }
    
    private func loadSeats() {
        if let path = Bundle.main.path(forResource: "Seats", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path))
                let response = try JSONDecoder().decode(SeatResponse.self, from: data)
                self.seats = response.result
                
                calculateGrid()
                calculateScale()
            } catch {
                print("No data: \(error)")
            }
        }
    }
    
    private func calculateGrid() {
        maxRow = seats.map { $0.rowPosition }.max() ?? 0
        maxColumn = seats.map { $0.columnPosition }.max() ?? 0
    }
    
    
    
    func calculateScale() {
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        
        let seatSize: CGFloat = 40
        let spacing: CGFloat = 10
        let padding: CGFloat = 16
        
        let gridWidth = (seatSize * 1.5 * CGFloat(maxColumn)) + (spacing * CGFloat(maxColumn - 1))
        let gridHeight = (seatSize * 0.8 * CGFloat(maxRow)) + (spacing * CGFloat(maxRow - 1))
        
        let widthScale = screenWidth / gridWidth
        let heightScale = screenHeight / gridHeight
        
        scale = min(widthScale, heightScale) * 0.95
        
        centerSeatsOnScreen(screenWidth: screenWidth, screenHeight: screenHeight)
    }
    
    private func centerSeatsOnScreen(screenWidth: CGFloat, screenHeight: CGFloat) {
        let totalWidth = (seatSize * 1.5 * CGFloat(maxColumn)) + (seatSpacing * CGFloat(maxColumn - 1))
        let totalHeight = (seatSize * 0.8 * CGFloat(maxRow)) + (seatSpacing * CGFloat(maxRow - 1))
        
        let offsetX = (screenWidth - totalWidth * scale) / 2
        
        let verticalAdjustment = screenHeight * 0.1
        let offsetY = ((screenHeight - totalHeight * scale) / 2) - verticalAdjustment
        
        offset = CGSize(width: offsetX, height: offsetY)
        lastOffset = offset
    }
    
    func getSeatAt(row: Int, column: Int) -> Seat? {
        return seats.first { $0.rowPosition == row && $0.columnPosition == column }
    }
    
    func clearSelection() {
        withAnimation(.spring(response: 0.25, dampingFraction: 0.7, blendDuration: 0.1)) {
            self.showPopup = false
        }
    }
    
    func selectSeat(_ seat: Seat?) {
        withAnimation(.spring(response: 0.25, dampingFraction: 0.7, blendDuration: 0.1)) {
            if selectedSeat?.id == seat?.id {
                clearSelection()
            } else {
                selectedSeat = seat
                if seat != nil {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        withAnimation(.spring(response: 0.25)) {
                            self.showPopup = true
                        }
                    }
                }
            }
        }
        if let seat = seat {
            print("Seat Info:")
            print("Seat Number: \(seat.seatNumber)")
            print("QR Code: \(seat.qrCode)")
            print("Reservation Situation: \(seat.reservableType)")
        }
    }
    
    func calculateDragLimits() {
        let totalWidth = (seatSize * 1.5 * CGFloat(maxColumn)) + (seatSpacing * CGFloat(maxColumn - 1))
        let totalHeight = (seatSize * 0.8 * CGFloat(maxRow)) + (seatSpacing * CGFloat(maxRow - 1))
        
        if totalWidth * scale <= screenSize.width && totalHeight * scale <= screenSize.height {
    
            let verticalAdjustment = screenSize.height * 0.1
            let centerX = (screenSize.width - totalWidth * scale) / 2
            let centerY = ((screenSize.height - totalHeight * scale) / 2) - verticalAdjustment
            
            dragLimits = CGRect(x: centerX, y: centerY, width: 0, height: 0)
        } else {
            let horizontalLimit = max(0, (totalWidth * scale - screenSize.width) / 2 + screenSize.width * 0.1)
            
            let verticalTopLimit = max(0, (totalHeight * scale - screenSize.height) / 2 + screenSize.height * 0.05)
            let verticalBottomLimit = max(0, (totalHeight * scale - screenSize.height) / 2 + screenSize.height * 0.15)
            
            dragLimits = CGRect(x: -horizontalLimit, 
                              y: -verticalTopLimit, 
                              width: horizontalLimit * 2, 
                              height: verticalTopLimit + verticalBottomLimit)
        }
    }
    
    func updateOffset(_ translation: CGSize) {
        var newOffset = CGSize(
            width: lastOffset.width + translation.width,
            height: lastOffset.height + translation.height
        )
        newOffset.width = min(max(newOffset.width, dragLimits.minX), dragLimits.maxX)
        newOffset.height = min(max(newOffset.height, dragLimits.minY), dragLimits.maxY)
        
        offset = newOffset
    }
    
    func endDragging() {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.7, blendDuration: 0.5)) {
            lastOffset = offset
        }
    }
    
    func updateZoomCenter(_ point: CGPoint, in geometry: GeometryProxy) {
        let normalPoint = CGPoint(
            x: (point.x - offset.width - geometry.size.width/2) / scale,
            y: (point.y - offset.height - geometry.size.height/2) / scale
        )
        zoomCenter = normalPoint
    }
    
    func calculateNewOffset(for scale: CGFloat, in geometry: GeometryProxy) -> CGSize {
        let newOffset = CGSize(
            width: zoomCenter.x * (scale - self.scale) + offset.width,
            height: zoomCenter.y * (scale - self.scale) + offset.height
        )
        return newOffset
    }
    
    func calculateOptimalSeatSize(for screenSize: CGSize) {
        let horizontalPadding: CGFloat = 16
        let verticalPadding: CGFloat = 16
        
        self.screenSize = screenSize
        
        let availableWidth = screenSize.width - horizontalPadding
        let availableHeight = screenSize.height - verticalPadding + (screenSize.height * 0.1)
        
        let widthWithSpacing = availableWidth / CGFloat(maxColumn)
        let widthBasedSpacing = widthWithSpacing * 0.12
        let widthBasedSeatSize = (widthWithSpacing - widthBasedSpacing) / 1.5
        
        let heightWithSpacing = availableHeight / CGFloat(maxRow)
        let heightBasedSpacing = heightWithSpacing * 0.12
        let heightBasedSeatSize = (heightWithSpacing - heightBasedSpacing) / 0.8
        
        let minSeatSize: CGFloat = 35
        let maxSeatSize: CGFloat = 70
        
        let calculatedSize = min(widthBasedSeatSize, heightBasedSeatSize)
        seatSize = min(max(calculatedSize, minSeatSize), maxSeatSize)
        
        seatSpacing = max(seatSize * 0.1, 5)
        
        centerSeatsOnScreen(screenWidth: screenSize.width, screenHeight: screenSize.height)
        
        calculateDragLimits()
    }
    
    func validateScale(_ newScale: CGFloat) -> CGFloat {
        let validatedScale = min(max(newScale, minScale), maxScale)
        
        if newScale < minScale * 1.05 {
            DispatchQueue.main.async {
                self.resetViewToInitial()
            }
        }
        
        DispatchQueue.main.async {
            self.calculateDragLimits()
        }
        return validatedScale
    }
    
    func resetViewToInitial() {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.7, blendDuration: 0.5)) {
            self.scale = 1.0
            centerSeatsOnScreen(screenWidth: screenSize.width, screenHeight: screenSize.height)
        }
    }
    
}
