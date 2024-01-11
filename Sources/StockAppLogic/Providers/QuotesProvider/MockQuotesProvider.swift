//
//  MockQuotesProvider.swift
//  StockAppLogic
//
//  Created by Jan Gulkowski on 27/12/2023.
//

import Foundation

public class MockQuotesProvider: QuotesProviding {
    public enum MockQuotesProviderError: Error {
        case any
    }
    
    public init() {}
    
    public func getQuote(forSymbol symbol: String) async throws -> Quote {
        try? await Task.sleep(nanoseconds: 1 * 1_000_000_000) // 1 second
        
        if Bool.random() {
            throw MockQuotesProviderError.any
        }
        
        let bidPrice = Double.random(in: 80.0...100.0)
        let askPrice = Double.random(in: bidPrice...110.0)
        let lastPrice = Double.random(in: bidPrice...askPrice)
        let quote: Quote = Quote(date: .now, bidPrice: bidPrice, askPrice: askPrice, lastPrice: lastPrice)
        return quote
    }
}
