//
//  ApiFetcher.swift
//  StockAppLogic
//
//  Created by Jan Gulkowski on 19/12/2023.
//

import Foundation

public class ApiFetcher: ApiFetching {
    public func fetchData<T>(
        forRequest apiRequest: ApiRequest,
        andDecoder decoder: ApiDecoding
    ) async throws -> T where T : Decodable {
        let result = try await URLSession.shared.data(for: apiRequest.request)
        let data = try decoder.decode(T.self, from: result.0)
        return data
    }
    
    public init() {}
}
