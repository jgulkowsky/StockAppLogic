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
    @Published public var symbols: [String] = []
    
    public var symbolsCount: Int { viewModel.symbolsCount }
    
    private let viewModel: StockAppLogic.AddNewSymbolViewModel
    private var store = Set<AnyCancellable>()
    
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
        
        self.viewModel.symbolsPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] value in
                self?.symbols = value
            }
            .store(in: &store)
    }
    
    public func getSymbolFor(index: Int) -> String? {
        return viewModel.getSymbolFor(index: index)
    }
    
    public func onSearchTextChanged(to newText: String) {
        viewModel.onSearchTextChanged(to: newText)
    }
    
    public func onItemTapped(at index: Int) {
        viewModel.onItemTapped(at: index)
    }
}
