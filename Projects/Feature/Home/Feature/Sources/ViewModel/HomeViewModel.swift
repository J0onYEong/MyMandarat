//
//  HomeViewModel.swift
//  Home
//
//  Created by choijunios on 12/4/24.
//

import UIKit

import SharedDependencyInjector
import SharedNavigationInterface
import DomainMandaratInterface

import ReactorKit

class HomeViewModel: Reactor, MainMandaratViewModelDelegate, EditMainMandaratViewModelDelegate {
    
    @Inject private var router: Router
    
    // 의존성 주입
    private let mandaratUseCase: MandaratUseCase
    
    let initialState: State = .init()
    
    // Sub reactors
    private(set) var mainMandaratViewReactors: [MandaratPosition: MainMandaratViewModel] = [:]
    
    init(mandaratUseCase: MandaratUseCase) {
        
        self.mandaratUseCase = mandaratUseCase
            
        createMainMandaratReactors()
    }
    
    public func sendEvent(_ action: Action) {
        
        self.action.onNext(action)
    }
    
    func mutate(action: Action) -> Observable<Action> {
        
        switch action {
        case .viewDidLoad:
            
            return mandaratUseCase
                .requestMainMandarats()
                .asObservable()
                .map { mainMandarats in
                    
                    Action.fetchedMainMandarat(mainMandarats)
                }
        default:
            return .just(action)
        }
    }
    
    func reduce(state: State, mutation: Action) -> State {
        
        switch mutation {
        case .fetchedMainMandarat(let mainMandarats):
            
            var newState = state
            mainMandarats.forEach { mainMandaratVO in
                
                let position = mainMandaratVO.position
                newState.mainMandaratVO[position] = mainMandaratVO
                
            }
            return newState
            
        case .addMainMandaratButtonClicked(let position):
            
            let mainMandaratVO = state.mainMandaratVO[position] ?? .createEmpty(with: position)
            presentEditMainMandaratViewController(mainMandaratVO)
            
            return state
            
        case .mandaratUpdated(let mandaratVO):
            
            var newState = state
            let position = mandaratVO.position
            newState.mainMandaratVO[position] = mandaratVO
            
            // to mainMandaratViewModel
            let mainMandaratViewModel = mainMandaratViewReactors[position]
            mainMandaratViewModel?.requestRender(.create(from: mandaratVO))
            
            return newState
            
        default:
            return state
        }
        
    }
}


extension HomeViewModel {
    
    enum Action {
        
        // Event
        case addMainMandaratButtonClicked(MandaratPosition)
        case mandaratUpdated(MainMandaratVO)
        case viewDidLoad
        
        // Side effect
        case fetchedMainMandarat([MainMandaratVO])
    }
    
    struct State {
    
        var mainMandaratVO: [MandaratPosition: MainMandaratVO] = [:]
        
        var presentEditMainMandaratView: Bool = false
    }
}


// MARK: Navigations
private extension HomeViewModel {
    
    func presentEditMainMandaratViewController(_ mainMandaratVO: MainMandaratVO) {
        
        let viewModel: EditMainMandaratViewModel = .init(mainMandaratVO)
        viewModel.delegate = self
        
        let viewController = EditMainMandaratViewController()
        viewController.bind(reactor: viewModel)
        
        router.present(viewController, animated: true, modalPresentationSytle: .custom)
    }
}


// MARK: MainMandaratViewModelDelegate
extension HomeViewModel {
    
    func mainMandarat(buttonClicked position: MandaratPosition) {
        
        self.action.onNext(.addMainMandaratButtonClicked(position))
    }
}


// MARK: Create main mandarat reactors
private extension HomeViewModel {
    
    func createMainMandaratReactors() {
        
        // MARK: MainMandaratViewModels
        var mainMandaratReactors: [MandaratPosition: MainMandaratViewModel] = [:]
        
        MandaratPosition.allCases.forEach { position in
            
            let reactor: MainMandaratViewModel = .init(position: position)
            reactor.delegate = self
            mainMandaratReactors[position] = reactor
        }
        
        self.mainMandaratViewReactors = mainMandaratReactors
    }
}


// MARK: EditMainMandaratViewModelDelegate
extension HomeViewModel {
    
    func editFinishedWithSavingRequest(mainMandarat edited: MainMandaratVO) {
        
        action.onNext(.mandaratUpdated(edited))
        
        mandaratUseCase.saveMainMandarat(mainMandarat: edited)
    }
}
