//
//  Seat.swift
//  seatReserve
//
//  Created by Cüneyt Elbastı on 27.02.2025.
//


struct SeatResponse: Codable {
    let message: String
    let statusCode: Int
    let result: [Seat]
}

struct Seat: Codable, Identifiable {
    let qrCode: String
    let rowPosition: Int
    let id: String
    let seatNumber: String
    let sectionId: String
    let reservableType: String
    let alignment: String
    let type: String
    let columnPosition: Int
    let isActive: Bool
} 
