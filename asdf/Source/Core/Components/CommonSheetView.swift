//
//  CommonSheetView.swift
//  asdf
//
//  Created by 咸鱼悠游 on 2026/4/14.
//

import Foundation
import UIKit
import SnapKit

final class CommonSheetView: UIView {
    
    struct Action {
        enum Style {
            case primary
            case secondary
        }
        
        let title: String
        let style: Style
        let handler: (() -> Void)?
        
        init(title: String, style: Style = .primary, handler: (() -> Void)? = nil) {
            self.title = title
            self.style = style
            self.handler = handler
        }
    }
    
    struct Configuration {
        let titleImage: UIImage?
        let title: String?
        let message: String?
        let primaryAction: Action
        let secondaryAction: Action?
        let showsCloseButton: Bool
        let allowsTapToDismiss: Bool
        let showsContactSupport: Bool
        let contactHandler: (() -> Void)?
        let onDismiss: (() -> Void)?
        
        init(titleImage: UIImage? = nil,
             title: String? = nil,
             message: String? = nil,
             primaryAction: Action,
             secondaryAction: Action? = nil,
             showsCloseButton: Bool = true,
             allowsTapToDismiss: Bool = true,
             showsContactSupport: Bool = false,
             contactHandler: (() -> Void)? = nil,
             onDismiss: (() -> Void)? = nil) {
            self.titleImage = titleImage
            self.title = title
            self.message = message
            self.primaryAction = primaryAction
            self.secondaryAction = secondaryAction
            self.showsCloseButton = showsCloseButton
            self.allowsTapToDismiss = allowsTapToDismiss
            self.showsContactSupport = showsContactSupport
            self.contactHandler = contactHandler
            self.onDismiss = onDismiss
        }
    }
    
    private enum Metrics {
        static let cornerRadius: CGFloat = 26
        static let actionHeight: CGFloat = 52
        static let dismissTranslationThreshold: CGFloat = 120
        static let dismissVelocityThreshold: CGFloat = 1200
        static let overlayAlpha: CGFloat = 0.36
    }
    
    private enum Palette {
        static let cardBackground = UIColor.white
        static let title = UIColor(hex: "#111111")
        static let message = UIColor(hex: "#2B2B2B")
        static let primaryBlue = UIColor(hex: "#1548C9")
        static let secondaryBlue = UIColor(hex: "#1A49C1")
        static let indicator = UIColor(hex: "#DEDEDE")
        static let close = UIColor(hex: "#2F2F2F")
        static let imageBackground = UIColor(hex: "#EAF8FF")
        static let overlay = UIColor.black.withAlphaComponent(Metrics.overlayAlpha)
    }
    
    private let configuration: Configuration
    private var isDismissing = false
    
    private lazy var dimmingView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleBackgroundTap))
        view.addGestureRecognizer(tap)
        return view
    }()
    
    private lazy var sheetContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = Palette.cardBackground
        view.layer.cornerRadius = Metrics.cornerRadius
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.layer.masksToBounds = true
        return view
    }()
    
    private lazy var dragIndicatorView: UIView = {
        let view = UIView()
        view.backgroundColor = Palette.indicator
        view.layer.cornerRadius = 2
        return view
    }()
    
    private lazy var closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = Palette.close
        button.setImage(
            UIImage(systemName: "xmark")?.withConfiguration(
                UIImage.SymbolConfiguration(pointSize: 16, weight: .medium)
            ),
            for: .normal
        )
        button.addTarget(self, action: #selector(handleCloseTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var iconWrapperView = UIView()
    
    private lazy var iconBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = Palette.imageBackground
        view.layer.cornerRadius = 22
        view.layer.masksToBounds = true
        return view
    }()
    
    private lazy var iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .dmSansFont(ofSize: 18, weight: .bold)
        label.textColor = Palette.title
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var messageLabel: UILabel = {
        let label = UILabel()
        label.font = .dmSansFont(ofSize: 14, weight: .regular)
        label.textColor = Palette.message
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var primaryButton: UIButton = makeActionButton()
    private lazy var secondaryButton: UIButton = makeActionButton()
    
    private lazy var assistanceLabel1: UILabel = {
        let label = UILabel()
        label.font = .dmSansFont(ofSize: 14, weight: .regular)
        label.textColor = Palette.message
        label.textAlignment = .center
        label.text = "Need assistance?"
        return label
    }()
    
    private lazy var assistanceLabel2: UILabel = {
        let label = UILabel()
        label.font = .dmSansFont(ofSize: 14, weight: .regular)
        label.textColor = Palette.message
        label.textAlignment = .center
        label.text = "now!"
        return label
    }()
    
    private lazy var contactButton: UIButton = {
        let button = UIButton(type: .custom)
        button.titleLabel?.font = .dmSansFont(ofSize: 14, weight: .bold)
        button.setTitle("Contact KDi GO", for: .normal)
        button.setTitleColor(Palette.secondaryBlue, for: .normal)
        button.addTarget(self, action: #selector(handleContactTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var assistanceContainerView = UIView()
    
    private lazy var assistanceStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [assistanceLabel1, contactButton, assistanceLabel2])
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.spacing = 4
        return stackView
    }()
    
    private lazy var contentStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [
            iconWrapperView,
            titleLabel,
            messageLabel,
            primaryButton,
            secondaryButton,
            assistanceContainerView
        ])
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.setCustomSpacing(24, after: iconWrapperView)
        stackView.setCustomSpacing(14, after: titleLabel)
        stackView.setCustomSpacing(24, after: messageLabel)
        stackView.setCustomSpacing(21, after: secondaryButton)
        return stackView
    }()
    
    init(configuration: Configuration) {
        self.configuration = configuration
        super.init(frame: .zero)
        setupViews()
        applyConfiguration()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func present(in parentView: UIView? = nil) {
        guard let hostView = parentView ?? Self.topMostViewController()?.view else { return }
        
        frame = hostView.bounds
        autoresizingMask = [.flexibleWidth, .flexibleHeight]
        hostView.addSubview(self)
        layoutIfNeeded()
        
        let startTranslation = max(sheetContainerView.bounds.height, 320)
        sheetContainerView.transform = CGAffineTransform(translationX: 0, y: startTranslation)
        dimmingView.backgroundColor = .clear
        
        UIView.animate(withDuration: 0.22) {
            self.dimmingView.backgroundColor = Palette.overlay
        }
        
        UIView.animate(.spring(response: 0.5, dampingFraction: 0.7)) {
            self.sheetContainerView.transform = .identity
        }
    }
    
    func dismiss(animated: Bool = true, completion: (() -> Void)? = nil) {
        guard !isDismissing else { return }
        isDismissing = true
        
        let finishDismiss = {
            self.removeFromSuperview()
            self.isDismissing = false
            self.configuration.onDismiss?()
            completion?()
        }
        
        guard animated else {
            finishDismiss()
            return
        }
        
        let endTranslation = max(sheetContainerView.bounds.height + 48, 320)
        UIView.animate(withDuration: 0.25) {
            self.dimmingView.backgroundColor = .clear
            self.sheetContainerView.transform = CGAffineTransform(translationX: 0, y: endTranslation)
        } completion: { _ in
            finishDismiss()
        }
    }
}

private extension CommonSheetView {
    
    func setupViews() {
        backgroundColor = .clear
        
        addSubview(dimmingView)
        addSubview(sheetContainerView)
        
        dimmingView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        sheetContainerView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
        }
        
        sheetContainerView.addSubview(dragIndicatorView)
        sheetContainerView.addSubview(closeButton)
        sheetContainerView.addSubview(contentStackView)
        iconWrapperView.addSubview(iconBackgroundView)
        iconBackgroundView.addSubview(iconImageView)
        assistanceContainerView.addSubview(assistanceStackView)
        
        dragIndicatorView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.centerX.equalToSuperview()
            make.width.equalTo(60)
            make.height.equalTo(4)
        }
        
        closeButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.trailing.equalToSuperview().inset(18)
            make.size.equalTo(CGSize(width: 28, height: 28))
        }
        
        contentStackView.snp.makeConstraints { make in
            make.top.equalTo(dragIndicatorView.snp.bottom).offset(22)
            make.leading.trailing.equalToSuperview().inset(24)
            make.bottom.equalTo(sheetContainerView.safeAreaLayoutGuide.snp.bottom).inset(18)
        }
        
        iconWrapperView.snp.makeConstraints { make in
            make.height.equalTo(88)
        }
        
        iconBackgroundView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(CGSize(width: 88, height: 88))
        }
        
        iconImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.lessThanOrEqualTo(CGSize(width: 56, height: 56))
        }
        
        primaryButton.snp.makeConstraints { make in
            make.height.equalTo(Metrics.actionHeight)
        }
        
        secondaryButton.snp.makeConstraints { make in
            make.height.equalTo(Metrics.actionHeight)
        }
        
        assistanceStackView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.greaterThanOrEqualToSuperview()
            make.trailing.lessThanOrEqualToSuperview()
            make.top.bottom.equalToSuperview()
        }
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        sheetContainerView.addGestureRecognizer(panGesture)
        
        primaryButton.addTarget(self, action: #selector(handlePrimaryTapped), for: .touchUpInside)
        secondaryButton.addTarget(self, action: #selector(handleSecondaryTapped), for: .touchUpInside)
    }
    
    func applyConfiguration() {
        closeButton.isHidden = !configuration.showsCloseButton
        
        let hasImage = configuration.titleImage != nil
        iconWrapperView.isHidden = !hasImage
        iconImageView.image = configuration.titleImage
        
        let hasTitle = !normalized(configuration.title).isEmpty
        titleLabel.isHidden = !hasTitle
        titleLabel.text = configuration.title
        
        let hasMessage = !normalized(configuration.message).isEmpty
        messageLabel.isHidden = !hasMessage
        messageLabel.text = configuration.message
        
        apply(action: configuration.primaryAction, to: primaryButton)
        
        if let secondaryAction = configuration.secondaryAction {
            secondaryButton.isHidden = false
            apply(action: secondaryAction, to: secondaryButton)
        } else {
            secondaryButton.isHidden = true
        }
        
        assistanceContainerView.isHidden = !configuration.showsContactSupport
    }
    
    func makeActionButton() -> UIButton {
        let button = UIButton(type: .system)
        button.layer.cornerRadius = 10
        button.layer.masksToBounds = true
        button.titleLabel?.font = .dmSansFont(ofSize: 16, weight: .bold)
        return button
    }
    
    func apply(action: Action, to button: UIButton) {
        button.setTitle(action.title, for: .normal)
        
        switch action.style {
        case .primary:
            button.backgroundColor = Palette.primaryBlue
            button.setTitleColor(.white, for: .normal)
        case .secondary:
            button.backgroundColor = .clear
            button.setTitleColor(Palette.secondaryBlue, for: .normal)
        }
    }
    
    func normalized(_ text: String?) -> String {
        text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
    }
    
    static func topMostViewController(base: UIViewController? = nil) -> UIViewController? {
        let rootViewController: UIViewController? = {
            if let base {
                return base
            }
            
            return UIApplication.shared.connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .flatMap(\.windows)
                .first(where: \.isKeyWindow)?
                .rootViewController
        }()
        
        if let navigationController = rootViewController as? UINavigationController {
            return topMostViewController(base: navigationController.visibleViewController)
        }
        
        if let tabBarController = rootViewController as? UITabBarController,
           let selectedViewController = tabBarController.selectedViewController {
            return topMostViewController(base: selectedViewController)
        }
        
        if let presentedViewController = rootViewController?.presentedViewController {
            return topMostViewController(base: presentedViewController)
        }
        
        return rootViewController
    }
    
    @objc func handleBackgroundTap() {
        guard configuration.allowsTapToDismiss else { return }
        dismiss()
    }
    
    @objc func handleCloseTapped() {
        dismiss()
    }
    
    @objc func handlePrimaryTapped() {
        dismiss { [configuration] in
            configuration.primaryAction.handler?()
        }
    }
    
    @objc func handleSecondaryTapped() {
        guard let secondaryAction = configuration.secondaryAction else { return }
        dismiss { [secondaryAction] in
            secondaryAction.handler?()
        }
    }
    
    @objc func handleContactTapped() {
        dismiss { [configuration] in
            configuration.contactHandler?()
        }
    }
    
    @objc func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        let translationY = gesture.translation(in: self).y
        
        switch gesture.state {
        case .changed:
            guard translationY > 0 else { return }
            sheetContainerView.transform = CGAffineTransform(translationX: 0, y: translationY)
            let progress = min(translationY / 220, 1)
            dimmingView.backgroundColor = Palette.overlay.withAlphaComponent((1 - progress) * Metrics.overlayAlpha)
        case .ended, .cancelled:
            let velocityY = gesture.velocity(in: self).y
            if translationY > Metrics.dismissTranslationThreshold || velocityY > Metrics.dismissVelocityThreshold {
                dismiss()
            } else {
                UIView.animate(withDuration: 0.34,
                               delay: 0,
                               usingSpringWithDamping: 0.84,
                               initialSpringVelocity: 0.78,
                               options: [.curveEaseOut, .allowUserInteraction]) {
                    self.sheetContainerView.transform = .identity
                    self.dimmingView.backgroundColor = Palette.overlay
                }
            }
        default:
            break
        }
    }
}

extension CommonSheetView {
    
    @discardableResult
    static func show(in parentView: UIView? = UIApplication.shared.windows.first { $0.isKeyWindow }, configuration: Configuration) -> CommonSheetView {
        let sheetView = CommonSheetView(configuration: configuration)
        sheetView.present(in: parentView)
        return sheetView
    }
    
    @discardableResult
    static func show(in viewController: UIViewController, configuration: Configuration) -> CommonSheetView {
        show(in: viewController.view, configuration: configuration)
    }
}
