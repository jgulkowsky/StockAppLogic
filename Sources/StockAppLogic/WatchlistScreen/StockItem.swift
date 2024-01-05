//
//  StockItem.swift
//  StockApp
//
//  Created by Jan Gulkowski on 19/12/2023.
//

import Foundation

struct StockItem {
    let symbol: String
    let quote: Quote?
}

extension StockItem: Comparable {
    static func < (lhs: StockItem, rhs: StockItem) -> Bool {
        return lhs.symbol < rhs.symbol
    }
    
    static func == (lhs: StockItem, rhs: StockItem) -> Bool {
        return lhs.symbol == rhs.symbol
            && lhs.quote == rhs.quote
    }
}
