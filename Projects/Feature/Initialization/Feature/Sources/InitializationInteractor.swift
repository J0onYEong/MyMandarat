//
//  InitializationInteractor.swift
//  Initialization
//
//  Created by choijunios on 12/30/24.
//

import DomainUserStateInterface

protocol InitializationRouting: AnyObject {
    
    func presentMainMandaratPage()
    
    func presentNickNameInputPage()
}

class InitializationInteractor: InitializationInteractable {
    
    // DI
    private let userStateUseCase: UserStateUseCase
    
    
    // Router
    weak var router: InitializationRouting?
    
    
    init(userStateUseCase: UserStateUseCase) {
        self.userStateUseCase = userStateUseCase
    }
    
}

// MARK: InitializationInteractable
extension InitializationInteractor {
    
    func checkRequiredInput() {
        
        let userNickName = userStateUseCase.checkState(.userNickName)
        
        if userNickName.isEmpty {
            
            router?.presentNickNameInputPage()
            
        } else {
            
            router?.presentMainMandaratPage()
        }
    }
}