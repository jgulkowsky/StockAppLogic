//
//  AddNewSymbolViewModel.swift
//  
//
//  Created by Jan Gulkowski on 06/01/2024.
//

import Foundation
import Combine
import StockAppLogic

public class AddNewSymbolViewModel: ObservableObject {
    @Published public var symbols: [String] = [] // todo: bind it somehow with symbolsPublisher from StockAppLogic.AddNewSymbolViewModel
    
    private var viewModel: StockAppLogic.AddNewSymbolViewModel
    
    public init(
        coordinator: Coordinator,
        watchlistsProvider: WatchlistsProviding,
        symbolsProvider: SymbolsProviding,
        watchlist: Watchlist,
        searchTextDebounceMillis: Int
    ) {
        self.viewModel = StockAppLogic.AddNewSymbolViewModel(
            coordinator: coordinator,
            watchlistsProvider: watchlistsProvider,
            symbolsProvider: symbolsProvider,
            watchlist: watchlist,
            searchTextDebounceMillis: searchTextDebounceMillis
        )
    }
}
