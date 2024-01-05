//
//  ChartItemExtensions.swift
//  StockAppTests
//
//  Created by Jan Gulkowski on 03/01/2024.
//

import Foundation
@testable import StockAppLogic

extension ChartItem: Equatable {
    public static func == (lhs: ChartItem, rhs: ChartItem) -> Bool {
        return lhs.close == rhs.close && lhs.high == rhs.high && lhs.low == rhs.low && lhs.open == rhs.open && lhs.date == rhs.date
    }
}
