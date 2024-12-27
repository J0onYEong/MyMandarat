//
//  MainMandaratCoordinator.swift
//  Home
//
//  Created by choijunios on 12/26/24.
//

import UIKit

import FeatureSubMandarat
import DomainMandaratInterface
import SharedPresentationExt

protocol MainMandaratPageRouting: AnyObject {
    
    func presentEditMainMandaratPage(mainMandarat: MainMandaratVO)
    
    func dismissEditMainMandaratPage()

    func presentSubMandaratPage(mainMandarat: MainMandaratVO)
    
    func dismissSubMandaratPage()
}

class MainMandaratRouter: MainMandaratRoutable, MainMandaratPageRouting {
    
    private let navigationController: UINavigationController
    private let subMandaratBuilder: SubMandaratPageBuildable
    
    
    init(
        subMandaratBuilder: SubMandaratPageBuildable,
        navigationController: UINavigationController,
        viewModel: MainMandaratPageViewModel,
        viewController: MainMandaratPageViewController)
    {
        self.subMandaratBuilder = subMandaratBuilder
        self.navigationController = navigationController
        
        super.init(viewModel: viewModel, viewController: viewController)
        
        viewModel.router = self
    }
}


// MARK: MainMandaratPageRouting
extension MainMandaratRouter {
    
    func presentSubMandaratPage(mainMandarat: MainMandaratVO) {
        
        let router = subMandaratBuilder.build(mainMandaratVO: mainMandarat)
        
        let viewModel = router.viewModel
        
        if let listener = self.viewModel as? SubMandaratPageViewModelListener {
            viewModel.listener = listener
        }
        
        let viewController = router.viewController
        
        navigationController.delegate = viewController.transitionDelegate
        navigationController.pushViewController(viewController, animated: true)
        navigationController.delegate = nil
        
        attach(router)
    }
    
    
    func dismissSubMandaratPage() {
        
        guard let router = children.first(where: { $0 is SubMandaratPageRoutable }) as? SubMandaratPageRoutable else { return }
        
        let viewController = router.viewController
        
        if navigationController.topViewController === viewController {
            
            navigationController.delegate = viewController.transitionDelegate
            navigationController.popViewController(animated: true)
            navigationController.delegate = nil
            
            dettach(router)
        }
    }
    
    
    func presentEditMainMandaratPage(mainMandarat: MainMandaratVO) {
        
        // 메인 만다라트 화면과 결합력이 강해 빌더를 따로 만들지 않았습니다.
        
        let viewModel: EditMainMandaratViewModel = .init(mainMandarat)
        viewModel.router = self
        
        if let delegate = self.viewModel as? EditMainMandaratViewModelDelegate {
            
            viewModel.delegate = delegate
        }
        
        let viewController = EditMainMandaratViewController()
        viewController.bind(reactor: viewModel)
        
        
        viewController.modalPresentationStyle = .custom
        navigationController.present(
            viewController,
            animated: true
        )
    }
    
    
    func dismissEditMainMandaratPage() {
        
        if navigationController.presentedViewController is EditMainMandaratViewController {
            
            navigationController.dismiss(animated: true)
        }
    }
}
