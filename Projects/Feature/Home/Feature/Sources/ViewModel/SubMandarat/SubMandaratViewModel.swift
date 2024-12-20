//
//  SubMandaratViewModel.swift
//  Home
//
//  Created by choijunios on 12/13/24.
//

import UIKit

import DomainMandaratInterface

import ReactorKit
import RxSwift

class SubMandaratViewModel: Reactor {
    
    var initialState: State
    
    private let position: MandaratPosition
    
    weak var deleate: SubMandaratViewModelDelegate?
    
    init(position: MandaratPosition, color: UIColor) {
        
        self.position = position
        
        self.initialState = .init(
            titleColor: color
        )
    }
    
    func mutate(action: Action) -> Observable<Action> {
        switch action {
        case .editSubMandaratButtonClicked:
            
            deleate?.subMandarat(edit: position)
            
            return .never()
        }
    }
    
    func reduce(state: State, mutation: Action) -> State {
        
        return state
    }
}

// MARK: Action & State
extension SubMandaratViewModel {
    
    enum Action {
        
        case editSubMandaratButtonClicked
    }
    
    struct State {
        
        var isAvailable: Bool = false
        var titleColor: UIColor
    }
}
