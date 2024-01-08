//
//  AddNewWatchlistViewModel.swift
//
//
//  Created by Jan Gulkowski on 06/01/2024.
//

import Foundation
import Combine
import StockAppLogic

public class AddNewWatchlistViewModel: ObservableObject {
    @Published public var error: String?
    @Published public var watchlistText: String = ""
    
    private let viewModel: StockAppLogic.AddNewWatchlistViewModel
    private var store = Set<AnyCancellable>()
    
    public init(
        coordinator: Coordinator,
        watchlistsProvider: WatchlistsProviding,
        emptyNameError: String = "Watchlist name can't be empty!",
        watchlistAlreadyExistsError: String = "Watchlist with this name already exists!"
    ) {
        self.viewModel = StockAppLogic.AddNewWatchlistViewModel(
            coordinator: coordinator,
            watchlistsProvider: watchlistsProvider,
            emptyNameError: emptyNameError,
            watchlistAlreadyExistsError: watchlistAlreadyExistsError
        )
        
        self.viewModel.errorPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] value in
                self?.error = value
            }
            .store(in: &store)
        
        self.viewModel.watchlistTextPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] value in
                self?.watchlistText = value
            }
            .store(in: &store)
    }
    
    public func onTextFieldFocused(initialText: String?) {
        viewModel.onTextFieldFocused(initialText: initialText)
    }
    
    public func onTextFieldSubmitted(text: String?) {
        viewModel.onTextFieldSubmitted(text: text)
    }
}
