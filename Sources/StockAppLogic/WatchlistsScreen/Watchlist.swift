//
//  Watchlist.swift
//  StockApp
//
//  Created by Jan Gulkowski on 20/12/2023.
//

import Foundation

public struct Watchlist: Equatable {
    public var id: UUID
    public var name: String
    public var symbols: [String]
}
