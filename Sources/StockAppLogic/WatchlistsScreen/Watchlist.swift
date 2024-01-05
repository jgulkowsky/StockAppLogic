//
//  Watchlist.swift
//  StockApp
//
//  Created by Jan Gulkowski on 20/12/2023.
//

import Foundation

struct Watchlist: Equatable {
    var id: UUID
    var name: String
    var symbols: [String]
}
