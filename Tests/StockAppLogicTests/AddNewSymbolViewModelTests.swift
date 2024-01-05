//
//  AddNewSymbolViewModelTests.swift
//  StockAppLogicTests
//
//  Created by Jan Gulkowski on 03/01/2024.
//

import XCTest
import Combine
@testable import StockAppLogic

final class AddNewSymbolViewModelTests: XCTestCase {
    private var store = Set<AnyCancellable>()
    private var viewModel: AddNewSymbolViewModel?
    private var coordinator: MockCoordinator?
    private var watchlistsProvider: MockWatchlistsProvider?
    private var symbolsProvider: MockSymbolsProvider?
    
    override func setUp() {
        self.coordinator = MockCoordinator()
        self.watchlistsProvider = MockWatchlistsProvider()
        self.symbolsProvider = MockSymbolsProvider()
        
        self.viewModel = AddNewSymbolViewModel(
            coordinator: self.coordinator!,
            watchlistsProvider: self.watchlistsProvider!,
            symbolsProvider: self.symbolsProvider!,
            watchlist: Watchlist(id: UUID(), name: "some watchlist", symbols: []),
            searchTextDebounceMillis: 0 // generally be careful with changing this as this can affect timeouts in tests - normal value used in app is 500 millis
        )
    }
    
    override func tearDown() {
        self.coordinator = nil
        self.watchlistsProvider = nil
        self.symbolsProvider = nil
        self.viewModel = nil
        self.store.removeAll()
    }
    
    func test_givenThatIndexIsSmallerThanNumberOfSymbolsReturned_whenGetSymbolForIndexIsCalled_thenSymbolShouldBeReturned() throws {
        // given
        let (index, numberOfItems) = getIndexAndNumberOfItems_whereIndexIsSmallerThanNumberOfItems()
        let symbolsFromProvider = self.symbolsProvider!.setupSymbolsToReturn(in: numberOfItems)
        
        self.viewModel!.onSearchTextChanged(to: "some text")
        wait(for: 0.1)
        
        // when
        let symbol = self.viewModel!.getSymbolFor(index: index)
        
        // then
        XCTAssertEqual(symbol, symbolsFromProvider[index])
    }
    
    func test_givenThatIndexIsGreaterThanOrEqualToNumberOfSymbolsReturned_whenGetSymbolForIndexIsCalled_thenNilShouldBeReturned() throws {
        // given
        let (index, numberOfItems) = getIndexAndNumberOfItems_whereIndexIsGreaterThanOrEqualToNumberOfItems()
        _ = self.symbolsProvider!.setupSymbolsToReturn(in: numberOfItems)
        
        self.viewModel!.onSearchTextChanged(to: "some text")
        wait(for: 0.1)
        
        // when
        let symbol = self.viewModel!.getSymbolFor(index: index)
        
        // then
        XCTAssertNil(symbol)
    }
    
    func test_givenThatSymbolsProviderWillProvideListOfSymbols_whenOnSearchTextChangedIsCalled_thenSymbolsPublisherShouldEmitTheseSymbolsInNearFuture() throws {
        // given
        let symbolsFromProvider = self.symbolsProvider!.setupSymbolsToReturn(in: 10)
        
        // when
        self.viewModel!.onSearchTextChanged(to: "some text")
        
        // then
        let expectation = XCTestExpectation(description: UUID().description)
        self.viewModel!.symbolsPublisher
            .filter { !$0.isEmpty }
            .sink { symbols in
                XCTAssertEqual(symbols, symbolsFromProvider)
                expectation.fulfill()
            }
            .store(in: &store)
        wait(for: [expectation], timeout: 0.1)
    }
    
    func test_givenThatSymbolsProviderWillProvideListOfXSymbols_whenOnSearchTextChangedIsCalled_thenSymbolsCountShouldBeEqualToXWhenSymbolsPublisherEmitsTheseSymbols() throws {
        // given
        let numberOfSymbols = Int.random(in: 0..<10)
        _ = self.symbolsProvider!.setupSymbolsToReturn(in: numberOfSymbols)
        
        // when
        self.viewModel!.onSearchTextChanged(to: "some text")
        wait(for: 0.1)
        
        // then
        XCTAssertEqual(self.viewModel!.symbolsCount, numberOfSymbols)
    }
    
    func test_whenOnSearchTextChangedToStringXIsCalled_thenSymbolsProviderGetSymbolsStartingWithStringXIsCalled_inNearFuture() throws {
        // given
        _ = self.symbolsProvider!.setupSymbolsToReturn(in: 10)
        let text = "String X"
        
        // when
        self.viewModel!.onSearchTextChanged(to: text)
        wait(for: 0.1)
        
        // then
        XCTAssertTrue(self.symbolsProvider!.getSymbolsCalled)
        XCTAssertEqual(self.symbolsProvider!.getSymbolsText, text)
    }
    
    func test_givenThatIndexIsGreaterThanOrEqualToNumberOfSymbolsReturned_whenOnItemTappedAtIndexIsCalled_thenWatchlistsProviderOnAddSymbolToWatchlistIsNotCalled_andCoordinatorDoesNotExecuteAnyAction() throws {
        // given
        let (index, numberOfItems) = getIndexAndNumberOfItems_whereIndexIsGreaterThanOrEqualToNumberOfItems()
        _ = self.symbolsProvider!.setupSymbolsToReturn(in: numberOfItems)

        self.viewModel!.onSearchTextChanged(to: "some text")
        wait(for: 0.1)

        // when
        self.viewModel!.onItemTapped(at: index)

        // then
        XCTAssertFalse(self.watchlistsProvider!.onAddSymbolCalled)
        
        // and
        XCTAssertFalse(self.coordinator!.executeActionCalled)
    }
    
    func test_givenThatSymbolForIndexExists_andThisSymbolIsAlreadyContainedByTheWatchlist_whenOnItemTappedAtIndexIsCalled_thenWatchlistsProviderOnAddSymbolToWatchlistIsNotCalled_andCoordinatorExecutesActionOfItemSelectedWithNoAdditionalData() throws {
        // given
        let (index, numberOfItems) = getIndexAndNumberOfItems_whereIndexIsSmallerThanNumberOfItems()
        let symbols = self.symbolsProvider!.setupSymbolsToReturn(in: numberOfItems)
        let symbol = symbols[index]
        self.viewModel = AddNewSymbolViewModel(
            coordinator: self.coordinator!,
            watchlistsProvider: self.watchlistsProvider!,
            symbolsProvider: self.symbolsProvider!,
            watchlist: Watchlist(id: UUID(), name: "some watchlist", symbols: [symbol]),
            searchTextDebounceMillis: 0 // generally be careful with changing this as this can affect timeouts in tests - normal value used in app is 500 millis
        )

        self.viewModel!.onSearchTextChanged(to: "some text")
        wait(for: 0.1)

        // when
        self.viewModel!.onItemTapped(at: index)

        // then
        XCTAssertFalse(self.watchlistsProvider!.onAddSymbolCalled)
        
        // and
        XCTAssertTrue(self.coordinator!.executeActionCalled)
        switch self.coordinator!.executeAction {
        case .itemSelected(data: let data):
            XCTAssertNil(data)
        default:
            XCTFail()
        }
    }
    
    func test_givenThatSymbolForIndexExists_andThisSymbolIsNotYetContainedByTheWatchlist_whenOnItemTappedAtIndexIsCalled_thenWatchlistsProviderOnAddSymbolToWatchlistIsCalled_andAlsoCoordinatorExecutesActionOfItemSelectedWithNoAdditionalData() throws {
        // given
        let (index, numberOfItems) = getIndexAndNumberOfItems_whereIndexIsSmallerThanNumberOfItems()
        let symbols = self.symbolsProvider!.setupSymbolsToReturn(in: numberOfItems)
        let symbol = symbols[index]

        self.viewModel!.onSearchTextChanged(to: "some text")
        wait(for: 0.1)

        // when
        self.viewModel!.onItemTapped(at: index)

        // then
        XCTAssertTrue(self.watchlistsProvider!.onAddSymbolCalled)
        XCTAssertEqual(self.watchlistsProvider!.onAddSymbolSymbol, symbol)
        
        // and
        XCTAssertTrue(self.coordinator!.executeActionCalled)
        switch self.coordinator!.executeAction {
        case .itemSelected(data: let data):
            XCTAssertNil(data)
        default:
            XCTFail()
        }
    }
}
