//
//  MockChartDataProvider.swift
//  StockAppLogicTests
//
//  Created by Jan Gulkowski on 03/01/2024.
//

import Foundation
@testable import StockAppLogic

class MockChartDataProvider: ChartDataProviding {
    enum MockChartDataProviderError: Error {
        case any
    }
    
    // setters
    var delayInMillis: UInt64?
    var shouldThrow = false
    var chartDataToReturn: ChartData?
    
    // getters
    var getChartDataForSymbolCalled = false
    var getChartDataForSymbolSymbol: String?
    
    func getChartData(forSymbol symbol: String) async throws -> ChartData {
        getChartDataForSymbolCalled = true
        getChartDataForSymbolSymbol = symbol
        
        if let delayInMillis = delayInMillis {
            try? await Task.sleep(nanoseconds: delayInMillis)
        }
        
        if shouldThrow {
            throw MockChartDataProviderError.any
        }
        
        if let chartDataToReturn = chartDataToReturn {
            return chartDataToReturn
        }
        
        let dates = Date.daysBetween(
            startDate: Date(timeIntervalSince1970: 1698796800), // 1st of November
            andEndDate: Date(timeIntervalSince1970: 1701388800) // 1st of December
        )
        let items = generateRandomChartItems(for: dates)
        let chartData = ChartData(values: items)
        return chartData
    }
}

private extension MockChartDataProvider {
    func generateRandomChartItems(for dates: [Date]) -> [ChartItem] {
        var chartData: [ChartItem] = []
        for date in dates {
            let close = Double.random(in: 80.0...100.0)
            let high = Double.random(in: close...110.0)
            let low = Double.random(in: 70.0...close)
            let open = Double.random(in: low...high)
            let chartItem = ChartItem(close: close, high: high, low: low, open: open, date: date)
            chartData.append(chartItem)
        }
        return chartData
    }
}
