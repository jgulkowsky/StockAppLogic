//
//  QuoteDecoder.swift
//  StockApp
//
//  Created by Jan Gulkowski on 19/12/2023.
//

import Foundation

class QuoteDecoder: ApiDecoding {
    private static let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .millisecondsSince1970
        return decoder
    }()
    
    func decode<T>(_ type: T.Type, from data: Data) throws -> T where T : Decodable {
        return try Self.decoder.decode(type, from: data)
    }
}
