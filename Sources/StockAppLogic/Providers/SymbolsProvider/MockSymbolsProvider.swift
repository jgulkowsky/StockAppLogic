//
//  MockSymbolsProvider.swift
//  StockAppLogic
//
//  Created by Jan Gulkowski on 28/12/2023.
//

import Foundation

public class MockSymbolsProvider: SymbolsProviding {
    public enum MockSymbolsProviderError: Error {
        case any
    }
    
    public func getSymbols(startingWith text: String) async throws -> [String] {
        try? await Task.sleep(nanoseconds: 1 * 1_000_000_000) // 1 second
        
        if Bool.random() {
            throw MockSymbolsProviderError.any
        }
        
        guard !text.isEmpty else { return [] }
        
        var symbols: [String] = []
        let amountOfSymbols = Int.random(in: 0...10)
        for _ in 0..<amountOfSymbols {
            let amountOfLetters = Int.random(in: 2...6)
            let symbol = getRandomString(ofLength: amountOfLetters).uppercased()
            symbols.append(symbol)
        }
        return symbols
    }
    
    private func getRandomString(ofLength length: Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<length).map{ _ in letters.randomElement()! })
    }
}
