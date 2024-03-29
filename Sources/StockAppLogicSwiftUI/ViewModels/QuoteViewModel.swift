//
//  QuoteViewModel.swift
//
//
//  Created by Jan Gulkowski on 06/01/2024.
//

import Foundation
import Combine
import StockAppLogic

public class QuoteViewModel: ObservableObject {
    @Published public var state: StatefulViewModel.State = .loading
    @Published public var error: String?
    @Published public var title: String = ""
    @Published public var chartData: ChartData = ChartData(values: [])
    @Published public var bidPrice: String = ""
    @Published public var askPrice: String = ""
    @Published public var lastPrice: String = ""
    
    private let viewModel: StockAppLogic.QuoteViewModel
    private var store = Set<AnyCancellable>()
    
    public init(
        coordinator: Coordinator,
        quotesProvider: QuotesProviding,
        chartDataProvider: ChartDataProviding,
        symbol: String,
        refreshRate: Double
    ) {
        self.viewModel = StockAppLogic.QuoteViewModel(
            coordinator: coordinator,
            quotesProvider: quotesProvider,
            chartDataProvider: chartDataProvider,
            symbol: symbol,
            refreshRate: refreshRate
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
        
        self.viewModel.titlePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] value in
                self?.title = value
            }
            .store(in: &store)
        
        self.viewModel.chartDataPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] value in
                self?.chartData = value
            }
            .store(in: &store)
        
        self.viewModel.bidPricePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] value in
                self?.bidPrice = value
            }
            .store(in: &store)
        
        self.viewModel.askPricePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] value in
                self?.askPrice = value
            }
            .store(in: &store)
        
        self.viewModel.lastPricePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] value in
                self?.lastPrice = value
            }
            .store(in: &store)
    }
    
    public func onViewWillAppear() {
        viewModel.onViewWillAppear()
    }

    public func onViewWillDisappear() {
        viewModel.onViewWillDisappear()
    }
    
    public func onErrorRefreshButtonTapped() {
        viewModel.onErrorRefreshButtonTapped()
    }
}
