//
//  WatchlistViewModel.swift
//
//
//  Created by Jan Gulkowski on 06/01/2024.
//

import Foundation
import Combine
import StockAppLogic

public class WatchlistViewModel: ObservableObject {
    @Published public var state: StatefulViewModel.State = .loading
    @Published public var error: String?
    @Published public var title: String = ""
    @Published public var stockItems: [StockItem] = []
    
    public var stockItemsCount: Int { viewModel.stockItemsCount }
    
    private let viewModel: StockAppLogic.WatchlistViewModel
    private var store = Set<AnyCancellable>()
    
    public init(
        coordinator: Coordinator,
        watchlistsProvider: WatchlistsProviding,
        quotesProvider: QuotesProviding,
        watchlist: Watchlist,
        refreshRate: Double
    ) {
        self.viewModel = StockAppLogic.WatchlistViewModel(
            coordinator: coordinator,
            watchlistsProvider: watchlistsProvider,
            quotesProvider: quotesProvider,
            watchlist: watchlist,
            refreshRate: refreshRate
        )
        
        self.viewModel.statePublisher.sink { [weak self] value in
            self?.state = value
        }.store(in: &store)
        
        self.viewModel.errorPublisher.sink { [weak self] value in
            self?.error = value
        }.store(in: &store)
        
        self.viewModel.titlePublisher.sink { [weak self] value in
            self?.title = value
        }.store(in: &store)
        
        self.viewModel.stockItemsPublisher.sink { [weak self] value in
            self?.stockItems = value
        }.store(in: &store)
    }
    
    public func onViewWillAppear() {
        viewModel.onViewWillAppear()
    }

    public func onViewWillDisappear() {
        viewModel.onViewWillDisappear()
    }
    
    public func getStockItemFor(index: Int) -> StockItem? {
        return viewModel.getStockItemFor(index: index)
    }
    
    public func onItemTapped(at index: Int) {
        viewModel.onItemTapped(at: index)
    }
    
    public func onAddButtonTapped() {
        viewModel.onAddButtonTapped()
    }
    
    public func onItemSwipedOut(at index: Int) {
        viewModel.onItemSwipedOut(at: index)
    }
}
