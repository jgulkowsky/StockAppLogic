//
//  AddNewWatchlistViewModelTests.swift
//  StockAppTests
//
//  Created by Jan Gulkowski on 02/01/2024.
//

import XCTest
import Combine
@testable import StockAppLogic

final class AddNewWatchlistViewModelTests: XCTestCase {
    private var store = Set<AnyCancellable>()
    private var viewModel: AddNewWatchlistViewModel?
    private var coordinator: MockCoordinator?
    private var watchlistsProvider: MockWatchlistsProvider?
    
    override func tearDown() {
        self.coordinator = nil
        self.watchlistsProvider = nil
        self.viewModel = nil
        self.store.removeAll()
    }
    
    func test_whenViewModelIsInitialized_thenErrorPublisherEmitsNil() {
        // given
        
        // when
        setupVariables()
        
        // then
        self.viewModel!.errorPublisher
            .sink {
                XCTAssertNil($0)
            }
            .store(in: &store)
    }
    
    func test_whenOnTextFieldSubmittedIsCalledWithTextEqualToNil_thenWatchlistTextPublisherDoesNotEmitAnyValue_alsoErrorPublisherDoesNotEmitAnyValueExceptTheInitialNil_alsoWatchlistOnAddMethodIsNotCalled_alsoCoordinatorExecuteMethodIsNotCalled() throws {
        // given
        let items = [
            Watchlist(id: UUID(), name: "some list", symbols: ["some symbol"])
        ]
        setupVariables(with: items)
        
        // when
        self.viewModel!.onTextFieldSubmitted(text: nil)
        
        // then
        self.viewModel!.watchlistTextPublisher
            .sink { _ in
                XCTFail()
            }
            .store(in: &store)
        
        self.viewModel!.errorPublisher
            .dropFirst()
            .sink { _ in
                XCTFail()
            }
            .store(in: &store)
        
        XCTAssertFalse(self.watchlistsProvider!.onAddCalled)
        XCTAssertFalse(self.coordinator!.executeActionCalled)
    }
    
    func test_givenThatWatchlistsProviderHasNoItemsYet_whenOnTextFieldSubmittedIsCalledWithSomeText_thenWatchlistTextPublisherDoesNotEmitAnyValue_alsoErrorPublisherDoesNotEmitAnyValueExceptTheInitialNil_alsoWatchlistOnAddMethodIsNotCalled_alsoCoordinatorExecuteMethodIsNotCalled() throws {
        // given
        setupVariables() // watchlistsProvider has no items
        
        // when
        self.viewModel!.onTextFieldSubmitted(text: "some valid text")
        
        // then
        self.viewModel!.watchlistTextPublisher
            .sink { _ in
                XCTFail()
            }
            .store(in: &store)
        
        self.viewModel!.errorPublisher
            .dropFirst()
            .sink { _ in
                XCTFail()
            }
            .store(in: &store)
        
        XCTAssertFalse(self.watchlistsProvider!.onAddCalled)
        XCTAssertFalse(self.coordinator!.executeActionCalled)
    }
    
    func test_givenThatWatchlistsProviderHasItems_whenOnTextFieldSubmittedWithNonNilText_thenWatchlistsTextPublisherEmitsValueEqualToTrimmedText() throws {
        // given
        let items = [
            Watchlist(id: UUID(), name: "some list", symbols: ["some symbol"])
        ]
        setupVariables(with: items)
        
        // when
        let text = "some text"
        let textPlusSpaces = "  \(text)    "
        self.viewModel!.onTextFieldSubmitted(text: textPlusSpaces)
        
        // then
        self.viewModel!.watchlistTextPublisher
            .sink {
                XCTAssertEqual($0, text)
            }
            .store(in: &store)
    }
    
    func test_givenThatWatchlistsProviderHasItems_andTextIsEmptyAfterTrimming_whenOnTextFieldSubmittedIsCalledWithTheText_thenErrorPublisherEmitsEmptyNameError() throws {
        // given
        let items = [
            Watchlist(id: UUID(), name: "some list", symbols: ["some symbol"])
        ]
        let emptyNameError = "EMPTY NAME!!!"
        setupVariables(
            with: items,
            emptyNameError: emptyNameError
        )
        let text = "         "
        
        // when
        self.viewModel!.onTextFieldSubmitted(text: text)
        
        // then
        self.viewModel!.errorPublisher
            .sink {
                XCTAssertEqual($0, emptyNameError)
            }
            .store(in: &store)
    }
    
    func test_givenThatWatchlistsProviderHasItems_andTextIsEqualToAnyOfTheseItemsNames_whenOnTextFieldSubmittedIsCalledWithTheText_thenErrorPublisherEmitsNameAlreadyExistsError() throws {
        // given
        let duplicatedListName = "some list"
        let items = [
            Watchlist(id: UUID(), name: duplicatedListName, symbols: ["some symbol"])
        ]
        let watchlistAlreadyExistsError = "WATCHLIST EXISTS!!!"
        setupVariables(
            with: items,
            watchlistAlreadyExistsError: watchlistAlreadyExistsError
        )
        let text = duplicatedListName
        
        // when
        self.viewModel!.onTextFieldSubmitted(text: text)
        
        // then
        self.viewModel!.errorPublisher
            .sink {
                XCTAssertEqual($0, watchlistAlreadyExistsError)
            }
            .store(in: &store)
    }
    
    func test_givenThatWatchlistsProviderHasItems_andTextIsNotEmptyAfterTrimming_andNotEqualToAnyOfTheseItemsNames_whenOnTextFieldSubmittedIsCalledWithTheText_thenWatchlistsProviderOnAddMethodIsCalledWithNewlyCreatedWatchlistWithNameFromTheTrimmedTextAndWithEmptyListOfSybols() throws {
        // given
        let items = [
            Watchlist(id: UUID(), name: "some list", symbols: ["some symbol"])
        ]
        setupVariables(with: items)
        let text = "non empty text after trimming and also not equal to any of the watchlists names"
        let textPlusSpaces = "    \(text)    "
        
        // when
        self.viewModel!.onTextFieldSubmitted(text: textPlusSpaces)
        
        // then
        XCTAssertTrue(self.watchlistsProvider!.onAddCalled)
        XCTAssertEqual(self.watchlistsProvider!.onAddWatchlist!.name, text)
        XCTAssertEqual(self.watchlistsProvider!.onAddWatchlist!.symbols, [])
    }
    
    func test_givenThatWatchlistsProviderHasItems_andTextIsNotEmptyAfterTrimming_andNotEqualToAnyOfTheseItemsNames_whenOnTextFieldSubmittedIsCalledWithTheText_thenCoordinatorExecuteMethodIsCalledWithActionInputSubmitted() throws {
        // given
        let items = [
            Watchlist(id: UUID(), name: "some list", symbols: ["some symbol"])
        ]
        setupVariables(with: items)
        let text = "non empty text after trimming and also not equal to any of the watchlists names"
        let textPlusSpaces = "    \(text)    "
        
        // when
        self.viewModel!.onTextFieldSubmitted(text: textPlusSpaces)
        
        // then
        XCTAssertTrue(self.coordinator!.executeActionCalled)
        
        switch self.coordinator!.executeAction {
        case .inputSubmitted:
            XCTAssert(true)
        default:
            XCTFail()
        }
    }
    
    func test_givenThatSomeErrorIsAlreadyPublished_whenOnTextFieldFocusedIsCalled_thenErrorPublisherPublishesNil() throws {
        // given
        let duplicatedListName = "some list"
        let items = [
            Watchlist(id: UUID(), name: duplicatedListName, symbols: ["some symbol"])
        ]
        let watchlistAlreadyExistsError = "WATCHLIST EXISTS!!!"
        setupVariables(
            with: items,
            watchlistAlreadyExistsError: watchlistAlreadyExistsError
        )
        let text = duplicatedListName
        self.viewModel!.onTextFieldSubmitted(text: text)
        let expectation = XCTestExpectation(description: UUID().description)
        self.viewModel!.errorPublisher
            .first()
            .sink {
                XCTAssertEqual($0, watchlistAlreadyExistsError)
                expectation.fulfill()
            }
            .store(in: &store)
        
        wait(for: [expectation], timeout: 0.1)
        
        // when
        self.viewModel!.onTextFieldFocused(initialText: nil)

        // then
        self.viewModel!.errorPublisher
            .sink {
                XCTAssertNil($0)
            }
            .store(in: &store)
    }
}

private extension AddNewWatchlistViewModelTests {
    func setupVariables(
        with items: [Watchlist]? = nil,
        emptyNameError: String = "emptyNameError",
        watchlistAlreadyExistsError: String = "watchlistAlreadyExistsError"
    ) {
        self.coordinator = MockCoordinator()
        self.watchlistsProvider = MockWatchlistsProvider()
        if let items = items {
            self.watchlistsProvider!.setupWatchlists(with: items)
        }
        self.viewModel = AddNewWatchlistViewModel(
            coordinator: self.coordinator!,
            watchlistsProvider: self.watchlistsProvider!,
            emptyNameError: emptyNameError,
            watchlistAlreadyExistsError: watchlistAlreadyExistsError
        )
    }
}
