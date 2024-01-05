//
//  StockItem.swift
//  StockAppLogic
//
//  Created by Jan Gulkowski on 19/12/2023.
//

import Foundation

public struct StockItem {
    public let symbol: String
    public let quote: Quote?
    
    public init(symbol: String, quote: Quote?) {
        self.symbol = symbol
        self.quote = quote
    }
}

extension StockItem: Comparable {
    public static func < (lhs: StockItem, rhs: StockItem) -> Bool {
        return lhs.symbol < rhs.symbol
    }
    
    public static func == (lhs: StockItem, rhs: StockItem) -> Bool {
        return lhs.symbol == rhs.symbol
            && lhs.quote == rhs.quote
    }
}
