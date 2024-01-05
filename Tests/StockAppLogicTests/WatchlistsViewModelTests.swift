//
//  WatchlistsViewModelTests.swift
//  StockAppLogicTests
//
//  Created by Jan Gulkowski on 02/01/2024.
//

import XCTest
import Combine
@testable import StockAppLogic

final class WatchlistsViewModelTests: XCTestCase {
    private var store = Set<AnyCancellable>()
    private var viewModel: WatchlistsViewModel?
    private var coordinator: MockCoordinator?
    private var watchlistsProvider: MockWatchlistsProvider?
    
    override func tearDown() {
        self.coordinator = nil
        self.watchlistsProvider = nil
        self.viewModel = nil
        self.store.removeAll()
    }

    func test_givenThatWatchlistsProviderReturnsXItems_thenWatchlistsCountIsEqualToX() throws {
        // given
        let numberOfItems = Int.random(in: 1..<10)
        let items = getRandomWatchlists(inNumber: numberOfItems)
        setupVariables(with: items)
        
        // when
        
        // then
        XCTAssertEqual(self.viewModel!.watchlistsCount, numberOfItems)
    }

    func test_givenThatWatchlistsProviderHasYetNotObtainedAnyItems_whenViewModelIsInitialized_thenStatePublisherHasValueOfLoading() throws {
        // given
        
        // when
        setupVariables()
        
        // then
        self.viewModel!.statePublisher
            .sink { XCTAssertEqual($0, .loading) }
            .store(in: &store)
    }
    
    func test_givenThatWatchlistsProviderWillObtainItemsShortly_whenViewModelIsInitialized_thenStatePublisherWillHaveValueOfDataObtainedAfterItHappens() throws {
        // given
        setupVariables()
        
        // when
        
        // then
        let expectation = XCTestExpectation(description: UUID().description)
        self.viewModel!.statePublisher
            .dropFirst() // as it's .loading initially
            .sink {
                XCTAssertEqual($0, .dataObtained)
                expectation.fulfill()
            }
            .store(in: &store)
        
        let items = getRandomWatchlists(inNumber: 5)
        self.watchlistsProvider!.setupWatchlists(with: items)
        
        wait(for: [expectation], timeout: 0.1)
    }
    
    func test_givenThatIndexIsSmallerThanNumberOfItemsReturnedFromWatchlistsProvider_whenGetWatchlistsForIndexIsCalledForTheIndex_thenItemRelatedToTheIndexShouldBeReturned() throws {
        // given
        let (index, numberOfItems) = getIndexAndNumberOfItems_whereIndexIsSmallerThanNumberOfItems()
        let items = getRandomWatchlists(inNumber: numberOfItems)
        setupVariables(with: items)
        
        // when
        let watchlist = self.viewModel!.getWatchlistFor(index: index)
        
        // then
        XCTAssertEqual(watchlist, items[index])
    }
    
    func test_givenThatIndexIsGreaterThanOrEqualToNumberOfItemsReturnedFromWatchlistsProvider_whenGetWatchlistsForIndexIsCalledForTheIndex_thenNilShouldBeReturned() throws {
        // given
        let (index, numberOfItems) = getIndexAndNumberOfItems_whereIndexIsGreaterThanOrEqualToNumberOfItems()
        let items = getRandomWatchlists(inNumber: numberOfItems)
        setupVariables(with: items)
        
        // when
        let watchlist = self.viewModel!.getWatchlistFor(index: index)
        
        // then
        XCTAssertNil(watchlist)
    }
    
    func test_givenThatIndexIsSmallerThanNumberOfItemsReturnedFromWatchlistsProvider_whenOnItemTappedIsCalledForTheIndex_thenCoordinatorExecuteActionShouldBeCalledWithItemSelectedAndWatchlistRelatedToTheIndex() throws {
        // given
        let (index, numberOfItems) = getIndexAndNumberOfItems_whereIndexIsSmallerThanNumberOfItems()
        let items = getRandomWatchlists(inNumber: numberOfItems)
        setupVariables(with: items)
        
        // when
        self.viewModel!.onItemTapped(at: index)
        
        // then
        XCTAssertTrue(self.coordinator!.executeActionCalled)
        
        switch self.coordinator!.executeAction {
        case .itemSelected(data: let data):
            XCTAssertEqual(data as! Watchlist, items[index])
        default:
            XCTFail()
        }
    }
    
    func test_givenThatIndexIsGreaterThanOrEqualToNumberOfItemsReturnedFromWatchlistsProvider_whenOnItemTappedIsCalledForTheIndex_thenCoordinatorExecuteActionShouldNotBeCalled() throws {
        // given
        let (index, numberOfItems) = getIndexAndNumberOfItems_whereIndexIsGreaterThanOrEqualToNumberOfItems()
        let items = getRandomWatchlists(inNumber: numberOfItems)
        setupVariables(with: items)
        
        // when
        self.viewModel!.onItemTapped(at: index)
        
        // then
        XCTAssertFalse(self.coordinator!.executeActionCalled)
    }
    
    func test_whenOnAddButtonTappedIsCalled_thenCoordinatorExecuteActionShouldBeCalledWithAddButtonTappedWithNoData() throws {
        // given
        setupVariables()
        
        // when
        self.viewModel!.onAddButtonTapped()
        
        // then
        XCTAssertTrue(self.coordinator!.executeActionCalled)
        
        switch self.coordinator!.executeAction {
        case .addButtonTapped(data: let data):
            XCTAssertNil(data)
        default:
            XCTFail()
        }
    }

    func test_givenThatIndexIsSmallerThanNumberOfItemsReturnedFromWatchlistsProvider_whenOnItemSwipedOutIsCalledForTheIndex_thenWatchlistsProviderOnRemoveMethodIsCalledForTheWatchlistRelatedToTheIndex() throws {
        // given
        let (index, numberOfItems) = getIndexAndNumberOfItems_whereIndexIsSmallerThanNumberOfItems()
        let items = getRandomWatchlists(inNumber: numberOfItems)
        setupVariables(with: items)
        
        // when
        self.viewModel!.onItemSwipedOut(at: index)
        
        // then
        XCTAssertTrue(self.watchlistsProvider!.onRemoveCalled)
        XCTAssertEqual(self.watchlistsProvider!.onRemoveWatchlist, items[index])
    }
    
    func test_givenThatIndexIsSmallerThanNumberOfItemsReturnedFromWatchlistsProvider_whenOnItemSwipedOutIsCalledForTheIndex_thenWatchlistsPublisherWillContainAllTheItemsExceptTheOneRelatedToTheIndex() throws {
        // given
        let (index, numberOfItems) = getIndexAndNumberOfItems_whereIndexIsSmallerThanNumberOfItems()
        let items = getRandomWatchlists(inNumber: numberOfItems)
        setupVariables(with: items)
        
        // when
        self.viewModel!.onItemSwipedOut(at: index)
        
        // then
        let expectation = XCTestExpectation(description: UUID().description)
        self.viewModel!.watchlistsPublisher
            .sink {
                var items = items
                items.remove(at: index)
                XCTAssertEqual($0, items)
                expectation.fulfill()
            }
            .store(in: &store)
        
        wait(for: [expectation], timeout: 0.1)
    }
    
    func test_givenThatIndexIsGreaterThanOrEqualToNumberOfItemsReturnedFromWatchlistsProvider_whenOnItemSwipedOutIsCalledForTheIndex_thenWatchlistsProviderOnRemoveMethodIsNotCalled() throws {
        // given
        let (index, numberOfItems) = getIndexAndNumberOfItems_whereIndexIsGreaterThanOrEqualToNumberOfItems()
        let items = getRandomWatchlists(inNumber: numberOfItems)
        setupVariables(with: items)
        
        // when
        self.viewModel!.onItemSwipedOut(at: index)
        
        // then
        XCTAssertFalse(self.watchlistsProvider!.onRemoveCalled)
    }
}

private extension WatchlistsViewModelTests {
    func getRandomWatchlists(inNumber numberOfWatchlists: Int) -> [Watchlist] {
        var items = [Watchlist]()
        for _ in 0..<numberOfWatchlists {
            items.append(
                Watchlist(id: UUID(), name: "Some name", symbols: ["Symbol 1", "Symbol 2", "Symbol 3"])
            )
        }
        return items
    }
    
    func setupVariables(with items: [Watchlist]? = nil) {
        self.coordinator = MockCoordinator()
        self.watchlistsProvider = MockWatchlistsProvider()
        if let items = items {
            self.watchlistsProvider!.setupWatchlists(with: items)
        }
        self.viewModel = WatchlistsViewModel(
            coordinator: self.coordinator!,
            watchlistsProvider: self.watchlistsProvider!
        )
    }
}
