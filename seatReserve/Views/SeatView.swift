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
    let size: CGFloat
    
    var body: some View {
        HStack(spacing: 0) {
            RoundedRectangle(cornerRadius: size * 0.2)
                .fill(seatColor)
                .frame(width: size * 1.5, height: size * 0.8)
                .overlay(
                    Text(seat.seatNumber)
                        .font(.system(size: size * 0.3))
                        .foregroundColor(.white)
                )
                .scaleEffect(isSelected ? 2.0 : 1.0)
                .animation(
                    .spring(response: 0.5, dampingFraction: 0.7, blendDuration: 0.3),
                    value: isSelected
                )
            
            Spacer()
        }
        .frame(width: size * 1.5)
        .zIndex(isSelected ? 100 : 1)
    }
    
    private var seatColor: Color {
        if seat.reservableType == "NOT_RESERVABLE" {
            return .gray
        }
        return isSelected ? .blue : .green
    }
} 
