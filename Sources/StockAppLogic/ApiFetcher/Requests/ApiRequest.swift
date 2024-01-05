//
//  ApiRequest.swift
//  StockApp
//
//  Created by Jan Gulkowski on 19/12/2023.
//

import Foundation

public protocol ApiRequest {
    var apiToken: String? { get }
    var request: URLRequest! { get }
}

extension ApiRequest {
    var apiToken: String? {
        if let apiToken = ProcessInfo.processInfo.environment["API_TOKEN"] {
            return apiToken
        } else {
            fatalError("Add API_TOKEN into scheme/run/arguments/environment variables")
            // we will get this fatal error when tried to open app without xcode - directly from simulator - for now I don't think it's important for us to be able to run without xcode so leaving it as it is
        }
    }
}
