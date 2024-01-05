//
//  Quote.swift
//  StockAppLogic
//
//  Created by Jan Gulkowski on 18/12/2023.
//

import Foundation

public struct Quote: Codable, Equatable {
    public let date: Date
    public let bidPrice: Double
    public let askPrice: Double
    public let lastPrice: Double
    
    private enum CodingKeys: String, CodingKey {
        case date = "latestUpdate"
        case bidPrice = "iexBidPrice"
        case askPrice = "iexAskPrice"
        case lastPrice = "latestPrice"
    }
    
    public init(date: Date, bidPrice: Double, askPrice: Double, lastPrice: Double) {
        self.date = date
        self.bidPrice = bidPrice
        self.askPrice = askPrice
        self.lastPrice = lastPrice
    }
}
