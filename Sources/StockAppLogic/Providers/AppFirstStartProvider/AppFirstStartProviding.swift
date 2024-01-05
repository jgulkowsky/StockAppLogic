//
//  AppFirstStartProviding.swift
//  StockAppLogic
//
//  Created by Jan Gulkowski on 27/12/2023.
//

import Foundation

public protocol AppFirstStartProviding {
    var isFirstAppStart: Bool { get }
    func setAppFirstStarted()
}
