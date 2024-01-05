//
//  ChartData.swift
//  StockApp
//
//  Created by Jan Gulkowski on 18/12/2023.
//

import Foundation

public struct ChartData: Codable {
    public let values: [ChartItem]
    
    private enum CodingKeys: String, CodingKey {
        case values = "chart"
    }
    
    public init(values: [ChartItem]) {
        self.values = values
    }
}
