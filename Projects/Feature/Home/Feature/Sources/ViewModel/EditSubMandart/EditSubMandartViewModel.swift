//
//  EditSubMandartViewModel.swift
//  Home
//
//  Created by choijunios on 12/20/24.
//

import Foundation

import SharedNavigationInterface
import SharedDependencyInjector
import DomainMandaratInterface

import ReactorKit
import RxSwift

class EditSubMandartViewModel: Reactor {
    
    @Inject private var router: Router
    
    var initialState: State
    
    private let initialSubMandartVO: SubMandaratVO
    
    init(_ subMandartVO: SubMandaratVO) {
        
        self.initialSubMandartVO = subMandartVO
        
        self.initialState = .init(
            titleText: subMandartVO.title,
            acheiveRate: subMandartVO.acheivementRate
        )
    }
    
    
    func mutate(action: Action) -> Observable<Action> {
        switch action {
        case .exitButtonClicked:
            
            router.dismissModule(animated: true)
            
            return .never()
        default:
            return .just(action)
        }
    }
    
    
    func reduce(state: State, mutation: Action) -> State {
        
        switch mutation {
        case .acheivePercentChanged(let percent):
            print(percent)
            var newState = state
            newState.acheiveRate = percent
            return newState
            
        case .titleChanged(let text):
            print(text)
            var newState = state
            newState.titleText = text
            return newState
            
        case .saveButtonClicked:
            
            var newState = state
            
            
            
            return newState
            
        default:
            return state
        }
    }
    
}


// MARK: Reactor
extension EditSubMandartViewModel {
    
    struct State {
        
        var titleText: String
        var acheiveRate: Double
    }
    
    enum Action {
           
        case acheivePercentChanged(percent: Double)
        case titleChanged(text: String)
        case saveButtonClicked
        case exitButtonClicked
    }
}
