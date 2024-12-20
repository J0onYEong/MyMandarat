//
//  HomeViewController.swift
//  Home
//
//  Created by choijunios on 12/4/24.
//

import UIKit

import DomainMandaratInterface

import ReactorKit
import RxCocoa

class HomeViewController: UIViewController, View {
    
    // Sub view
    private var mainMandaratViews: [MandaratPosition: MainMandaratView] = [:]
    fileprivate var mainMandaratContainerView: UIStackView!
    
    // Color picker
    private let selectedColor: PublishSubject<UIColor> = .init()
    private var editingColor: UIColor?
    
    var disposeBag: DisposeBag = .init()
    
    init(reactor: HomeViewModel) {
        
        super.init(nibName: nil, bundle: nil)
        
        createMainMandaratViews()
        
        self.reactor = reactor
    }
    required init?(coder: NSCoder) { nil }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        setLayout()
        
        reactor?.sendEvent(.viewDidLoad)
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        reactor?.sendEvent(.viewDidAppear)
    }
    
    
    func bind(reactor: HomeViewModel) {
        
        // Bind reactors to MainMandaratViews
        MandaratPosition.allCases.forEach { position in
            
            let mainMandaratReactor = reactor.mainMandaratViewReactors[position]!
            
            mainMandaratViews[position]?.bind(reactor: mainMandaratReactor)
        }
        
        
        // Transition animation
        reactor.state
            .compactMap(\.positionToMoveCenter)
            .withUnretained(self)
            .subscribe(onNext: { vc, position in
                
                vc.focusingMainMandaratCell(selected: position) { completed in
                    
                    if completed {
                        vc.reactor?.action.onNext(.moveMandaratToCenterFinished(position))
                    }
                    
                }
            })
            .disposed(by: disposeBag)
        
        reactor.state
            .map(\.viewAction)
            .distinctUntilChanged()
            .compactMap({ $0 })
            .withUnretained(self)
            .subscribe(onNext: { vc, viewAction in
                
                switch viewAction {
                case .replaceMainMandarats(let position):
                    
                    vc.resetMainMandaratPositions(selected: position) { completed in
                        
                        if completed {
                            
                            vc.reactor?.sendEvent(.resetMainMandaratsFinished)
                        }
                    }
                }
                
            })
            .disposed(by: disposeBag)
    }
    
    private func setLayout() {
        
        setMainMandaratViewLayout()
    }
}

private extension HomeViewController {
    
    func setMainMandaratViewLayout() {
        
        // MARK: Main mandarat views
        let mandaratRows: [[MandaratPosition]] = [
            
            // row1
            [.ONE_ONE, .ONE_TWO, .ONE_TRD],
            
            // row2
            [.TWO_ONE, .TWO_TWO, .TWO_TRD],
            
            // row3
            [.TRD_ONE, .TRD_TWO, .TRD_TRD],
        ]
        
        let rowStackViews: [UIStackView] = mandaratRows.map { rowItems in
            
            let stackView: UIStackView = .init(
                arrangedSubviews: getMainMandaratViews(rowItems)
            )
            stackView.axis = .horizontal
            stackView.spacing = 5
            stackView.distribution = .fillEqually
            stackView.alignment = .fill
            return stackView
        }
        
        let mainMandaratContainerStackView: UIStackView = .init(
            arrangedSubviews: rowStackViews
        )
        mainMandaratContainerStackView.axis = .vertical
        mainMandaratContainerStackView.spacing = 5
        mainMandaratContainerStackView.distribution = .fillEqually
        mainMandaratContainerStackView.alignment = .fill
        
        
        view.addSubview(mainMandaratContainerStackView)
        
        mainMandaratContainerStackView.snp.makeConstraints { make in
            
            make.leading.equalTo(view.safeAreaLayoutGuide.snp.leading)
            make.trailing.equalTo(view.safeAreaLayoutGuide.snp.trailing)
            
            // width == height
            make.height.equalTo(mainMandaratContainerStackView.snp.width)
            
            // y position
            make.centerY.equalToSuperview()
        }
        
        self.mainMandaratContainerView = mainMandaratContainerStackView
    }
}

// MARK: MainMandarats
private extension HomeViewController {
    
    func createMainMandaratViews() {
        
        MandaratPosition.allCases.forEach { mandaratPosition in
            let view = MainMandaratView()
            self.mainMandaratViews[mandaratPosition] = view
        }
    }
    
    
    func getMainMandaratViews(_ positions: [MandaratPosition]) -> [MainMandaratView] {
        
        return positions.map { position in
            
            self.mainMandaratViews[position]!
        }
    }
    
    
    func makeMainMandaratViewToTop(_ position: MandaratPosition) {
        
        let targetView = mainMandaratViews[position]!
        targetView.superview?.layer.sublayers?.forEach({ $0.zPosition = 0 })
        targetView.layer.zPosition = 1
        
        mainMandaratContainerView.layer.sublayers?.forEach({ $0.zPosition = 0 })
        targetView.superview?.layer.zPosition = 1
    }
}


// MARK: Animation
private extension HomeViewController {
    
    func resetMainMandaratPositions(selected position: MandaratPosition, completion: @escaping (Bool) -> ()) {
        
        UIView.animate(withDuration: 0.4, animations: {
            
            self.mainMandaratViews.filter({ key, _ in key != position }).values.forEach { mainMandaratView in
                
                mainMandaratView.alpha = 1
            }
            
            self.mainMandaratViews[position]!.moveToIdentity()
            
        }, completion: completion)
    }
    
    
    func focusingMainMandaratCell(selected position: MandaratPosition, completion: @escaping (Bool) -> ()) {
        
        // 선택된 셀을 최상단으로 이동
        makeMainMandaratViewToTop(position)
        
        
        // 중앙 좌표구하기
        let containerSize = mainMandaratContainerView.bounds
        let middlePosition: CGPoint = .init(
            x: containerSize.width/2,
            y: containerSize.height/2
        )
        
        let selectedMainMandaratView = mainMandaratViews[position]!
        
        let positionFittedToView = mainMandaratContainerView.convert(middlePosition, to: selectedMainMandaratView)
        
        UIView.animate(withDuration: 0.3, animations: {
            
            // 선택된 뷰를 중앙으로 이동
            selectedMainMandaratView.moveCenter(point: positionFittedToView)
            
            // 다른 뷰들은 사라짐
            self.mainMandaratViews
                .filter({ (pos, _) in pos != position })
                .values
                .forEach { mainMandaratView in
                    
                    mainMandaratView.alpha = 0
                }
            
        }, completion: completion)
    }
}
