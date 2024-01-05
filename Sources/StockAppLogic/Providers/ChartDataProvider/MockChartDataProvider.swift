//
//  MockChartDataProvider.swift
//  StockAppLogic
//
//  Created by Jan Gulkowski on 19/12/2023.
//

import Foundation

// todo: consinder having it rather only in the ViewApp as this is for some fast update to go on with development - if we need to change sth here then we would need to update first the package then provide the ViewApp with the new version of the package...

public class MockChartDataProvider: ChartDataProviding {
    public func getChartData(forSymbol symbol: String) async throws -> ChartData {
        try? await Task.sleep(nanoseconds: 2 * 1_000_000_000) // 2 seconds
//        let dates = Date.last30Days()
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
