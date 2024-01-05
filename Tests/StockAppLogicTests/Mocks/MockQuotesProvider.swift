//
//  MockQuotesProvider.swift
//  StockAppTests
//
//  Created by Jan Gulkowski on 03/01/2024.
//

import Foundation
@testable import StockAppLogic

class MockQuotesProvider: QuotesProviding {
    enum MockQuotesProviderError: Error {
        case any
    }
    
    // setters
    var delayInMillis: UInt64?
    var shouldThrow = false
    var quoteToReturn: Quote?
    
    // getters
    var getQuoteForSymbolCalled = false
    var getQuoteForSymbolCallsCounter = 0
    var getQuoteForSymbolSymbol: String?
    
    func getQuote(forSymbol symbol: String) async throws -> Quote {
        getQuoteForSymbolCalled = true
        getQuoteForSymbolCallsCounter += 1
        getQuoteForSymbolSymbol = symbol
        
        if let delayInMillis = delayInMillis {
            try? await Task.sleep(nanoseconds: delayInMillis)
        }
        
        if shouldThrow {
            throw MockQuotesProviderError.any
        }
        
        if let quoteToReturn = quoteToReturn {
            return quoteToReturn
        }

        let bidPrice = Double.random(in: 80.0...100.0)
        let askPrice = Double.random(in: bidPrice...110.0)
        let lastPrice = Double.random(in: bidPrice...askPrice)
        let quote: Quote = Quote(date: .now, bidPrice: bidPrice, askPrice: askPrice, lastPrice: lastPrice)
        return quote
    }
}
