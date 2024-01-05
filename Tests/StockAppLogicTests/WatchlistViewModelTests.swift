//
//  WatchlistViewModelTests.swift
//  StockAppLogicTests
//
//  Created by Jan Gulkowski on 03/01/2024.
//

import XCTest
import Combine
@testable import StockAppLogic

final class WatchlistViewModelTests: XCTestCase {
    private var store = Set<AnyCancellable>()
    private var viewModel: WatchlistViewModel?
    private var coordinator: MockCoordinator?
    private var watchlistsProvider: MockWatchlistsProvider?
    private var quotesProvider: MockQuotesProvider?
    
    override func tearDown() {
        self.coordinator = nil
        self.watchlistsProvider = nil
        self.quotesProvider = nil
        self.viewModel = nil
        self.store.removeAll()
    }
    
    func test_whenViewModelIsInitialized_thenStatePublisherShouldEmitValueOfLoading() throws {
        // given
        
        // when
        setupVariables()
        
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
    
    func test_givenThatWatchlistsProviderAlreadyContainsWatchlist_whenViewModelIsInitializedWithWatchlist_thenTitlePublisherShouldEmitTitleEqualToWatchlistName() throws {
        // given
        let watchlist = Watchlist(id: UUID(), name: "watchlist 2", symbols: ["symbol 4", "symbol 5", "symbol 6"])
        let watchlists = [
            Watchlist(id: UUID(), name: "watchlist 1", symbols: ["symbol 1", "symbol 2"]),
            watchlist,
            Watchlist(id: UUID(), name: "watchlist 3", symbols: ["symbol 7"])
        ]
        
        // when
        setupVariables(
            watchlist: watchlist,
            watchlistsToReturn: watchlists
        )
        
        // then
        let expectation = XCTestExpectation(description: UUID().description)
        self.viewModel!.titlePublisher
            .sink { title in
                expectation.fulfill()
                XCTAssertEqual(title, watchlist.name)
            }
            .store(in: &store)
        wait(for: [expectation], timeout: 0.1)
    }
    
    func test_givenThatWatchlistsProviderAlreadyContainsWatchlist_whenViewModelIsInitializedWithWatchlist_thenQuotesProviderGetQuoteIsCalledForEverySymbolFromTheWatchlist() throws {
        // given
        let symbols = ["symbol 4", "symbol 5", "symbol 6"]
        let watchlist = Watchlist(id: UUID(), name: "watchlist 2", symbols: symbols)
        let watchlists = [
            Watchlist(id: UUID(), name: "watchlist 1", symbols: ["symbol 1", "symbol 2"]),
            watchlist,
            Watchlist(id: UUID(), name: "watchlist 3", symbols: ["symbol 7"])
        ]
        
        // when
        setupVariables(
            watchlist: watchlist,
            watchlistsToReturn: watchlists
        )
        wait(for: 0.1)
        
        // then
        XCTAssertEqual(self.quotesProvider!.getQuoteForSymbolCallsCounter, symbols.count)
    }
    
    func test_givenThatWatchlistsProviderAlreadyContainsWatchlist_andThatQuotesProviderDoesNotThrowErrors_whenViewModelIsInitializedWithWatchlist_thenStockItemsPublisherShouldPublishStockItemsContainingSymbolsAndTheirQuotes_andStatePublisherShouldPublishDataObtainedState() throws {
        // given
        let symbols = ["symbol 4", "symbol 5", "symbol 6"]
        let watchlist = Watchlist(id: UUID(), name: "watchlist 2", symbols: symbols)
        let watchlists = [
            Watchlist(id: UUID(), name: "watchlist 1", symbols: ["symbol 1", "symbol 2"]),
            watchlist,
            Watchlist(id: UUID(), name: "watchlist 3", symbols: ["symbol 7"])
        ]
        let quote = Quote(date: Date(), bidPrice: 100.01, askPrice: 100.02, lastPrice: 100.03)
        let expectedStockItems = symbols.map { StockItem(symbol: $0, quote: quote) }
        
        // when
        setupVariables(
            watchlist: watchlist,
            quotesProviderThrows: false,
            watchlistsToReturn: watchlists,
            quoteToReturn: quote
        )
        
        // then
        let expectationStockItems = XCTestExpectation(description: UUID().description)
        self.viewModel!.stockItemsPublisher
            .filter { !$0.isEmpty }
            .sink { stockItems in
                expectationStockItems.fulfill()
                XCTAssertEqual(stockItems, expectedStockItems)
            }
            .store(in: &store)
        
        let expectationState = XCTestExpectation(description: UUID().description)
        self.viewModel!.statePublisher
            .filter { $0 == .dataObtained }
            .sink { _ in
                expectationState.fulfill()
            }
            .store(in: &store)
        
        wait(for: [expectationStockItems, expectationState], timeout: 0.1)
    }
    
    func test_givenThatWatchlistsProviderAlreadyContainsWatchlist_andThatQuotesProviderThrowsErrors_whenViewModelIsInitializedWithWatchlist_thenStockItemsPublisherShouldPublishStockItemsContainingSymbolsAndNilQuotes_andStatePublisherShouldPublishDataObtainedState() throws {
        // given
        let symbols = ["symbol 4", "symbol 5", "symbol 6"]
        let watchlist = Watchlist(id: UUID(), name: "watchlist 2", symbols: symbols)
        let watchlists = [
            Watchlist(id: UUID(), name: "watchlist 1", symbols: ["symbol 1", "symbol 2"]),
            watchlist,
            Watchlist(id: UUID(), name: "watchlist 3", symbols: ["symbol 7"])
        ]
        let expectedStockItems = symbols.map { StockItem(symbol: $0, quote: nil) }
        
        // when
        setupVariables(
            watchlist: watchlist,
            quotesProviderThrows: true,
            watchlistsToReturn: watchlists
        )
        
        // then
        let expectationStockItems = XCTestExpectation(description: UUID().description)
        self.viewModel!.stockItemsPublisher
            .filter { !$0.isEmpty }
            .sink { stockItems in
                expectationStockItems.fulfill()
                XCTAssertEqual(stockItems, expectedStockItems)
            }
            .store(in: &store)
        
        let expectationState = XCTestExpectation(description: UUID().description)
        self.viewModel!.statePublisher
            .filter { $0 == .dataObtained }
            .sink { _ in
                expectationState.fulfill()
            }
            .store(in: &store)
        
        wait(for: [expectationStockItems, expectationState], timeout: 0.1)
    }
    
    func test_givenThatQuotesProviderReturnsDifferentValues_whenOnViewWillAppear_thenStockItemsPublisherPublishesRegularly() throws {
        // given
        // quotes provider returns different values on default
        setupVariables(
            rate: 0.1
        )
        
        // when
        self.viewModel!.onViewWillAppear()
        
        // then
        let expectation = XCTestExpectation(description: UUID().description)
        self.viewModel!.stockItemsPublisher
            .filter { !$0.isEmpty }
            .dropFirst(3) // this is a proof there're regular updates
            .sink { stockItems in
                expectation.fulfill()
            }
            .store(in: &store)
        wait(for: [expectation], timeout: 0.5)
    }
    
    func test_givenThatStockItemsPublisherPublishesRegularly_whenOnViewWillDisappear_thenStockItemsPublisherStopsPublishingRegularly() throws {
        // given
        // quotes provider returns different values on default
        setupVariables(
            rate: 0.1
        )
        
        self.viewModel!.onViewWillAppear()
        
        var counter = 0
        self.viewModel!.stockItemsPublisher
            .filter { !$0.isEmpty }
            .sink { _ in
                counter += 1
            }
            .store(in: &store)
        
        wait(for: 0.5)
        let savedState = counter
        
        // when
        self.viewModel!.onViewWillDisappear()
        
        // then
        wait(for: 0.5)
        let currentState = counter
        XCTAssertEqual(currentState, savedState) // which means there were no more updates form publisher since onViewWillDisappear
    }
    
    func test_givenThatIndexIsSmallerThanNumberOfStockItemsReturned_whenGetStockItemForIndex_thenStockItemRelatedToIndexIsReturned() throws {
        // given
        let (index, numberOfItems) = getIndexAndNumberOfItems_whereIndexIsSmallerThanNumberOfItems()
        let expectedStockItems = makeSureThatStockItemsAreSetInViewModel(numberOfItems: numberOfItems)
        let expectedStockItem = expectedStockItems[index]
        
        // when
        let stockItem = self.viewModel!.getStockItemFor(index: index)
        
        // then
        XCTAssertEqual(stockItem, expectedStockItem)
    }
    
    func test_givenThatIndexIsGreaterThanOrEqualToNumberOfStockItemsReturned_whenGetStockItemForIndex_thenNilIsReturned() throws {
        // given
        let (index, numberOfItems) = getIndexAndNumberOfItems_whereIndexIsGreaterThanOrEqualToNumberOfItems()
        _ = makeSureThatStockItemsAreSetInViewModel(numberOfItems: numberOfItems)
        
        // when
        let stockItem = self.viewModel!.getStockItemFor(index: index)
        
        // then
        XCTAssertNil(stockItem)
    }
    
    func test_givenThatIndexIsSmallerThanNumberOfStockItemsReturned_whenOnItemTappedForIndex_thenCoordinatorExecutesActionOfItemSelectedWithStockItemRelatedToIndex() throws {
        // given
        let (index, numberOfItems) = getIndexAndNumberOfItems_whereIndexIsSmallerThanNumberOfItems()
        let stockItems = makeSureThatStockItemsAreSetInViewModel(numberOfItems: numberOfItems)
        let stockItem = stockItems[index]
        
        // when
        self.viewModel!.onItemTapped(at: index)
        
        // then
        XCTAssertTrue(self.coordinator!.executeActionCalled)
        switch self.coordinator!.executeAction {
        case .itemSelected(let data):
            XCTAssertEqual(data as! StockItem, stockItem)
        default:
            XCTFail()
        }
    }
    
    func test_givenThatIndexIsGreaterThanOrEqualToNumberOfStockItemsReturned_whenOnItemTappedForIndex_thenCoordinatorDoesNotExecuteAnyAction() throws {
        // given
        let (index, numberOfItems) = getIndexAndNumberOfItems_whereIndexIsGreaterThanOrEqualToNumberOfItems()
        _ = makeSureThatStockItemsAreSetInViewModel(numberOfItems: numberOfItems)
        
        // when
        self.viewModel!.onItemTapped(at: index)
        
        // then
        XCTAssertFalse(self.coordinator!.executeActionCalled)
    }

    func test_whenOnAddButtonTapped_thenCoordinatorExecutesActionAddButtonTappedWithWatchlist() throws {
        // given
        let watchlist = Watchlist(id: UUID(), name: "watchlist 1", symbols: [])
        setupVariables(
            watchlist: watchlist
        )
        
        // when
        self.viewModel!.onAddButtonTapped()
        
        // then
        XCTAssertTrue(self.coordinator!.executeActionCalled)
        switch self.coordinator!.executeAction {
        case .addButtonTapped(let data):
            XCTAssertEqual(data as! Watchlist, watchlist)
        default:
            XCTFail()
        }
    }
    
    func test_givenThatIndexIsSmallerThanNumberOfStockItemsReturned_whenOnItemSwipedOut_thenWatchlistsProviderOnRemoveSymbolFromWatchlistIsCalled() throws {
        // given
        let watchlist = Watchlist(id: UUID(), name: "watchlist 1", symbols: [])
        let (index, numberOfItems) = getIndexAndNumberOfItems_whereIndexIsSmallerThanNumberOfItems()
        let stockItems = makeSureThatStockItemsAreSetInViewModel(
            numberOfItems: numberOfItems,
            watchlist: watchlist
        )
        let stockItem = stockItems[index]
        
        // when
        self.viewModel!.onItemSwipedOut(at: index)
        
        // then
        XCTAssertTrue(self.watchlistsProvider!.onRemoveSymbolCalled)
        XCTAssertEqual(self.watchlistsProvider!.onRemoveSymbolSymbol, stockItem.symbol)
        XCTAssertEqual(self.watchlistsProvider!.onRemoveSymbolWatchlist!.id, watchlist.id)
    }
    
    func test_givenThatIndexIsGreaterThanOrEqualToNumberOfStockItemsReturned_whenOnItemSwipedOut_thenWatchlistsProviderOnRemoveSymbolFromWatchlistIsNotCalled() throws {
        // given
        let (index, numberOfItems) = getIndexAndNumberOfItems_whereIndexIsGreaterThanOrEqualToNumberOfItems()
        _ = makeSureThatStockItemsAreSetInViewModel(
            numberOfItems: numberOfItems
        )
        
        // when
        self.viewModel!.onItemSwipedOut(at: index)
        
        // then
        XCTAssertFalse(self.watchlistsProvider!.onRemoveSymbolCalled)
    }
}

private extension WatchlistViewModelTests {
    func setupVariables(
        watchlist: Watchlist = Watchlist(id: UUID(), name: "watchlist", symbols: ["some symbol", "some other"]),
        rate: Double = 5,
        quotesProviderThrows: Bool = false,
        watchlistsToReturn: [Watchlist]? = nil,
        quoteToReturn: Quote? = nil
    ) {
        self.coordinator = MockCoordinator()
 
        self.watchlistsProvider = MockWatchlistsProvider()
        if let watchlistsToReturn = watchlistsToReturn {
            self.watchlistsProvider!.setupWatchlists(with: watchlistsToReturn)
        }
        
        self.quotesProvider = MockQuotesProvider()
        self.quotesProvider!.quoteToReturn = quoteToReturn
        self.quotesProvider!.shouldThrow = quotesProviderThrows
 
        self.viewModel = WatchlistViewModel(
            coordinator: self.coordinator!,
            watchlistsProvider: self.watchlistsProvider!,
            quotesProvider: self.quotesProvider!,
            watchlist: watchlist,
            refreshRate: rate
        )
    }
    
    func makeSureThatStockItemsAreSetInViewModel(
        numberOfItems: Int,
        watchlist: Watchlist = Watchlist(id: UUID(), name: "watchlist 1", symbols: [])
    ) -> [StockItem] {
        let symbols = (0..<numberOfItems).map { "symbol \($0)" }
        var watchlist = watchlist
        watchlist.symbols = symbols
        let watchlists = [watchlist]
        let quote = Quote(date: Date(), bidPrice: 12.12, askPrice: 13.13, lastPrice: 14.14)
        setupVariables(
            watchlist: watchlist,
            watchlistsToReturn: watchlists,
            quoteToReturn: quote
        )
        wait(for: 0.1) // waiting to have stock items
        let stockItems = symbols.map { StockItem(symbol: $0, quote: quote) }
        return stockItems
    }
}
