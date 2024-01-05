//
//  ChartDataDecoder.swift
//  StockAppLogic
//
//  Created by Jan Gulkowski on 19/12/2023.
//

import Foundation

class ChartDataDecoder: ApiDecoding {
    private static let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        decoder.dateDecodingStrategy = .formatted(dateFormatter)
        return decoder
    }()
    
    func decode<T>(_ type: T.Type, from data: Data) throws -> T where T : Decodable {
        return try Self.decoder.decode(type, from: data)
    }
}
