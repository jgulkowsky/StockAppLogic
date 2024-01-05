//
//  MockWatchlistsCoreDataProvider.swift
//  StockAppTests
//
//  Created by Jan Gulkowski on 04/01/2024.
//

import Foundation
@testable import StockAppLogic

class MockWatchlistsCoreDataProvider: WatchlistsCoreDataProviding {
    // setters
    var watchlistsToReturn: [Watchlist] = []
    
    //getters
    var getWatchlistsCalled = false
    
    var addWatchlistCalled = false
    var addWatchlistWatchlist: Watchlist?
    
    var addSymbolToWatchlistCalled = false
    var addSymbolToWatchlistSymbol: String?
    var addSymbolToWatchlistWatchlist: Watchlist?
    
    var removeSymbolFromWatchlistCalled = false
    var removeSymbolFromWatchlistSymbol: String?
    var removeSymbolFromWatchlistWatchlist: Watchlist?
    
    var deleteWatchlistCalled = false
    var deleteWatchlistWatchlist: Watchlist?
    
    func getWatchlists() -> [Watchlist] {
        getWatchlistsCalled = true
        return watchlistsToReturn
    }
    
    func addWatchlist(_ watchlist: Watchlist) {
        addWatchlistCalled = true
        addWatchlistWatchlist = watchlist
    }
    
    func addSymbolToWatchlist(_ symbol: String, _ watchlist: Watchlist) {
        addSymbolToWatchlistCalled = true
        addSymbolToWatchlistSymbol = symbol
        addSymbolToWatchlistWatchlist = watchlist
    }
    
    func removeSymbolFromWatchlist(_ symbol: String, _ watchlist: Watchlist) {
        removeSymbolFromWatchlistCalled = true
        removeSymbolFromWatchlistSymbol = symbol
        removeSymbolFromWatchlistWatchlist = watchlist
    }
    
    func deleteWatchlist(_ watchlist: Watchlist) {
        deleteWatchlistCalled = true
        deleteWatchlistWatchlist = watchlist
    }
}
