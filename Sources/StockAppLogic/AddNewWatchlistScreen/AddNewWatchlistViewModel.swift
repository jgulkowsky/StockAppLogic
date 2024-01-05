//
//  AddNewWatchlistViewModel.swift
//  StockApp
//
//  Created by Jan Gulkowski on 20/12/2023.
//

import Foundation
import Combine

class AddNewWatchlistViewModel {
    var errorPublisher: AnyPublisher<String?, Never> {
        errorSubject
            .eraseToAnyPublisher()
    }
    
    var watchlistTextPublisher: AnyPublisher<String, Never> {
        watchlistTextSubject
            .compactMap { $0 }
            .eraseToAnyPublisher()
    }
    
    private var errorSubject = CurrentValueSubject<String?, Never>(nil)
    private var watchlistTextSubject = CurrentValueSubject<String?, Never>(nil)
    private var store = Set<AnyCancellable>()
    
    private unowned let coordinator: Coordinator
    private let watchlistsProvider: WatchlistsProviding
    
    private let emptyNameError: String
    private let watchlistAlreadyExistsError: String
    
    private var watchlists: [Watchlist]?
    
    init(coordinator: Coordinator,
         watchlistsProvider: WatchlistsProviding,
         emptyNameError: String = "Watchlist name can't be empty!",
         watchlistAlreadyExistsError: String = "Watchlist with this name already exists!"
    ) {
#if DEBUG
        print("@jgu: \(Self.self).init()")
#endif
        self.coordinator = coordinator
        self.watchlistsProvider = watchlistsProvider
        self.emptyNameError = emptyNameError
        self.watchlistAlreadyExistsError = watchlistAlreadyExistsError
        setupBindings()
    }
    
    func onTextFieldFocused(initialText: String?) {
        errorSubject.send(nil)
    }
    
    func onTextFieldSubmitted(text: String?) {
        guard let text = text,
              let watchlists = watchlists else { return }
        
        let watchlistNames = watchlists.map { $0.name }
        let trimmedName = text.trimmingCharacters(in: .whitespaces)
        
        watchlistTextSubject.send(trimmedName)
        
        guard !trimmedName.isEmpty else {
            errorSubject.send(emptyNameError)
            return
        }
        guard !watchlistNames.contains(where: { $0 == trimmedName }) else {
            errorSubject.send(watchlistAlreadyExistsError)
            return
        }
        
        watchlistsProvider.onAdd(
            Watchlist.init(id: UUID(), name: trimmedName, symbols: [])
        )
        coordinator.execute(action: .inputSubmitted)
    }
    
#if DEBUG
    deinit {
        print("@jgu: \(Self.self).deinit()")
    }
#endif
}

private extension AddNewWatchlistViewModel {
    func setupBindings() {
        self.watchlistsProvider.watchlists
            .sink { [weak self] watchlists in
                self?.watchlists = watchlists
            }
            .store(in: &store)
    }
}
