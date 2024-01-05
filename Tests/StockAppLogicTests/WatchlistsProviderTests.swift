//
//  WatchlistsProviderTests.swift
//  StockAppLogicTests
//
//  Created by Jan Gulkowski on 04/01/2024.
//

import XCTest
import Combine
@testable import StockAppLogic

final class WatchlistsProviderTests: XCTestCase {
    private var store = Set<AnyCancellable>()
    private var provider: WatchlistsProvider?
    private var coreDataProvider: MockWatchlistsCoreDataProvider?
    private var appFirstStartProvider: MockAppFirstStartProvider?
    
    private static let initialList = Watchlist(id: UUID(), name: "My First List", symbols: ["AAPL", "GOOG", "MSFT"])
    
    override func tearDown() {
        self.coreDataProvider = nil
        self.appFirstStartProvider = nil
        self.provider = nil
        self.store.removeAll()
    }
    
    func test_givenCoreDataProviderReturnsEmptyListOfWatchlists_andThatAppFirstStartProviderSaysItIsFirstAppStart_whenWatchlistsProviderIsInitialized_thenWatchlistsPublisherPublishesTheInitialList_andCoreDataProviderAddWatchlistIsCalledWithTheInitialList() throws {
        // given
        let initialList = Watchlist(
            id: UUID(),
            name: "some list",
            symbols: ["symbol 1", "symbol 2", "symbol 3"]
        )
        
        setupProviders(
            watchlistsToReturn: [],
            isFirstAppStart: true
        )
        
        // when
        self.provider = WatchlistsProvider(
            coreDataProvider: self.coreDataProvider!,
            appFirstStartProvider: self.appFirstStartProvider!,
            initialList: initialList
        )
        
        // then
        let expectation = XCTestExpectation(description: UUID().description)
        self.provider!.watchlists
            .sink { watchlists in
                XCTAssertEqual(watchlists, [initialList])
                expectation.fulfill()
            }
            .store(in: &store)
        wait(for: [expectation], timeout: 0.1)
        
        // and
        XCTAssertTrue(self.coreDataProvider!.addWatchlistCalled)
        XCTAssertEqual(self.coreDataProvider!.addWatchlistWatchlist, initialList)
    }
    
    func test_givenCoreDataProviderReturnsNonEmptyListOfWatchlists_andThatAppFirstStartProviderSaysItIsFirstAppStart_whenWatchlistsProviderIsInitialized_thenWatchlistsPublisherPublishesTheListFromCoreData_andCoreDataProviderAddWatchlistIsNotCalled() throws {
        // given
        let coreDataList = [
            Watchlist(id: UUID(), name: "some other list", symbols: []),
            Watchlist(id: UUID(), name: "some other list 2", symbols: ["some symbol 1", "some symbol 2"])
        ]
        
        setupProviders(
            watchlistsToReturn: coreDataList,
            isFirstAppStart: true
        )
        
        // when
        self.provider = WatchlistsProvider(
            coreDataProvider: self.coreDataProvider!,
            appFirstStartProvider: self.appFirstStartProvider!,
            initialList: Self.initialList
        )
        
        // then
        let expectation = XCTestExpectation(description: UUID().description)
        self.provider!.watchlists
            .sink { watchlists in
                XCTAssertEqual(watchlists, coreDataList)
                expectation.fulfill()
            }
            .store(in: &store)
        wait(for: [expectation], timeout: 0.1)
        
        // and
        XCTAssertFalse(self.coreDataProvider!.addWatchlistCalled)
    }
    
    func test_givenCoreDataProviderReturnsEmptyListOfWatchlists_andThatAppFirstStartProviderSaysItIsNotTheFirstAppStart_whenWatchlistsProviderIsInitialized_thenWatchlistsPublisherPublishesEmptyList_andCoreDataProviderAddWatchlistIsNotCalled() throws {
        // given
        setupProviders(
            watchlistsToReturn: [],
            isFirstAppStart: false
        )
        
        // when
        self.provider = WatchlistsProvider(
            coreDataProvider: self.coreDataProvider!,
            appFirstStartProvider: self.appFirstStartProvider!,
            initialList: Self.initialList
        )
        
        // then
        let expectation = XCTestExpectation(description: UUID().description)
        self.provider!.watchlists
            .sink { watchlists in
                XCTAssertEqual(watchlists, [])
                expectation.fulfill()
            }
            .store(in: &store)
        wait(for: [expectation], timeout: 0.1)
        
        // and
        XCTAssertFalse(self.coreDataProvider!.addWatchlistCalled)
    }
    
    func test_givenWatchlistsProviderIsInitialized_whenWatchlistsProviderOnAddIsCalledWithWatchlist_thenWatchlistsPublisherPublishesListContainingThisWatchlist_andCoreDataProviderAddWatchlistIsCalledWithThisWatchlist() throws {
        // given
        setupProviders()
        
        self.provider = WatchlistsProvider(
            coreDataProvider: self.coreDataProvider!,
            appFirstStartProvider: self.appFirstStartProvider!,
            initialList: Self.initialList
        )
        
        let watchlist = Watchlist(id: UUID(), name: "new watchlist", symbols: ["new symbol"])
        let expectation = XCTestExpectation(description: UUID().description)
        self.provider!.watchlists
            .filter { $0.contains(watchlist) }
            .sink { watchlists in
                expectation.fulfill()
            }
            .store(in: &store)
        
        // when
        self.provider!.onAdd(watchlist)
        
        // then
        wait(for: [expectation], timeout: 0.1) // which means that WatchlistsPublisher published list containing the watchlist
        
        // and
        XCTAssertTrue(self.coreDataProvider!.addWatchlistCalled)
        XCTAssertEqual(self.coreDataProvider!.addWatchlistWatchlist, watchlist)
    }
    
    func test_givenWatchlistsProviderIsInitialized_whenWatchlistsProviderOnRemoveIsCalledWithWatchlist_andWatchlistIsContainedInWatchlistsPublisher_thenWatchlistsPublisherPublishesListReducedByThisWatchlist_andCoreDataProviderDeleteWatchlistIsCalledWithThisWatchlist() throws {
        // given
        let watchlist = Watchlist(id: UUID(), name: "a watchlist", symbols: ["a symbol"])
        let otherList = Watchlist(id: UUID(), name: "some other watchlist", symbols: ["some other symbol"])
        let watchlists = [watchlist, otherList]
        setupProviders(watchlistsToReturn: watchlists)
        
        self.provider = WatchlistsProvider(
            coreDataProvider: self.coreDataProvider!,
            appFirstStartProvider: self.appFirstStartProvider!,
            initialList: Self.initialList
        )
        
        let expectation = XCTestExpectation(description: UUID().description)
        self.provider!.watchlists
            .filter { $0.count == 1 } // at init we have 2 items then we remove one and we have 1
            .sink { watchlists in
                XCTAssertEqual(watchlists.first!, otherList)
                expectation.fulfill()
            }
            .store(in: &store)
        
        // when
        self.provider!.onRemove(watchlist)
        
        // then
        wait(for: [expectation], timeout: 0.1) // which means that WatchlistsPublisher published list reduced by the watchlist
        
        // and
        XCTAssertTrue(self.coreDataProvider!.deleteWatchlistCalled)
        XCTAssertEqual(self.coreDataProvider!.deleteWatchlistWatchlist, watchlist)
    }
    
    func test_givenWatchlistsProviderIsInitialized_whenWatchlistsProviderOnRemoveIsCalledWithWatchlist_andWatchlistIsNotContainedInWatchlistsPublisher_thenWatchlistsPublisherDoesNotPublishListReducedByThisWatchlist_andCoreDataProviderDeleteWatchlistIsNotCalledWithThisWatchlist() throws {
        // given
        let watchlist = Watchlist(id: UUID(), name: "a watchlist", symbols: ["a symbol"])
        let otherList = Watchlist(id: UUID(), name: "some other watchlist", symbols: ["some other symbol"])
        let watchlists = [watchlist, otherList]
        setupProviders(watchlistsToReturn: watchlists)
        
        self.provider = WatchlistsProvider(
            coreDataProvider: self.coreDataProvider!,
            appFirstStartProvider: self.appFirstStartProvider!,
            initialList: Self.initialList
        )
        
        let expectation = XCTestExpectation(description: UUID().description)
        expectation.isInverted = true
        self.provider!.watchlists
            .filter { $0.count == 1 } // at init we have 2 items and as we don't remove anything this should stay
            .sink { watchlists in
                expectation.fulfill()
            }
            .store(in: &store)
        
        // when
        let listNotContainedInPublisher = Watchlist(id: UUID(), name: "some other watchlist", symbols: ["some other symbol"])
        self.provider!.onRemove(listNotContainedInPublisher)
        
        // then
        wait(for: [expectation], timeout: 0.1) // which means that WatchlistsPublisher didn't publish the list reduced by the watchlist
        
        // and
        XCTAssertFalse(self.coreDataProvider!.deleteWatchlistCalled)
    }
    
    func test_givenWatchlistsProviderIsInitialized_whenWatchlistsProviderOnAddSymbolToWatchlistIsCalledWithSymbolAndWatchlist_andWatchlistIsContainedInWatchlistsPublisher_thenWatchlistsPublisherPublishesListContainingThisWatchlistWithAddedSymbol_andCoreDataProviderAddSymbolToWatchlistIsCalledWithThisWatchlistAndThisSymbol() throws {
        // given
        let watchlist = Watchlist(id: UUID(), name: "a watchlist", symbols: ["a symbol"])
        let otherList = Watchlist(id: UUID(), name: "some other watchlist", symbols: ["some other symbol"])
        let watchlists = [watchlist, otherList]
        setupProviders(watchlistsToReturn: watchlists)
        
        self.provider = WatchlistsProvider(
            coreDataProvider: self.coreDataProvider!,
            appFirstStartProvider: self.appFirstStartProvider!,
            initialList: Self.initialList
        )
        
        let symbol = "some new symbol"
        var watchlistAddedTheSymbol = watchlist
        watchlistAddedTheSymbol.symbols.append(symbol)
        
        let expectation = XCTestExpectation(description: UUID().description)
        self.provider!.watchlists
            .filter { $0.contains(watchlistAddedTheSymbol) }
            .sink { watchlists in
                expectation.fulfill()
            }
            .store(in: &store)
        
        // when
        self.provider!.onAdd(symbol, to: watchlist)
        
        // then
        wait(for: [expectation], timeout: 0.1) // which means that WatchlistsPublisher published list containing the watchlist that was added the symbol
        
        // and
        XCTAssertTrue(self.coreDataProvider!.addSymbolToWatchlistCalled)
        XCTAssertEqual(self.coreDataProvider!.addSymbolToWatchlistSymbol, symbol)
        XCTAssertEqual(self.coreDataProvider!.addSymbolToWatchlistWatchlist, watchlistAddedTheSymbol)
    }
    
    func test_givenWatchlistsProviderIsInitialized_whenWatchlistsProviderOnAddSymbolToWatchlistIsCalledWithSymbolAndWatchlist_andWatchlistIsNotContainedInWatchlistsPublisher_thenWatchlistsPublisherDoesNotPublishListContainingThisWatchlistWithAddedSymbol_andCoreDataProviderAddSymbolToWatchlistIsNotCalled() throws {
        // given
        let watchlist = Watchlist(id: UUID(), name: "a watchlist", symbols: ["a symbol"])
        let otherList = Watchlist(id: UUID(), name: "some other watchlist", symbols: ["some other symbol"])
        let watchlists = [watchlist, otherList]
        setupProviders(watchlistsToReturn: watchlists)
        
        self.provider = WatchlistsProvider(
            coreDataProvider: self.coreDataProvider!,
            appFirstStartProvider: self.appFirstStartProvider!,
            initialList: Self.initialList
        )
        
        let listNotContainedInPublisher = Watchlist(id: UUID(), name: "some other watchlist", symbols: ["some other symbol"])
        let symbol = "some new symbol"
        var watchlistNotContainedInPublisherAddedTheSymbol = listNotContainedInPublisher
        watchlistNotContainedInPublisherAddedTheSymbol.symbols.append(symbol)
        
        let expectation = XCTestExpectation(description: UUID().description)
        expectation.isInverted = true
        self.provider!.watchlists
            .filter { $0.contains(watchlistNotContainedInPublisherAddedTheSymbol) }
            .sink { watchlists in
                expectation.fulfill()
            }
            .store(in: &store)
        
        // when
        self.provider!.onAdd(symbol, to: listNotContainedInPublisher)
        
        // then
        wait(for: [expectation], timeout: 0.1) // which means that WatchlistsPublisher didn't publish list containing the watchlist that was added the symbol because there's no such watchlist in WatchlistPublisher
        
        // and
        XCTAssertFalse(self.coreDataProvider!.addSymbolToWatchlistCalled)
    }
    
    func test_givenWatchlistsProviderIsInitialized_whenWatchlistsProviderOnRemoveSymbolFromWatchlistIsCalledWithSymbolAndWatchlist_andWatchlistIsContainedInWatchlistsPublisher_andWatchlistContainsSymbol_thenWatchlistsPublisherPublishesListContainingThisWatchlistWithRemovedSymbol_andCoreDataProviderRemoveSymbolFromWatchlistIsCalledWithThisWatchlistAndThisSymbol() throws {
        // given
        let symbol = "symbol to remove"
        let watchlist = Watchlist(id: UUID(), name: "a watchlist", symbols: ["a symbol", symbol])
        let otherList = Watchlist(id: UUID(), name: "some other watchlist", symbols: ["some other symbol"])
        let watchlists = [watchlist, otherList]
        setupProviders(watchlistsToReturn: watchlists)
        
        self.provider = WatchlistsProvider(
            coreDataProvider: self.coreDataProvider!,
            appFirstStartProvider: self.appFirstStartProvider!,
            initialList: Self.initialList
        )
        
        var watchlistRemovedTheSymbol = watchlist
        watchlistRemovedTheSymbol.symbols.removeAll(where: { $0 == symbol })
        
        let expectation = XCTestExpectation(description: UUID().description)
        self.provider!.watchlists
            .filter { $0.contains(watchlistRemovedTheSymbol) }
            .sink { watchlists in
                expectation.fulfill()
            }
            .store(in: &store)
        
        // when
        self.provider!.onRemove(symbol, from: watchlist)
        
        // then
        wait(for: [expectation], timeout: 0.1) // which means that WatchlistsPublisher published list containing the watchlist that was removed the symbol
        
        // and
        XCTAssertTrue(self.coreDataProvider!.removeSymbolFromWatchlistCalled)
        XCTAssertEqual(self.coreDataProvider!.removeSymbolFromWatchlistSymbol, symbol)
        XCTAssertEqual(self.coreDataProvider!.removeSymbolFromWatchlistWatchlist, watchlistRemovedTheSymbol)
    }
    
    func test_givenWatchlistsProviderIsInitialized_whenWatchlistsProviderOnRemoveSymbolFromWatchlistIsCalledWithSymbolAndWatchlist_andWatchlistIsContainedInWatchlistsPublisher_andWatchlistDoesNotContainSymbol_thenWatchlistsPublisherDoesNotPublishListContainingThisWatchlistWithRemovedSymbol_andCoreDataProviderRemoveSymbolFromWatchlistIsNotCalledWithThisWatchlistAndThisSymbol() throws {
        // given
        let symbol = "symbol will not be removed as it is not contained in the watchlist"
        let watchlist = Watchlist(id: UUID(), name: "a watchlist", symbols: ["a symbol"])
        let otherList = Watchlist(id: UUID(), name: "some other watchlist", symbols: ["some other symbol"])
        let watchlists = [watchlist, otherList]
        setupProviders(watchlistsToReturn: watchlists)
        
        self.provider = WatchlistsProvider(
            coreDataProvider: self.coreDataProvider!,
            appFirstStartProvider: self.appFirstStartProvider!,
            initialList: Self.initialList
        )
        
        var watchlistRemovedTheSymbol = watchlist
        watchlistRemovedTheSymbol.symbols.removeAll()
        
        let expectation = XCTestExpectation(description: UUID().description)
        expectation.isInverted = true
        self.provider!.watchlists
            .filter { $0.contains(watchlistRemovedTheSymbol) } // at init we have watchlist with 1 symbol and it should stay as it is as we don't remove any symbol from it - so we never would have watchlist with no symbols and this code in sink triggered
            .sink { watchlists in
                expectation.fulfill()
            }
            .store(in: &store)
        
        // when
        self.provider!.onRemove(symbol, from: watchlist)
        
        // then
        wait(for: [expectation], timeout: 0.1) // which means that WatchlistsPublisher didn't publish the list containing the watchlist that was removed the symbol
        
        // and
        XCTAssertFalse(self.coreDataProvider!.removeSymbolFromWatchlistCalled)
    }
    
    func test_givenWatchlistsProviderIsInitialized_whenWatchlistsProviderOnRemoveSymbolFromWatchlistIsCalledWithSymbolAndWatchlist_andWatchlistIsNotContainedInWatchlistsPublisher_thenWatchlistsPublisherDoesNotPublishListContainingThisWatchlistWithRemovedSymbol_andCoreDataProviderRemoveSymbolFromWatchlistIsNotCalledWithThisWatchlistAndThisSymbol() throws {
        // given
        let symbol = "symbol to remove"
        let watchlist = Watchlist(id: UUID(), name: "a watchlist", symbols: [symbol])
        let otherList = Watchlist(id: UUID(), name: "some other watchlist", symbols: [symbol, symbol])
        let watchlists = [watchlist, otherList]
        setupProviders(watchlistsToReturn: watchlists)
        
        self.provider = WatchlistsProvider(
            coreDataProvider: self.coreDataProvider!,
            appFirstStartProvider: self.appFirstStartProvider!,
            initialList: Self.initialList
        )
        
        
        var listNotContainedInPublisherButContainingTheSymbol = watchlist
        listNotContainedInPublisherButContainingTheSymbol.id = UUID()
        
        let expectation = XCTestExpectation(description: UUID().description)
        expectation.isInverted = true
        self.provider!.watchlists
            .filter { $0.contains(listNotContainedInPublisherButContainingTheSymbol) }
            .sink { watchlists in
                expectation.fulfill()
            }
            .store(in: &store)
        
        // when
        self.provider!.onRemove(symbol, from: listNotContainedInPublisherButContainingTheSymbol)
        
        // then
        wait(for: [expectation], timeout: 0.1) // which means that WatchlistsPublisher didn't publish list containing the watchlist that was removed the symbol because there's no such watchlist in WatchlistPublisher
        
        // and
        XCTAssertFalse(self.coreDataProvider!.removeSymbolFromWatchlistCalled)
    }
}

private extension WatchlistsProviderTests {
    func setupProviders(
        watchlistsToReturn: [Watchlist] = [],
        isFirstAppStart: Bool = false
    ) {
        self.coreDataProvider = MockWatchlistsCoreDataProvider()
        self.coreDataProvider!.watchlistsToReturn = watchlistsToReturn
        
        self.appFirstStartProvider = MockAppFirstStartProvider()
        self.appFirstStartProvider!.shouldReturnThatThisIsFirstAppStart = isFirstAppStart
    }
}
