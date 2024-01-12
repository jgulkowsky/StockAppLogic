//
//  AddNewSymbolViewModel.swift
//  StockAppLogic
//
//  Created by Jan Gulkowski on 20/12/2023.
//

import Foundation
import Combine

// todo: make it also a StatefulViewModel?
public class AddNewSymbolViewModel {
    public var symbolsPublisher: AnyPublisher<[String], Never> {
        symbolsSubject
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
    
    public var symbolsCount: Int { symbolsSubject.value.count }
    
    private var symbolsSubject = CurrentValueSubject<[String], Never>([])
    private var searchTextSubject = CurrentValueSubject<String?, Never>(nil)
    
    private var store = Set<AnyCancellable>()
    
    private unowned let coordinator: Coordinator
    private let watchlistsProvider: WatchlistsProviding
    private let symbolsProvider: SymbolsProviding
    private var watchlist: Watchlist
    private let searchTextDebounceMillis: Int
    
    public init(
        coordinator: Coordinator,
        watchlistsProvider: WatchlistsProviding,
        symbolsProvider: SymbolsProviding,
        watchlist: Watchlist,
        searchTextDebounceMillis: Int
    ) {
#if DEBUG
        print("@jgu: \(Self.self).init()")
#endif
        self.coordinator = coordinator
        self.watchlistsProvider = watchlistsProvider
        self.symbolsProvider = symbolsProvider
        self.watchlist = watchlist
        self.searchTextDebounceMillis = searchTextDebounceMillis
        setupBindings()
    }
    
#if DEBUG
    deinit {
        print("@jgu: \(Self.self).deinit()")
    }
#endif
    
    public func getSymbolFor(index: Int) -> String? {
        guard index < symbolsSubject.value.count else { return nil }
        return symbolsSubject.value[index]
    }
    
    public func onSearchTextChanged(to newText: String) {
        searchTextSubject.send(newText)
    }
    
    public func onItemTapped(at index: Int) {
        guard let symbol = getSymbolFor(index: index) else { return }
        
        if !watchlist.symbols.contains(symbol) {
            watchlistsProvider.onAdd(symbol, to: watchlist)
            watchlist.symbols.append(symbol)
        }
        
        coordinator.execute(action: .itemSelected(data: nil))
    }
}

private extension AddNewSymbolViewModel {
    func setupBindings() {
        self.searchTextSubject
            .debounce(for: .milliseconds(self.searchTextDebounceMillis), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .compactMap { $0 }
            .sink { [weak self] searchText in
                self?.fetchData(for: searchText)
            }
            .store(in: &store)
    }
    
    func fetchData(for text: String) {
        Task {
            let symbols = try? await self.symbolsProvider.getSymbols(startingWith: text)
            symbolsSubject.send(symbols ?? [])
        }
    }
}
