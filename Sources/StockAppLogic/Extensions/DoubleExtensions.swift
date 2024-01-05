//
//  DoubleExtensions.swift
//  StockApp
//
//  Created by Jan Gulkowski on 27/12/2023.
//

import Foundation

extension Double {
    func to2DecPlaces() -> String {
        return String(format: "%.2f", self) 
    }
}
