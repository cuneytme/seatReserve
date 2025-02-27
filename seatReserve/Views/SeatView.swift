//
//  SeatView.swift
//  seatReserve
//
//  Created by Cüneyt Elbastı on 27.02.2025.
//


import SwiftUI

struct SeatView: View {
    let seat: Seat
    let isSelected: Bool
    
    var body: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(seatColor)
            .frame(width: 40, height: 40)
            .overlay(
                Text(seat.seatNumber)
                    .font(.caption)
                    .foregroundColor(.white)
            )
            .scaleEffect(isSelected ? 2.0 : 1.0)
            .animation(.spring(), value: isSelected)
            .zIndex(isSelected ? 10 : -10)
    }
    
    private var seatColor: Color {
        if seat.reservableType == "NOT_RESERVABLE" {
            return .gray
        }
        return isSelected ? .blue : .green
    }
} 
