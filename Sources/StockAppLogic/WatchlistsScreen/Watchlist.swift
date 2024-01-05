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
    
    public init(id: UUID, name: String, symbols: [String]) {
        self.id = id
        self.name = name
        self.symbols = symbols
    }
}
