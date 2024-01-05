//
//  ChartItem.swift
//  StockApp
//
//  Created by Jan Gulkowski on 19/12/2023.
//

import Foundation

struct ChartItem: Codable {
    let close: Double
    let high: Double
    let low: Double
    let open: Double
    let date: Date
}
