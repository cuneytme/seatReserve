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
    @Published var scale: CGFloat = 1.0
    @Published var offset: CGSize = .zero
    @Published var lastOffset: CGSize = .zero
    @Published var zoomCenter: CGPoint = .zero
    
    @Published var maxRow: Int = 0
    @Published var maxColumn: Int = 0
    
    let minScale: CGFloat = 0.5
    let maxScale: CGFloat = 3.0
    
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
        
        let gridWidth = (seatSize * CGFloat(maxColumn)) + (spacing * CGFloat(maxColumn - 1)) + (padding * 2)
        let gridHeight = (seatSize * CGFloat(maxRow)) + (spacing * CGFloat(maxRow - 1)) + (padding * 2)
        
        let widthScale = screenWidth / gridWidth
        let heightScale = screenHeight / gridHeight
        
        scale = min(widthScale, heightScale) * 0.6
        
        offset = CGSize(width: 0, height: 0)
        lastOffset = offset
    }
    
    func getSeatAt(row: Int, column: Int) -> Seat? {
        return seats.first { $0.rowPosition == row && $0.columnPosition == column }
    }
    
    func selectSeat(_ seat: Seat?) {
        withAnimation(.spring()) {
            if selectedSeat?.id == seat?.id {
                selectedSeat = nil
            } else {
                selectedSeat = seat
            }
        }
        if let seat = seat {
            print("Seat Info:")
            print("Seat Number: \(seat.seatNumber)")
            print("QR Code: \(seat.qrCode)")
            print("Reservation Situation: \(seat.reservableType)")
        }
    }
    
    func validateScale(_ newScale: CGFloat) -> CGFloat {
        min(max(newScale, minScale), maxScale)
    }
    
    func updateOffset(_ translation: CGSize) {
        offset = CGSize(
            width: lastOffset.width + translation.width,
            height: lastOffset.height + translation.height
        )
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
} 
