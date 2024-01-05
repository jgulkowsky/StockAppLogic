//
//  DateExtensions.swift
//  StockApp
//
//  Created by Jan Gulkowski on 18/12/2023.
//

import Foundation

extension Date {
    static func daysBetween(startDate: Date, andEndDate endDate: Date) -> [Date] {
        var dates: [Date] = []
        var currentDate = startDate

        while currentDate <= endDate {
            dates.append(currentDate)
            currentDate = Calendar.current.date(byAdding: .day, value: 1, to: currentDate)!
        }

        return dates
    }
    
    func last30Days() -> [Date] {
        return Date.daysBetween(
            startDate: Calendar.current.date(byAdding: .day, value: -29, to: self) ?? self,
            andEndDate: self
        )
    }
}
