//
//  ApiFetching.swift
//  StockAppLogic
//
//  Created by Jan Gulkowski on 19/12/2023.
//

import Foundation

public protocol ApiFetching {
    func fetchData<T>(
        forRequest apiRequest: ApiRequest,
        andDecoder decoder: ApiDecoding
    ) async throws -> T where T : Decodable
}
