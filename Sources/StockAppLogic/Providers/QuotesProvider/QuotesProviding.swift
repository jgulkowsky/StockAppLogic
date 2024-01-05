//
//  QuotesProviding.swift
//  StockApp
//
//  Created by Jan Gulkowski on 19/12/2023.
//

import Foundation

public protocol QuotesProviding {
    func getQuote(forSymbol symbol: String) async throws -> Quote
}
