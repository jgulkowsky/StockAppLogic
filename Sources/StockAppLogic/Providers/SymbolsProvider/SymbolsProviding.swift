//
//  SymbolsProviding.swift
//  StockApp
//
//  Created by Jan Gulkowski on 20/12/2023.
//

import Foundation

protocol SymbolsProviding {
    func getSymbols(startingWith text: String) async throws -> [String]
}
