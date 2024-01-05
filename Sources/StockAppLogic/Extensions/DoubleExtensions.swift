//
//  DoubleExtensions.swift
//  StockAppLogic
//
//  Created by Jan Gulkowski on 27/12/2023.
//

import Foundation

public extension Double {
    func to2DecPlaces() -> String {
        return String(format: "%.2f", self) 
    }
}
