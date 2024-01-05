//
//  QuoteRequest.swift
//  StockApp
//
//  Created by Jan Gulkowski on 19/12/2023.
//

import Foundation

struct QuoteRequest: ApiRequest {
    var request: URLRequest!
    
    init(_ symbol: String) {
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "cloud.iexapis.com"
        urlComponents.path = "/stable/stock/\(symbol.lowercased())/quote"
        
        if let apiToken = self.apiToken {
            urlComponents.queryItems = [
                URLQueryItem(name: "token", value: apiToken)
            ]
        }
        
        let url = urlComponents.url!
        self.request = URLRequest(url: url)
    }
}
