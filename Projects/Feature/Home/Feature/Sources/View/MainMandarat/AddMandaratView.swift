//
//  AddMandaratView.swift
//  Home
//
//  Created by choijunios on 12/7/24.
//

import UIKit

import SharedDesignSystem

import RxSwift
import SnapKit

class AddMandaratView: TappableView {
    
    // Sub view
    private let plusIconView: UIImageView = {
        let image = UIImage(systemName: "plus.square.fill")
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .black
        return imageView
    }()
    
    // Public interface
    public let present: PublishSubject<Bool> = .init()
    
    private let disposeBag: DisposeBag = .init()
    
    init() {
        super.init(frame: .zero)
        
        setLayer()
        setLayout()
        setTapEffect()
    }
    required init?(coder: NSCoder) { nil }
    
    private func setLayer() {
        
        layer.cornerRadius = MainMandaratUIConfig.cornerRadius
        layer.backgroundColor = UIColor.gray.cgColor
    }
    
    private func setLayout() {
        
        addSubview(plusIconView)
        
        plusIconView
            .snp.makeConstraints { make in
                
                make.width.equalTo(32)
                make.height.equalTo(plusIconView.snp.width)
                make.center.equalToSuperview()
            }
        
    }
    
    private func setTapEffect() {
        
        self.tap
            .subscribe(onNext: { _ in
                
                // Animation for tap event
                
            })
            .disposed(by: disposeBag)
    }
}

#Preview {
    
    AddMandaratView()
}
