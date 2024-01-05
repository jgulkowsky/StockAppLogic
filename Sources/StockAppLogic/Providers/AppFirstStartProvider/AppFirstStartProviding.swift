//
//  AppFirstStartProviding.swift
//  StockApp
//
//  Created by Jan Gulkowski on 27/12/2023.
//

import Foundation

protocol AppFirstStartProviding {
    var isFirstAppStart: Bool { get }
    func setAppFirstStarted()
}
