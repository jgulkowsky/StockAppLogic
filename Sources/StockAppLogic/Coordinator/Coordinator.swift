//
//  Coordinator.swift
//  StockApp
//
//  Created by Jan Gulkowski on 20/12/2023.
//

import Foundation

protocol Coordinator: AnyObject {
    func onAppStart()
    func execute(action: Action)
}
