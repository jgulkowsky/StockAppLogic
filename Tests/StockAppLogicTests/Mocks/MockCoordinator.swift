//
//  MockCoordinator.swift
//  StockAppTests
//
//  Created by Jan Gulkowski on 02/01/2024.
//

import Foundation
@testable import StockAppLogic

class MockCoordinator: Coordinator {
    var executeActionCalled = false
    var executeAction: Action?
    
    func onAppStart() {}
    
    func execute(action: Action) {
        executeActionCalled = true
        executeAction = action
    }
}
