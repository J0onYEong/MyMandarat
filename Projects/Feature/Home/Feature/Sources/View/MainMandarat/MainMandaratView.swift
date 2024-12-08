//
//  MainMandaratView.swift
//  Home
//
//  Created by choijunios on 12/7/24.
//

import UIKit

import SharedDesignSystem

import ReactorKit

final class MainMandaratView: UIView, View {
    
    // View
    private let addMandaratView: AddMandaratView = .init()
    
    var disposeBag: DisposeBag = .init()
    
    var reactor: MainMandaratViewModel?
    
    init() {
        
        super.init(frame: .zero)
        
        setLayer()
    }
    required init?(coder: NSCoder) { nil }
    
    func bind(reactor: MainMandaratViewModel) {
        
        self.reactor = reactor
        
        // Add MainMandarat button clicked
        addMandaratView.tap
            .map { _ in
                return Reactor.Action.addMandaratButtonClicked
            }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
            
        
        // Presentation for add mandarat
        reactor.state
            .map(\.isAvailable)
            .bind(to: addMandaratView.rx.isHidden)
            .disposed(by: disposeBag)
    }
    
    private func setLayer() {
        
        addSubview(addMandaratView)
        
        addMandaratView.snp.makeConstraints { make in
            
            make.edges.equalToSuperview()
        }
    }
}
