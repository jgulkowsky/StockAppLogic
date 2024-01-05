//
//  WatchlistsCoreDataProviding.swift
//  StockApp
//
//  Created by Jan Gulkowski on 04/01/2024.
//

import Foundation

protocol WatchlistsCoreDataProviding {
    func getWatchlists() -> [Watchlist]
    func addWatchlist(_ watchlist: Watchlist)
    func addSymbolToWatchlist(_ symbol: String, _ watchlist: Watchlist)
    func removeSymbolFromWatchlist(_ symbol: String, _ watchlist: Watchlist)
    func deleteWatchlist(_ watchlist: Watchlist)
}
