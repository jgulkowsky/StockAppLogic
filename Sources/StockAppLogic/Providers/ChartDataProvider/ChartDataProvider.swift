//
//  ChartDataProvider.swift
//  StockAppLogic
//
//  Created by Jan Gulkowski on 19/12/2023.
//

import Foundation

public class ChartDataProvider: ChartDataProviding {
    private let apiFetcher: ApiFetching
    
    public init(apiFetcher: ApiFetching) {
        self.apiFetcher = apiFetcher
    }
    
    public func getChartData(forSymbol symbol: String) async throws -> ChartData {
        let chartData: ChartData = try await apiFetcher.fetchData(
            forRequest: ChartDataRequest(symbol),
            andDecoder: ChartDataDecoder()
        )
        return chartData
    }
}

