//
//  ChartDataRequest.swift
//  StockApp
//
//  Created by Jan Gulkowski on 19/12/2023.
//

import Foundation

struct ChartDataRequest: ApiRequest {
    var request: URLRequest!
    
    init(_ symbol: String) {
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "cloud.iexapis.com"
        urlComponents.path = "/stable/stock/\(symbol.lowercased())/batch"
        
        urlComponents.queryItems = [
            URLQueryItem(name: "types", value: "chart"),
            URLQueryItem(name: "range", value: "3m"),
            URLQueryItem(name: "last", value: "30")
        ]
        
        if let apiToken = self.apiToken {
            urlComponents.queryItems?.append(
                URLQueryItem(name: "token", value: apiToken)
            )
        }
        
        let url = urlComponents.url!
        self.request = URLRequest(url: url)
    }
}
