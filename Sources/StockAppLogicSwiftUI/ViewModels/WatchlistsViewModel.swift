//
//  WatchlistsViewModel.swift
//
//
//  Created by Jan Gulkowski on 06/01/2024.
//

import Foundation
import Combine
import StockAppLogic

public class WatchlistsViewModel: ObservableObject {
    @Published public var state: StatefulViewModel.State = .loading
    @Published public var error: String?
    @Published public var watchlists: [Watchlist] = []
    
    public var watchlistsCount: Int { viewModel.watchlistsCount }
    
    private let viewModel: StockAppLogic.WatchlistsViewModel
    private var store = Set<AnyCancellable>()
    
    public init(
        coordinator: Coordinator,
        watchlistsProvider: WatchlistsProviding
    ) {
        self.viewModel = StockAppLogic.WatchlistsViewModel(
            coordinator: coordinator,
            watchlistsProvider: watchlistsProvider
        )
        
        self.viewModel.statePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] value in
                self?.state = value
            }
            .store(in: &store)
        
        self.viewModel.errorPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] value in
                self?.error = value
            }
            .store(in: &store)
        
        self.viewModel.watchlistsPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] value in
                self?.watchlists = value
            }
            .store(in: &store)
    }
    
    public func getWatchlistFor(index: Int) -> Watchlist? {
        return viewModel.getWatchlistFor(index: index)
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
