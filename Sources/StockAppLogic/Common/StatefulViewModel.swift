//
//  StatefulViewModel.swift
//  StockApp
//
//  Created by Jan Gulkowski on 20/12/2023.
//

import Foundation
import Combine

class StatefulViewModel {
    enum State {
        case loading
        case error
        case dataObtained
    }
    
    var statePublisher: AnyPublisher<State, Never> {
        stateSubject
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
    
    var errorPublisher: AnyPublisher<String?, Never> {
        errorSubject
            .eraseToAnyPublisher()
    }
    
    private var stateSubject: CurrentValueSubject<State, Never>
    private var errorSubject: CurrentValueSubject<String?, Never>
    
    init(stateSubject: CurrentValueSubject<State, Never>,
         errorSubject: CurrentValueSubject<String?, Never>
    ) {
        self.stateSubject = stateSubject
        self.errorSubject = errorSubject
    }
}
