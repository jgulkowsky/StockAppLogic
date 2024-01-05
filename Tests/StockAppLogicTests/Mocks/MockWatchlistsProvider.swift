//
//  MockWatchlistsProvider.swift
//  StockAppLogicTests
//
//  Created by Jan Gulkowski on 02/01/2024.
//

import Combine
@testable import StockAppLogic

class MockWatchlistsProvider: WatchlistsProviding {
    var watchlists: AnyPublisher<[Watchlist], Never> {
        watchlistsSubject
            .compactMap { $0 }
            .eraseToAnyPublisher()
    }
    
    var onAddCalled = false
    var onAddWatchlist: Watchlist?
    
    var onRemoveCalled = false
    var onRemoveWatchlist: Watchlist?
    
    var onAddSymbolCalled = false
    var onAddSymbolSymbol: String?
    var onAddSymbolWatchlist: Watchlist?
    
    var onRemoveSymbolCalled = false
    var onRemoveSymbolSymbol: String?
    var onRemoveSymbolWatchlist: Watchlist?
    
    private var watchlistsSubject = CurrentValueSubject<[Watchlist]?, Never>(nil)
    
    func setupWatchlists(with watchlists: [Watchlist]) {
        self.watchlistsSubject.send(watchlists)
    }
    
    func onAdd(_ watchlist: Watchlist) {
        self.onAddCalled = true
        self.onAddWatchlist = watchlist
    }
    
    func onRemove(_ watchlist: Watchlist) {
        self.onRemoveCalled = true
        self.onRemoveWatchlist = watchlist
    }
    
    func onAdd(_ symbol: String, to watchlist: Watchlist) {
        self.onAddSymbolCalled = true
        self.onAddSymbolSymbol = symbol
        self.onAddSymbolWatchlist = watchlist
    }
    
    func onRemove(_ symbol: String, from watchlist: Watchlist) {
        self.onRemoveSymbolCalled = true
        self.onRemoveSymbolSymbol = symbol
        self.onRemoveSymbolWatchlist = watchlist
    }
}
