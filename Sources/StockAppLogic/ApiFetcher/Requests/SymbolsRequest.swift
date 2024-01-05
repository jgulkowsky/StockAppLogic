//
//  SymbolsRequest.swift
//  StockApp
//
//  Created by Jan Gulkowski on 20/12/2023.
//

import Foundation

struct SymbolsRequest: ApiRequest {
    var apiToken: String? {
        return nil
    }
    
    var request: URLRequest!
    
    init(_ text: String) {
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "api.tastyworks.com"
        urlComponents.path = "/symbols/search/\(text.lowercased())"
        
        let url = urlComponents.url!
        self.request = URLRequest(url: url)
    }
}
