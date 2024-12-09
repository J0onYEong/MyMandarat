//
//  EditMainMandaratViewModel.swift
//  Home
//
//  Created by choijunios on 12/9/24.
//

import ReactorKit
import RxSwift

class EditMainMandaratViewModel: Reactor {
    
    let initialState: State
    
    init(initialState: State) {
        
        self.initialState = initialState
    }
    
    func reduce(state: State, mutation: Action) -> State {
        
        switch mutation {
        case .editTitleText(let text):
            
            var newState = state
            
            return newState
            
        default:
            return state
        }
    }
}

extension EditMainMandaratViewModel {
    
    enum Action {
        
        // Event
        case editTitleText(text: String)
        case editDescriptionText(text: String)
        
        // Side effect
    }
    
    struct State {
        
        var titleText: String
        var descriptionText: String
    }
}
