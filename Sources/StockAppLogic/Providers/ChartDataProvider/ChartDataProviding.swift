//
//  ChartDataProviding.swift
//  StockApp
//
//  Created by Jan Gulkowski on 19/12/2023.
//

import Foundation

public protocol ChartDataProviding {
    func getChartData(forSymbol symbol: String) async throws -> ChartData
}
