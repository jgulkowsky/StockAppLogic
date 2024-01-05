//
//  AppFirstStartProvider.swift
//  StockAppLogic
//
//  Created by Jan Gulkowski on 27/12/2023.
//

import Foundation

// todo: you will probably need to use Bundle.module instead of Bundle.main

public class AppFirstStartProvider: AppFirstStartProviding {
    public var isFirstAppStart: Bool
    
    private static var key_hasAppBeenStartedBefore = {
        guard let bundleName = Bundle.main.infoDictionary?[kCFBundleNameKey as String] as? String else { fatalError("Cannot retrive bundleName") }
        return "\(bundleName).hasAppBeenStartedBefore"
    }()
    
    
    public init() {
        let hasAppBeenStartedBefore = UserDefaults.standard.bool(forKey: AppFirstStartProvider.key_hasAppBeenStartedBefore)
        self.isFirstAppStart = !hasAppBeenStartedBefore
    }
    
    public func setAppFirstStarted() {
        UserDefaults.standard.set(true, forKey: AppFirstStartProvider.key_hasAppBeenStartedBefore)
    }
}
