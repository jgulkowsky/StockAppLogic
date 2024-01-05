//
//  QuoteViewModelTests.swift
//  StockAppTests
//
//  Created by Jan Gulkowski on 03/01/2024.
//

import XCTest
import Combine
@testable import StockAppLogic

final class QuoteViewModelTests: XCTestCase {
    private var store = Set<AnyCancellable>()
    private var viewModel: QuoteViewModel?
    private var coordinator: MockCoordinator?
    private var quotesProvider: MockQuotesProvider?
    private var chartDataProvider: MockChartDataProvider?
    
    override func tearDown() {
        self.coordinator = nil
        self.quotesProvider = nil
        self.chartDataProvider = nil
        self.viewModel = nil
        self.store.removeAll()
    }
    
    func test_whenViewModelIsInitializedWithSymbol_thenTitlePublisherShouldEmitTitleEqualToSymbol() throws {
        // given
        let symbol = "some symbol"
        
        // when
        setupVariables(symbol: symbol)
        
        // then
        let expectation = XCTestExpectation(description: UUID().description)
        self.viewModel!.titlePublisher
            .sink { title in
                expectation.fulfill()
                XCTAssertEqual(title, symbol)
            }
            .store(in: &store)
        wait(for: [expectation], timeout: 0.1)
    }
    
    func test_whenOnViewWillAppearIsCalled_thenStatePublisherShouldEmitValueOfLoading() throws {
        // given
        setupVariables()
        
        // when
        self.viewModel!.onViewWillAppear()
        
        // then
        let expectation = XCTestExpectation(description: UUID().description)
        self.viewModel!.statePublisher
            .sink { state in
                expectation.fulfill()
                XCTAssertEqual(state, .loading)
            }
            .store(in: &store)
        wait(for: [expectation], timeout: 0.1)
    }
    
    func test_givenSymbolIsSetDuringInit_whenOnViewWillAppearIsCalled_thenQuotesProviderGetQuoteIsCalledForSymbol() throws {
        // given
        let symbol = "some symbol"
        setupVariables(symbol: symbol)
        
        // when
        self.viewModel!.onViewWillAppear()
        wait(for: 0.1)
        
        // then
        XCTAssertTrue(self.quotesProvider!.getQuoteForSymbolCalled)
        XCTAssertEqual(self.quotesProvider!.getQuoteForSymbolSymbol, symbol)
    }
    
    func test_givenSymbolIsSetDuringInit_whenOnViewWillAppearIsCalled_thenChartDataProviderGetChartDataIsCalledForSymbol() throws {
        // given
        let symbol = "some symbol"
        setupVariables(symbol: symbol)
        
        // when
        self.viewModel!.onViewWillAppear()
        wait(for: 0.1)
        
        // then
        XCTAssertTrue(self.chartDataProvider!.getChartDataForSymbolCalled)
        XCTAssertEqual(self.chartDataProvider!.getChartDataForSymbolSymbol, symbol)
    }
    
    func test_givenQuotesProviderThrowsError_whenOnViewWillAppearIsCalled_thenStatePublisherShouldEmitValueOfError() throws {
        // given
        setupVariables(quotesProviderThrows: true)
        
        // when
        self.viewModel!.onViewWillAppear()
        
        // then
        let expectation = XCTestExpectation(description: UUID().description)
        self.viewModel!.statePublisher
            .filter { $0 == .error }
            .sink { state in
                expectation.fulfill()
            }
            .store(in: &store)
        wait(for: [expectation], timeout: 0.1)
    }
    
    func test_givenChartDataProviderThrowsError_whenOnViewWillAppearIsCalled_thenStatePublisherShouldEmitValueOfError() throws {
        // given
        setupVariables(chartDataProviderThrows: true)
        
        // when
        self.viewModel!.onViewWillAppear()
        
        // then
        let expectation = XCTestExpectation(description: UUID().description)
        self.viewModel!.statePublisher
            .filter { $0 == .error }
            .sink { state in
                expectation.fulfill()
            }
            .store(in: &store)
        wait(for: [expectation], timeout: 0.1)
    }
    
    func test_givenBothQuotesProviderAndChartDataProviderDoNotThrowAnyErrors_whenOnViewWillAppearIsCalled_thenStatePublisherShouldEmitValueOfDataObtained() throws {
        // given
        setupVariables(
            quotesProviderThrows: false,
            chartDataProviderThrows: false
        )
        
        // when
        self.viewModel!.onViewWillAppear()
        
        // then
        let expectation = XCTestExpectation(description: UUID().description)
        self.viewModel!.statePublisher
            .filter { $0 == .dataObtained }
            .sink { state in
                expectation.fulfill()
            }
            .store(in: &store)
        wait(for: [expectation], timeout: 0.1)
    }
    
    func test_givenBothQuotesProviderAndChartDataProviderDoNotThrowAnyErrors_whenOnViewWillAppearIsCalled_thenPricesPublishersShouldEmitValuesProvidedByQuotesProvider() throws {
        // given
        let quote = Quote(date: Date(), bidPrice: 12.12, askPrice: 13.13, lastPrice: 14.14)
        setupVariables(
            quotesProviderThrows: false,
            chartDataProviderThrows: false,
            quoteToReturn: quote
        )
        
        // when
        self.viewModel!.onViewWillAppear()
        
        // then
        let expectationBidPrice = XCTestExpectation(description: UUID().description)
        self.viewModel!.bidPricePublisher
            .filter { $0 != "Bid Price: -" }
            .sink { value in
                expectationBidPrice.fulfill()
                XCTAssertEqual(value, "Bid Price: 12.12")
            }
            .store(in: &store)
        
        let expectationAskPrice = XCTestExpectation(description: UUID().description)
        self.viewModel!.askPricePublisher
            .filter { $0 != "Ask Price: -" }
            .sink { value in
                expectationAskPrice.fulfill()
                XCTAssertEqual(value, "Ask Price: 13.13")
            }
            .store(in: &store)
        
        let expectationLastPrice = XCTestExpectation(description: UUID().description)
        self.viewModel!.lastPricePublisher
            .filter { $0 != "Last Price: -" }
            .sink { value in
                expectationLastPrice.fulfill()
                XCTAssertEqual(value, "Last Price: 14.14")
            }
            .store(in: &store)
        
        wait(for: [expectationBidPrice, expectationAskPrice, expectationLastPrice], timeout: 0.1)
    }
    
    func test_givenBothQuotesProviderAndChartDataProviderDoNotThrowAnyErrors_whenOnViewWillAppearIsCalled_thenChartDataPublisherShouldEmitValueProvidedByChartDataProvider() throws {
        // given
        let chartDataFromProvider = ChartData(
            values: [
                ChartItem(close: 100.1, high: 100.3, low: 100.0, open: 100.2, date: Date())
            ]
        )
        setupVariables(
            quotesProviderThrows: false,
            chartDataProviderThrows: false,
            chartDataToReturn: chartDataFromProvider
        )
        
        // when
        self.viewModel!.onViewWillAppear()
        
        // then
        let expectation = XCTestExpectation(description: UUID().description)
        self.viewModel!.chartDataPublisher
            .sink { chartData in
                expectation.fulfill()
                XCTAssertEqual(chartData, chartDataFromProvider)
            }
            .store(in: &store)
        wait(for: [expectation], timeout: 0.1)
    }
    
    func test_givenBothQuotesProviderAndChartDataProviderDoNotThrowAnyErrors_whenOnViewWillAppearIsCalled_thenQuotesProviderGetQuoteStartsBeingCalledForSymbolPassedOnInitRegularly_andTheRegularitySpecifiedByRatePassedDuringInit() throws {
        // given
        let symbol = "some symbol"
        setupVariables(
            symbol: symbol,
            rate: 0.1,
            quotesProviderThrows: false,
            chartDataProviderThrows: false
        )
        
        // when
        self.viewModel!.onViewWillAppear()
        wait(for: 0.3)
        
        // then
        XCTAssertTrue(self.quotesProvider!.getQuoteForSymbolCallsCounter > 1)
        XCTAssertEqual(self.quotesProvider!.getQuoteForSymbolSymbol, symbol)
    }
    
    func test_givenBothQuotesProviderAndChartDataProviderDoNotThrowAnyErrors_whenOnViewWillAppearIsCalled_thenPricesPublishersShouldStartEmittingRegularValuesSpecifiedByRatePassedDuringInit() throws {
        // given
        setupVariables(
            rate: 0.1,
            quotesProviderThrows: false,
            chartDataProviderThrows: false
        )
        
        // when
        self.viewModel!.onViewWillAppear()
        
        // then
        let expectationBidPrice = XCTestExpectation(description: UUID().description)
        self.viewModel!.bidPricePublisher
            .filter { $0 != "Bid Price: -" }
            .dropFirst(3) // this is a proof that publisher has emitted for several times
            .sink { value in
                expectationBidPrice.fulfill()
            }
            .store(in: &store)
        
        let expectationAskPrice = XCTestExpectation(description: UUID().description)
        self.viewModel!.askPricePublisher
            .filter { $0 != "Ask Price: -" }
            .dropFirst(3) // this is a proof that publisher has emitted for several times
            .sink { value in
                expectationAskPrice.fulfill()
            }
            .store(in: &store)
        
        let expectationLastPrice = XCTestExpectation(description: UUID().description)
        self.viewModel!.lastPricePublisher
            .filter { $0 != "Last Price: -" }
            .dropFirst(3) // this is a proof that publisher has emitted for several times
            .sink { value in
                expectationLastPrice.fulfill()
            }
            .store(in: &store)
        wait(for: [expectationLastPrice], timeout: 1)
    }
    
    func test_givenPricesPublishersAreEmittingRegularValuesAfterOnViewWillAppearWasCalled_whenOnViewWillDisappearIsCalled_thenPricesPublishersShouldStopToEmitTheseValues() throws {
        // given
        setupVariables(
            rate: 0.1,
            quotesProviderThrows: false,
            chartDataProviderThrows: false
        )
        
        self.viewModel!.onViewWillAppear()
        
        var bidPricePublisherEmitCounter = 0
        self.viewModel!.bidPricePublisher
            .filter { $0 != "Bid Price: -" }
            .sink { value in
                bidPricePublisherEmitCounter += 1
            }
            .store(in: &store)
        
        var askPricePublisherEmitCounter = 0
        self.viewModel!.askPricePublisher
            .filter { $0 != "Ask Price: -" }
            .sink { value in
                askPricePublisherEmitCounter += 1
            }
            .store(in: &store)
        
        var lastPricePublisherEmitCounter = 0
        self.viewModel!.lastPricePublisher
            .filter { $0 != "Last Price: -" }
            .sink { value in
                lastPricePublisherEmitCounter += 1
            }
            .store(in: &store)
        
        wait(for: 0.5)
        let savedState = [bidPricePublisherEmitCounter, askPricePublisherEmitCounter, lastPricePublisherEmitCounter]
        
        // when
        self.viewModel!.onViewWillDisappear()
        
        // then
        wait(for: 0.5)
        let currentState = [bidPricePublisherEmitCounter, askPricePublisherEmitCounter, lastPricePublisherEmitCounter]
        XCTAssertEqual(currentState, savedState) // which means there were no more updates from publishers since onViewWillDisappear
    }
    
    func test_whenOnErrorRefreshButtonTappedIsCalled_thenStatePublisherShouldEmitValueOfLoading() throws {
        // given
        setupVariables()
        
        // when
        self.viewModel!.onErrorRefreshButtonTapped()
        
        // then
        let expectation = XCTestExpectation(description: UUID().description)
        self.viewModel!.statePublisher
            .sink { state in
                expectation.fulfill()
                XCTAssertEqual(state, .loading)
            }
            .store(in: &store)
        wait(for: [expectation], timeout: 0.1)
    }
    
    func test_whenOnErrorRefreshButtonTappedIsCalled_thenQuotesProviderGetQuoteIsCalledForSymbol() throws {
        // given
        let symbol = "some symbol"
        setupVariables(symbol: symbol)
        
        // when
        self.viewModel!.onErrorRefreshButtonTapped()
        wait(for: 0.1)
        
        // then
        XCTAssertTrue(self.quotesProvider!.getQuoteForSymbolCalled)
        XCTAssertEqual(self.quotesProvider!.getQuoteForSymbolSymbol, symbol)
    }
    
    func test_whenOnErrorRefreshButtonTappedIsCalled_thenChartDataProviderGetChartDataIsCalledForSymbol() throws {
        // given
        let symbol = "some symbol"
        setupVariables(symbol: symbol)
        
        // when
        self.viewModel!.onErrorRefreshButtonTapped()
        wait(for: 0.1)
        
        // then
        XCTAssertTrue(self.chartDataProvider!.getChartDataForSymbolCalled)
        XCTAssertEqual(self.chartDataProvider!.getChartDataForSymbolSymbol, symbol)
    }
}

private extension QuoteViewModelTests {
    func setupVariables(
        symbol: String = "symbol",
        rate: Double = 5,
        quotesProviderThrows: Bool = false,
        chartDataProviderThrows: Bool = false,
        quoteToReturn: Quote = Quote(date: Date(), bidPrice: 100.01, askPrice: 100.02, lastPrice: 100.03),
        chartDataToReturn: ChartData? = nil
    ) {
        self.coordinator = MockCoordinator()
        
        self.quotesProvider = MockQuotesProvider()
        self.quotesProvider!.quoteToReturn = quoteToReturn
        self.quotesProvider!.shouldThrow = quotesProviderThrows
        
        self.chartDataProvider = MockChartDataProvider()
        self.chartDataProvider!.shouldThrow = chartDataProviderThrows
        self.chartDataProvider!.chartDataToReturn = chartDataToReturn
        
        self.viewModel = QuoteViewModel(
            coordinator: self.coordinator!,
            quotesProvider: self.quotesProvider!,
            chartDataProvider: self.chartDataProvider!,
            symbol: symbol,
            refreshRate: rate
        )
    }
}
