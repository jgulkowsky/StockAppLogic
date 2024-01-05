//
//  QuoteViewModel.swift
//  StockApp
//
//  Created by Jan Gulkowski on 18/12/2023.
//

import Foundation
import Combine

public class QuoteViewModel: StatefulViewModel {
    public var titlePublisher: AnyPublisher<String, Never> {
        titleSubject
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
    
    public var chartDataPublisher: AnyPublisher<ChartData, Never> {
        chartDataSubject
            .eraseToAnyPublisher()
    }
    
    public var bidPricePublisher: AnyPublisher<String, Never> {
        bidPriceSubject
            .map { value in
                self.setupPricePublisherValue(
                    withPrefix: "Bid Price:",
                    andValue: value
                )
            }
            .eraseToAnyPublisher()
    }
    
    public var askPricePublisher: AnyPublisher<String, Never> {
        askPriceSubject
            .map { value in
                self.setupPricePublisherValue(
                    withPrefix: "Ask Price:",
                    andValue: value
                )
            }
            .eraseToAnyPublisher()
    }
    
    public var lastPricePublisher: AnyPublisher<String, Never> {
        lastPriceSubject
            .map { value in
                self.setupPricePublisherValue(
                    withPrefix: "Last Price:",
                    andValue: value
                )
            }
            .eraseToAnyPublisher()
    }
    
    private var stateSubject = CurrentValueSubject<State, Never>(.loading)
    private var errorSubject = CurrentValueSubject<String?, Never>(nil)
    
    private var titleSubject = CurrentValueSubject<String, Never>("")
    private var chartDataSubject = CurrentValueSubject<ChartData, Never>(ChartData(values: []))
    private var bidPriceSubject = CurrentValueSubject<Double?, Never>(nil)
    private var askPriceSubject = CurrentValueSubject<Double?, Never>(nil)
    private var lastPriceSubject = CurrentValueSubject<Double?, Never>(nil)
    
    private var timerCancellable: AnyCancellable?
    
    private unowned let coordinator: Coordinator
    private let quotesProvider: QuotesProviding
    private let chartDataProvider: ChartDataProviding
    private let symbol: String
    private let refreshRate: Double
    
    public init(
        coordinator: Coordinator,
        quotesProvider: QuotesProviding,
        chartDataProvider: ChartDataProviding,
        symbol: String,
        refreshRate: Double
    ) {
#if DEBUG
        print("@jgu: \(Self.self).init()")
#endif
        self.coordinator = coordinator
        self.quotesProvider = quotesProvider
        self.chartDataProvider = chartDataProvider
        self.symbol = symbol
        self.refreshRate = refreshRate
        
        super.init(
            stateSubject: stateSubject,
            errorSubject: errorSubject
        )
        
        self.titleSubject.send(self.symbol)
    }
    
#if DEBUG
    deinit {
        print("@jgu: \(Self.self).deinit()")
    }
#endif
    
    public func onViewWillAppear() {
        fetchData()
        turnOnTimer()
    }

    public func onViewWillDisappear() {
        turnOffTimer()
    }
    
    public func onErrorRefreshButtonTapped() {
        fetchData()
    }
}

private extension QuoteViewModel {
    func fetchData() {
        stateSubject.send(.loading)
        Task {
            do {
                async let getQuote = self.quotesProvider.getQuote(forSymbol: symbol)
                async let getChartData = self.chartDataProvider.getChartData(forSymbol: symbol)
                let (quote, chartData) = try await (getQuote, getChartData)
                bidPriceSubject.send(quote.bidPrice)
                askPriceSubject.send(quote.askPrice)
                lastPriceSubject.send(quote.lastPrice)
                chartDataSubject.send(chartData)
                stateSubject.send(.dataObtained)
            } catch {
                errorSubject.send("Unfortunatelly cannot fetch data in current moment.\n\nCheck your connection and try again.")
                stateSubject.send(.error)
            }
        }
    }

    func turnOnTimer() {
        timerCancellable = Timer.publish(every: self.refreshRate, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                Task { [weak self] in
                    guard let `self` = self,
                          self.stateSubject.value != .error else { return }
                    
                    let quote = try? await self.quotesProvider.getQuote(forSymbol: self.symbol)
                    self.bidPriceSubject.send(quote?.bidPrice)
                    self.askPriceSubject.send(quote?.askPrice)
                    self.lastPriceSubject.send(quote?.lastPrice)
                }
            }
    }
    
    func turnOffTimer() {
        timerCancellable = nil
    }
    
    func setupPricePublisherValue(
        withPrefix prefix: String,
        andValue value: Double?
    ) -> String {
        if let value = value {
            return "\(prefix) \(value.to2DecPlaces())"
        } else {
            return "\(prefix) -"
        }
    }
}
