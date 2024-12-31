//
//  MainMandaratCoordinator.swift
//  Home
//
//  Created by choijunios on 12/26/24.
//

import UIKit

import FeatureSubMandarat
import FeatureSetting

import DomainMandaratInterface
import SharedPresentationExt

class MainMandaratRouter: MainMandaratRoutable, MainMandaratPageRouting {
    
    private let navigationController: UINavigationController
    
    private let subMandaratBuilder: SubMandaratPageBuildable
    private let settingPageBuilder: SettingPageBuildable
    
    
    init(
        subMandaratBuilder: SubMandaratPageBuildable,
        settingPageBuilder: SettingPageBuildable,
        navigationController: UINavigationController,
        viewModel: MainMandaratPageViewModel,
        viewController: MainMandaratPageViewController)
    {
        self.subMandaratBuilder = subMandaratBuilder
        self.settingPageBuilder = settingPageBuilder
        
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
        
        dettach(router)
        
        let viewController = router.viewController
        
        if navigationController.topViewController === viewController {
            
            navigationController.delegate = viewController.transitionDelegate
            navigationController.popViewController(animated: true)
            navigationController.delegate = nil
        }
    }
    
    
    func presentEditMainMandaratPage(mainMandarat: MainMandaratVO) {
        
        // 메인 만다라트 화면과 결합력이 강해 빌더를 따로 만들지 않았습니다.
        
        let viewModel: EditMainMandaratViewModel = .init(mainMandarat)
        
        if let listener = self.viewModel as? EditMainMandaratViewModelListener {
            
            viewModel.listener = listener
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
    
    
    func pushSettingPage() {
        
        let router = settingPageBuilder.build(interactorListener: viewModel)
        
        let viewController = router.viewController
        
        navigationController.pushViewController(viewController, animated: true)
        
        attach(router)
    }
    
    
    func popSettingPage() {
        
        guard let router = children.first(where: { $0 is SettingPageRoutable }) as? SubMandaratPageRoutable else { return }
        
        dettach(router)
        
        if navigationController.topViewController === router.viewController {
            
            navigationController.popViewController(animated: true)
        }
    }
}
