//
//  QuotesProvider.swift
//  StockApp
//
//  Created by Jan Gulkowski on 19/12/2023.
//

import Foundation

class QuotesProvider: QuotesProviding {
    private let apiFetcher: ApiFetching
    
    init(apiFetcher: ApiFetching) {
        self.apiFetcher = apiFetcher
    }
    
    func getQuote(forSymbol symbol: String) async throws -> Quote {
        let quote: Quote = try await apiFetcher.fetchData(
            forRequest: QuoteRequest(symbol),
            andDecoder: QuoteDecoder()
        )
        return quote
    }
}

