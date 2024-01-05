//
//  Coordinator.swift
//  StockAppLogic
//
//  Created by Jan Gulkowski on 20/12/2023.
//

import Foundation

public protocol Coordinator: AnyObject {
    func onAppStart()
    func execute(action: Action)
}
