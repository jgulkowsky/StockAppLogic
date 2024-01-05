//
//  DateExtensionsTests.swift
//  StockAppLogicTests
//
//  Created by Jan Gulkowski on 30/12/2023.
//

import XCTest
@testable import StockAppLogic

final class DateExtensionsTests: XCTestCase {
    func test_daysBetween_startDate_01Jan2023MidnightUtc0_endDate_07Jan2023MidnightUtc0_shouldReturn7DaysStartingWithTheStartDateAndEndingWithTheEndDate() throws {
        // given
        let startDate = Date(timeIntervalSince1970: 1672531200) // 01 Jan 2023 midnight utc 0
        let endDate = Date(timeIntervalSince1970: 1673049600) // 07 Jan 2023 midnight utc 0
        
        // when
        let dates = Date.daysBetween(startDate: startDate, andEndDate: endDate)
        
        // then
        let expectedDates = [
            Date(timeIntervalSince1970: 1672531200),
            Date(timeIntervalSince1970: 1672617600),
            Date(timeIntervalSince1970: 1672704000),
            Date(timeIntervalSince1970: 1672790400),
            Date(timeIntervalSince1970: 1672876800),
            Date(timeIntervalSince1970: 1672963200),
            Date(timeIntervalSince1970: 1673049600)
        ]
        XCTAssertEqual(dates, expectedDates)
    }
    
    func test_last30Days_givenDateIs_07Jan2023_1425Utc0_shouldReturn30DatesBetween_09Dec2022MidnightUtc0_and_07Jan2023MidnightUtc0() throws {
        // given
        let date = Date(timeIntervalSince1970: 1673049600) // 07 Jan 2023 midnight utc 0
        
        // when
        let dates = date.last30Days()
        
        // then
        var expectedDates: [Date] = []
        let stepToPreviousDay = -1 * 24 * 60 * 60 // 86400
        for i in 0..<30 {
            expectedDates.append(date.addingTimeInterval(Double(i * stepToPreviousDay)))
        }
        expectedDates = expectedDates.sorted()
        
        XCTAssertEqual(dates, expectedDates)
    }
}
