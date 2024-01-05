//
//  ApiDecoding.swift
//  StockApp
//
//  Created by Jan Gulkowski on 19/12/2023.
//

import Foundation

protocol ApiDecoding {
    func decode<T>(_ type: T.Type, from data: Data) throws -> T where T : Decodable
}
