//
//  WatchlistsProvider.swift
//  StockApp
//
//  Created by Jan Gulkowski on 19/12/2023.
//

import Foundation
import Combine

public class WatchlistsProvider: WatchlistsProviding {
    public var watchlists: AnyPublisher<[Watchlist], Never> {
        watchlistsSubject
            .compactMap { $0 }
            .eraseToAnyPublisher()
    }
    
    private let coreDataProvider: WatchlistsCoreDataProviding
    
    private var watchlistsSubject = CurrentValueSubject<[Watchlist]?, Never>(nil)
    private var store = Set<AnyCancellable>()
    
    public init(
        coreDataProvider: WatchlistsCoreDataProviding,
        appFirstStartProvider: AppFirstStartProviding,
        initialList: Watchlist
    ) {
        self.coreDataProvider = coreDataProvider
        
        let watchlists = coreDataProvider.getWatchlists()
        watchlistsSubject.send(watchlists)
        
        if appFirstStartProvider.isFirstAppStart && watchlists.isEmpty {
            onAdd(initialList)
        }
    }
    
    public func onAdd(_ watchlist: Watchlist) {
        watchlistsSubject.value?.append(watchlist)
        
        coreDataProvider.addWatchlist(watchlist)
    }
    
    public func onRemove(_ watchlist: Watchlist) {
        guard var watchlists = watchlistsSubject.value,
              let index = watchlists.firstIndex(where: { $0.id == watchlist.id } ) else { return }
        
        watchlists.remove(at: index)
        watchlistsSubject.send(watchlists)
        
        coreDataProvider.deleteWatchlist(watchlist)
    }
    
    public func onAdd(_ symbol: String, to watchlist: Watchlist) {
        guard var watchlists = watchlistsSubject.value,
              let index = watchlists.firstIndex(where: { $0.id == watchlist.id } ) else { return }
        
        var watchlist = watchlist
        watchlist.symbols.append(symbol)
        watchlists[Int(index)] = watchlist
        watchlistsSubject.send(watchlists)
        
        coreDataProvider.addSymbolToWatchlist(symbol, watchlist)
    }
    
    public func onRemove(_ symbol: String, from watchlist: Watchlist) {
        guard var watchlists = watchlistsSubject.value,
              let index = watchlists.firstIndex(where: { $0.id == watchlist.id } ),
              let symbolIndex = watchlist.symbols.firstIndex(of: symbol) else { return }
        
        var watchlist = watchlist
        watchlist.symbols.remove(at: symbolIndex)
        watchlists[Int(index)] = watchlist
        watchlistsSubject.send(watchlists)
        
        coreDataProvider.removeSymbolFromWatchlist(symbol, watchlist)
    }
}
