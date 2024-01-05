//
//  DoubleExtensionsTests.swift
//  StockAppTests
//
//  Created by Jan Gulkowski on 15/12/2023.
//

import XCTest
@testable import StockAppLogic

final class DoubleExtensionsTests: XCTestCase {
    func test_to2DecPlaces_properlyRoundsUp() throws {
        XCTAssertEqual(14.3456.to2DecPlaces(), "14.35")
    }
    
    func test_to2DecPlaces_properlyRoundsDown() throws {
        XCTAssertEqual(14.3446.to2DecPlaces(), "14.34")
    }
    
    func test_to2DecPlaces_forZeroResturns2DecPlacesToo() throws {
        XCTAssertEqual(0.to2DecPlaces(), "0.00")
    }
    
    func test_to2DecPlaces_properlyRoundsUpToOne() throws {
        XCTAssertEqual(0.9999.to2DecPlaces(), "1.00")
    }
    
    func test_to2DecPlaces_properlyRoundsDownToZero() throws {
        XCTAssertEqual(0.0049.to2DecPlaces(), "0.00")
    }
}
