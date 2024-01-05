//
//  ChartItem.swift
//  StockApp
//
//  Created by Jan Gulkowski on 19/12/2023.
//

import Foundation

public struct ChartItem: Codable {
    let close: Double
    let high: Double
    let low: Double
    let open: Double
    let date: Date
    
    public init(close: Double, high: Double, low: Double, open: Double, date: Date) {
        self.close = close
        self.high = high
        self.low = low
        self.open = open
        self.date = date
    }
}
