//
//  ChartDataExtensions.swift
//  StockAppTests
//
//  Created by Jan Gulkowski on 03/01/2024.
//

import Foundation
@testable import StockAppLogic

extension ChartData: Equatable {
    public static func == (lhs: ChartData, rhs: ChartData) -> Bool {
        return lhs.values == rhs.values
    }
}
