//
//  SeatDetailPopupView.swift
//  seatReserve
//
//  Created by Cüneyt Elbastı on 07.03.2025.
//

import SwiftUI

struct SeatDetailPopupView: View {
    let seat: Seat
    let seatSize: CGFloat
    
    var body: some View {
        VStack(alignment: .center, spacing: 12) {
            Text("Seat: \(seat.seatNumber)")
                .font(.system(size: seatSize * 0.3, weight: .semibold))
                .foregroundColor(.white)
            
            Divider()
                .background(Color.white.opacity(0.7))
                .frame(width: seatSize * 1.2)
            
            Text(reservationStatusText(seat.reservableType))
                .font(.system(size: seatSize * 0.3, weight: .semibold))
                .foregroundColor(statusColor(seat.reservableType))
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 14)
        .frame(width: seatSize * 2.5)
        .background(Color.black)
        .environment(\.colorScheme, .dark)
    }
    
    private func reservationStatusText(_ status: String) -> String {
        switch status {
        case "RESERVABLE":
            return "Reservable"
        case "NOT_RESERVABLE":
            return "Not Reservable"
        default:
            return status
        }
    }
    
    private func statusColor(_ status: String) -> Color {
        switch status {
        case "RESERVABLE":
            return .green
        case "NOT_RESERVABLE":
            return .red
        default:
            return .gray
        }
    }
} 
