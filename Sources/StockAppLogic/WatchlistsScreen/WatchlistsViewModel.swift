//
//  WatchlistsViewModel.swift
//  StockAppLogic
//
//  Created by Jan Gulkowski on 20/12/2023.
//

import Foundation
import Combine

public class WatchlistsViewModel: StatefulViewModel {
    public var watchlistsPublisher: AnyPublisher<[Watchlist], Never> {
        watchlistsSubject
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
    
    public var watchlistsCount: Int { watchlistsSubject.value.count }
    
    private var stateSubject = CurrentValueSubject<State, Never>(.loading)
    private var errorSubject = CurrentValueSubject<String?, Never>(nil)
    
    private var watchlistsSubject = CurrentValueSubject<[Watchlist], Never>([])
    
    private var store = Set<AnyCancellable>()
    
    private unowned let coordinator: Coordinator
    private let watchlistsProvider: WatchlistsProviding
    
    public init(
        coordinator: Coordinator,
        watchlistsProvider: WatchlistsProviding
    ) {
#if DEBUG
        print("@jgu: \(Self.self).init()")
#endif
        self.coordinator = coordinator
        self.watchlistsProvider = watchlistsProvider
        
        super.init(
            stateSubject: stateSubject,
            errorSubject: errorSubject
        )
        
        setupBindings()
    }
    
#if DEBUG
    deinit {
        print("@jgu: \(Self.self).deinit()")
    }
#endif
    
    public func getWatchlistFor(index: Int) -> Watchlist? {
        guard index < watchlistsSubject.value.count else { return nil }
        return watchlistsSubject.value[index]
    }
    
    public func onItemTapped(at index: Int) {
        guard let watchlist = getWatchlistFor(index: index) else { return }
        coordinator.execute(action: .itemSelected(data: watchlist))
    }
    
    public func onAddButtonTapped() {
        coordinator.execute(action: .addButtonTapped(data: nil))
    }
    
    public func onItemSwipedOut(at index: Int) {
        var watchlists = watchlistsSubject.value
        guard getWatchlistFor(index: index) != nil else { return }
        
        let watchlist = watchlists.remove(at: index)
        watchlistsSubject.send(watchlists)
        
        watchlistsProvider.onRemove(watchlist)
    }
}

private extension WatchlistsViewModel {
    func setupBindings() {
        self.watchlistsProvider.watchlists
            .sink { [weak self] watchlists in
                self?.watchlistsSubject.send(watchlists)
                self?.stateSubject.send(.dataObtained)
            }
            .store(in: &store)
    }
}
