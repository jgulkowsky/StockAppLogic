//
//  MockSymbolsProvider.swift
//  StockAppLogicTests
//
//  Created by Jan Gulkowski on 03/01/2024.
//

import Foundation
@testable import StockAppLogic

class MockSymbolsProvider: SymbolsProviding {
    var getSymbolsCalled = false
    var getSymbolsText: String?
    
    private var symbolsToReturn = [String]()
    
    func getSymbols(startingWith text: String) async throws -> [String] {
        getSymbolsCalled = true
        getSymbolsText = text
        return symbolsToReturn
    }
    
    func setupSymbolsToReturn(in number: Int) -> [String] {
        symbolsToReturn = []
        for _ in 0..<number {
            let amountOfLetters = Int.random(in: 2...6)
            let symbol = getRandomString(ofLength: amountOfLetters).uppercased()
            symbolsToReturn.append(symbol)
        }
        return symbolsToReturn
    }
}

private extension MockSymbolsProvider {
    func getRandomString(ofLength length: Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<length).map{ _ in letters.randomElement()! })
    }
}
