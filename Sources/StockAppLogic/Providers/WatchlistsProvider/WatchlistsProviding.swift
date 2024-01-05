//
//  WatchlistsProviding.swift
//  StockAppLogic
//
//  Created by Jan Gulkowski on 19/12/2023.
//

import Foundation
import Combine

public protocol WatchlistsProviding {
    var watchlists: AnyPublisher<[Watchlist], Never> { get }
    
    func onAdd(_ watchlist: Watchlist)
    func onRemove(_ watchlist: Watchlist)
    
    func onAdd(_ symbol: String, to watchlist: Watchlist)
    func onRemove(_ symbol: String, from watchlist: Watchlist)
}
