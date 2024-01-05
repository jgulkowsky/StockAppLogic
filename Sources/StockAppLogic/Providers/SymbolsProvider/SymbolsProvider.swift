//
//  SymbolsProvider.swift
//  StockApp
//
//  Created by Jan Gulkowski on 20/12/2023.
//

import Foundation

public class SymbolsProvider: SymbolsProviding {
    private let apiFetcher: ApiFetching
    
    public init(apiFetcher: ApiFetching) {
        self.apiFetcher = apiFetcher
    }
    
    public func getSymbols(startingWith text: String) async throws -> [String] {
        let response: SymbolsResponse = try await apiFetcher.fetchData(
            forRequest: SymbolsRequest(text),
            andDecoder: SymbolsDecoder()
        )
        
        let symbols = response.data.items
            .map { $0.symbol }
        
        return symbols
    }
}
