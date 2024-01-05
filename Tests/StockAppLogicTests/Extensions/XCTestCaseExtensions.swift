//
//  XCTestCaseExtensions.swift
//  StockAppLogicTests
//
//  Created by Jan Gulkowski on 03/01/2024.
//

import XCTest

extension XCTestCase {
    func getIndexAndNumberOfItems_whereIndexIsSmallerThanNumberOfItems() -> (Int, Int) {
        let index = Int.random(in: 0..<5)
        let numberOfItems = index + Int.random(in: 1..<5)
        return (index, numberOfItems)
    }
    
    func getIndexAndNumberOfItems_whereIndexIsGreaterThanOrEqualToNumberOfItems() -> (Int, Int) {
        let index = Int.random(in: 0..<5)
        let numberOfItems = max(index - Int.random(in: 0..<5), 0)
        return (index, numberOfItems)
    }
    
    func wait(for timeout: Double) {
        let expectation = XCTestExpectation(description: UUID().description) // this should never be fulfilled - thanks to this we are just waiting for timeout to pass
        expectation.isInverted = true
        wait(for: [expectation], timeout: timeout)
    }
}
