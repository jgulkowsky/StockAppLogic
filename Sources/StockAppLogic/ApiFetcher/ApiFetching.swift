//
//  ApiFetching.swift
//  StockApp
//
//  Created by Jan Gulkowski on 19/12/2023.
//

import Foundation

protocol ApiFetching {
    func fetchData<T>(
        forRequest apiRequest: ApiRequest,
        andDecoder decoder: ApiDecoding
    ) async throws -> T where T : Decodable
}
