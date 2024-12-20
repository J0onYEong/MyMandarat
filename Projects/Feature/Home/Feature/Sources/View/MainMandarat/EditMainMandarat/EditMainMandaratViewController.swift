//
//  EditMainMandaratViewController.swift
//  Home
//
//  Created by choijunios on 12/9/24.
//

import UIKit

import SharedDesignSystem

import ReactorKit
import SnapKit

// id, imageURL, title, story, hexColor

class EditMainMandaratViewController: UIViewController, View, UIColorPickerViewControllerDelegate {
    
    // Sub View
    private let backgroundView: TappableView = .init()
    private let titleInputView: FocusTextField = .init()
    private let descriptionInputView: FocusTextView = .init()
    private let inputContainerBackView: UIView = .init()
    private let colorSelectionView: ColorSelectionView = .init(labelText: "대표 색상 변경")
    
    // - Tool button
    private let exitButton: ImageButton = .init(imageName: "xmark")
    private let saveButton: TextButton = .init(text: "저장")
    
    
    // Reactor
    var reactor: EditMainMandaratViewModel?
    private let selectedColor: PublishSubject<UIColor> = .init()
    private let colorPickerClosed: PublishSubject<Void> = .init()
    var disposeBag: DisposeBag = .init()
    
    
    // Transition
    private let transitionDelegate = TransitionDelegate()
    
    
    init() {
        
        super.init(nibName: nil, bundle: nil)
        
        self.transitioningDelegate = transitionDelegate
        
    }
    required init?(coder: NSCoder) { nil }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setBackgroundView()
        setInputFields()
        setLayout()
        subscribeToKeyboardEvent()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.view.layoutIfNeeded()
        
        // MARK: Keyboard
        titleInputView.becomeFirstResponder()
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        setInputContainerView()
    }
    
    
    private func setBackgroundView() {
        
        view.backgroundColor = .clear
        
        backgroundView.backgroundColor = UIColor.gray.withAlphaComponent(0.7)
        let tapGesture: UITapGestureRecognizer = .init()
        backgroundView.addGestureRecognizer(tapGesture)
        tapGesture.addTarget(self, action: #selector(onBackgroundViewTapped))
    }
    
    
    @objc private func onBackgroundViewTapped() {
        
        [
            titleInputView,
            descriptionInputView
        ].forEach { responder in
            if responder.isFirstResponder {
                responder.resignFirstResponder()
            }
        }
    }
    
    
    private func setInputFields() {
        
        titleInputView.backgroundColor = UIColor.gray.withAlphaComponent(0.1)
        titleInputView.setFocusLineColor(.gray)
        titleInputView.setPlaceholderText("만다라트 주제를 입력해주세요!")
        
        descriptionInputView.backgroundColor = UIColor.gray.withAlphaComponent(0.1)
        descriptionInputView.setFocusLineColor(.gray)
        descriptionInputView.setPlaceholderText("목표를 설명해주세요!")
    }
    
    
    private func setLayout() {
        
        // MARK: backgroundView
        view.addSubview(backgroundView)
        
        backgroundView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        
        // MARK: inputContainerBackView
        view.addSubview(inputContainerBackView)
        
        inputContainerBackView.snp.makeConstraints { make in
            make.leading.equalTo(view.safeAreaLayoutGuide.snp.leading)
            make.trailing.equalTo(view.safeAreaLayoutGuide.snp.trailing)
            make.bottom.equalToSuperview()
        }
        
        
        // MARK: toolButtonStack
        let toolButtonStack: UIStackView = .init(
            arrangedSubviews: [saveButton, exitButton]
        )
        toolButtonStack.axis = .horizontal
        toolButtonStack.spacing = 5
        toolButtonStack.distribution = .fill
        toolButtonStack.alignment = .fill
        
        inputContainerBackView.addSubview(toolButtonStack)
        
        toolButtonStack.snp.makeConstraints { make in
            
            make.top.equalToSuperview().inset(40)
            make.trailing.equalToSuperview().inset(20)
        }
        
        
        // MARK: colorSelectionView
        let colorSelectionStackView: UIStackView = .init(
            arrangedSubviews: [colorSelectionView, UIView()]
        )
        colorSelectionStackView.axis = .horizontal
        colorSelectionStackView.distribution = .fill
        colorSelectionStackView.alignment = .center
        
        
        // MARK: inputStackView
        let inputStackView: UIStackView = .init(arrangedSubviews: [
            colorSelectionStackView,
            titleInputView,
            descriptionInputView,
        ])
        inputStackView.axis = .vertical
        inputStackView.spacing = 12
        inputStackView.alignment = .fill
        inputStackView.distribution = .fill
        
        inputContainerBackView.addSubview(inputStackView)
        
        descriptionInputView.snp.makeConstraints { make in
            make.height.equalTo(100)
        }
        
        inputStackView.snp.makeConstraints { make in
            make.top.equalTo(toolButtonStack.snp.bottom).inset(-10)
            make.leading.equalToSuperview().inset(20)
            make.trailing.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().inset(20)
        }
    }
    
    
    func bind(reactor: EditMainMandaratViewModel) {
        
        self.reactor = reactor
        
        
        // MARK: Bind, tool buttons
        exitButton.rx.tap
            .map { _ in
                Reactor.Action.exitButtonClicked
            }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        saveButton.rx.tap
            .map { _ in
                Reactor.Action.saveButtonClicked
            }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        

        // MARK: Bind, titleInputView
        reactor.state
            .map(\.titleText)
            .take(1)
            .bind(to: titleInputView.rx.text)
            .disposed(by: disposeBag)
        
        titleInputView.rx.text
            .compactMap({ $0 })
            .distinctUntilChanged()
            .map { text in
                return Reactor.Action.editTitleText(text: text)
            }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
            
        
        // MARK: Bind, descriptionInputView
        reactor.state
            .map(\.descriptionText)
            .take(1)
            .bind(to: descriptionInputView.text)
            .disposed(by: disposeBag)
        
        descriptionInputView.text
            .compactMap({ $0 })
            .distinctUntilChanged()
            .map { text in
                return Reactor.Action.editDescriptionText(text: text)
            }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        
        // MARK: color selection
        reactor.state
            .compactMap(\.mandaratTitleColor)
            .bind(to: colorSelectionView.rx.color)
            .disposed(by: disposeBag)
        
        reactor.state
            .distinctUntilChanged(at: \.presentColorPicker)
            .filter(\.presentColorPicker)
            .map(\.mandaratTitleColor)
            .withUnretained(self)
            .subscribe(onNext: { vc, prevColor in
                vc.presentColorPicker(
                    titleText: "만다라트 대표 색상",
                    previousColor: prevColor
                )
            })
            .disposed(by: disposeBag)
        
        selectedColor
            .map { color in
                Reactor.Action.editColor(color: color)
            }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        colorPickerClosed
            .map { _ in
                Reactor.Action.colorPickerClosed
            }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        colorSelectionView.rx.colorSelectionTap
            .map { _ in
                Reactor.Action.colorSelectionButtonClicked
            }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
    }
}


// MARK: InputContainerView drawing
private extension EditMainMandaratViewController {
    
    func setInputContainerView() {
        
        inputContainerBackView.backgroundColor = .white
        
        let shapeLayer: CAShapeLayer = .init()
        shapeLayer.frame = inputContainerBackView.bounds
        
        let rect = shapeLayer.bounds
        let minRadius: CGFloat = 30
        let maxRadius: CGFloat = 90
        let path = CGMutablePath()
        path.move(to: .init(x: rect.minX, y: rect.maxY))
        
        path.addLine(to: .init(x: rect.minX, y: minRadius))
        
        path.addCurve(
            to: .init(x: maxRadius, y: rect.minY),
            control1: .init(x: rect.minX, y: rect.minY),
            control2: .init(x: rect.minX, y: rect.minY)
        )
        
        path.addLine(to: .init(x: rect.maxX-maxRadius, y: rect.minY))
        
        path.addCurve(
            to: .init(x: rect.maxX, y: minRadius),
            control1: .init(x: rect.maxX, y: rect.minY),
            control2: .init(x: rect.maxX, y: rect.minY)
        )
        
        path.addLine(to: .init(x: rect.maxX, y: rect.maxY))
        path.addLine(to: .init(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        
        shapeLayer.path = path
        shapeLayer.strokeEnd = 1
        shapeLayer.fillColor = UIColor.white.cgColor
        
        inputContainerBackView.layer.mask = shapeLayer
    }
    
}

// MARK: Color picker
extension EditMainMandaratViewController {
    
    private func presentColorPicker(
        titleText: String,
        previousColor: UIColor?
    ) {
        
        let colorPicker = UIColorPickerViewController()
        colorPicker.title = titleText
        colorPicker.selectedColor = .blue
        colorPicker.supportsAlpha = true
        colorPicker.delegate = self
        colorPicker.modalPresentationStyle = .popover
        if let previousColor {
            colorPicker.selectedColor = previousColor
        }
        
        self.present(colorPicker, animated: true)
    }

    func colorPickerViewControllerDidFinish(_ viewController: UIColorPickerViewController) {
        self.colorPickerClosed.onNext(())
    }
    
    func colorPickerViewController(_ viewController: UIColorPickerViewController, didSelect color: UIColor, continuously: Bool) {
        self.selectedColor.onNext(color)
    }
}

private extension EditMainMandaratViewController {
    
    func subscribeToKeyboardEvent() {
        
        NotificationCenter.default.rx
            .notification(UIApplication.keyboardWillShowNotification)
            .withUnretained(self)
            .subscribe(onNext: { vc, notfication in
                
                guard
                    let keyboardFrame = notfication.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
                    let keyboardDisplayDuration = notfication.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double
                else { return }
                
                UIView.animate(withDuration: keyboardDisplayDuration) {
                    
                    vc.inputContainerBackView.snp.updateConstraints { make in
                        
                        make.bottom.equalToSuperview().inset(CGFloat(keyboardFrame.height))
                    }
                    
                    vc.view.layoutIfNeeded()
                }
            })
            .disposed(by: disposeBag)
        
        NotificationCenter.default.rx
            .notification(UIApplication.keyboardWillHideNotification)
            .withUnretained(self)
            .subscribe(onNext: { vc, notfication in
                
                guard
                    let keyboardDisplayDuration = notfication.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double
                else { return }
                
                UIView.animate(withDuration: keyboardDisplayDuration) {
                    
                    vc.inputContainerBackView.snp.updateConstraints { make in
                        
                        make.bottom.equalToSuperview()
                    }
                    
                    vc.view.layoutIfNeeded()
                }
            })
            .disposed(by: disposeBag)
    }
}


// MARK: Transition
private extension EditMainMandaratViewController {
    
    func onAppearTask(duration: CFTimeInterval, context: UIViewControllerContextTransitioning) {
        
        let containerView = context.containerView
        containerView.addSubview(view)
        
        // MARK: Animation
        view.layoutIfNeeded()
        let height = self.inputContainerBackView.layer.bounds.height
        inputContainerBackView.transform = .init(translationX: 0, y: height)
        backgroundView.alpha = 0
        
        UIView.animate(withDuration: duration) {
            
            self.backgroundView.alpha = 1
            
            self.inputContainerBackView.transform = .identity
            
        } completion: { completed in
            
            context.completeTransition(completed)
        }
    }
    
    func onDissmissTask(duration: CFTimeInterval, context: UIViewControllerContextTransitioning) {
        
        UIView.animate(withDuration: duration) {
            
            self.backgroundView.alpha = 0
            
            let height = self.inputContainerBackView.layer.bounds.height
            self.inputContainerBackView.transform = .init(translationX: 0, y: height)
            
        } completion: { [weak self] completed in
            
            self?.view.removeFromSuperview()
            context.completeTransition(completed)
        }
    }
    
    class TransitionDelegate: NSObject, UIViewControllerTransitioningDelegate {
        
        func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> (any UIViewControllerAnimatedTransitioning)? {
            PresentAnimation()
        }
        
        func animationController(forDismissed dismissed: UIViewController) -> (any UIViewControllerAnimatedTransitioning)? {
            DismissAnimation()
        }
    }
    
    class PresentAnimation: NSObject, UIViewControllerAnimatedTransitioning {
        func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
            return 0.25
        }

        func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
            guard let viewController = transitionContext.viewController(forKey: .to) as? EditMainMandaratViewController else { return }
            
            viewController.onAppearTask(
                duration: transitionDuration(using: transitionContext),
                context: transitionContext
            )
        }
    }

    class DismissAnimation: NSObject, UIViewControllerAnimatedTransitioning {
        func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
            return 0.25
        }

        func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
            guard let viewController = transitionContext.viewController(forKey: .from) as? EditMainMandaratViewController else { return }
            
            viewController.onDissmissTask(
                duration: transitionDuration(using: transitionContext),
                context: transitionContext
            )
        }
    }
}


