//
//  MockAppFirstStartProvider.swift
//  StockAppTests
//
//  Created by Jan Gulkowski on 04/01/2024.
//

import Foundation
@testable import StockAppLogic

class MockAppFirstStartProvider: AppFirstStartProviding {
    var isFirstAppStart: Bool { shouldReturnThatThisIsFirstAppStart }
    
    // setters
    var shouldReturnThatThisIsFirstAppStart: Bool = false
    
    func setAppFirstStarted() {}
}
