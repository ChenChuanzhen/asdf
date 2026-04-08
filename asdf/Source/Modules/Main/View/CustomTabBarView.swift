import UIKit
import SnapKit

fileprivate enum CustomTabBarLayout {
    static let barHeight: CGFloat = 64
    static let horizontalInset: CGFloat = 14
    static let bottomInset: CGFloat = 10
    static let capsuleHorizontalInset: CGFloat = 12
    static let buttonSpacing: CGFloat = 2
    static let sideItemWidth: CGFloat = 72
    static let centerButtonSize: CGFloat = 52
    static let centerButtonInnerSize: CGFloat = 44
    static let centerSlotWidth: CGFloat = 84
    static let labelTopSpacing: CGFloat = 2
    static let iconSize: CGFloat = 17
    static let activePillHeight: CGFloat = 54
    static let activePillHorizontalInset: CGFloat = 2
    static let activePillCornerRadius: CGFloat = 27
    static let activePillGlowInset: CGFloat = 3
    static let overallHeight: CGFloat = 92
}

protocol CustomTabBarViewDelegate: AnyObject {
    func customTabBar(_ tabBar: CustomTabBarView, didSelectIndex index: Int)
    func customTabBarDidSelectCenterButton(_ tabBar: CustomTabBarView)
}

final class CustomTabBarView: UIView {

    weak var delegate: CustomTabBarViewDelegate?
    
    private var selectedIndex: Int = 0
    private var itemViews: [TabItemView] = []
    private var lastIndicatorFrame: CGRect = .zero
    private var hasAppliedInitialSelectionIndicator = false
    /// 共享胶囊外发光层：位于主胶囊外侧，提供柔和的液态扩散感
    private let selectionGlowView = UIView()
    /// 共享胶囊主体层：在四个 Tab 之间滑动的主背景块，承担选中态的主要形状与底色
    private let selectionPillView = UIView()
    /// 共享胶囊顶部高光层：叠加在主体层上方，模拟胶囊表面的受光高光
    private let selectionHighlightView = UIView()
    /// 共享胶囊流光层：在切换时做横向流动，增强“液态滑移”的动态质感
    private let selectionSheenView = UIView()
    /// 共享胶囊流光渐变层：提供 selectionSheenView 的实际渐变内容
    private let selectionSheenLayer = CAGradientLayer()
    
    private let shadowContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.08
        view.layer.shadowOffset = CGSize(width: 0, height: 8)
        view.layer.shadowRadius = 16
        return view
    }()
    
    private let backgroundContainer: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white.withAlphaComponent(0.035)
        view.layer.cornerRadius = CustomTabBarLayout.barHeight / 2
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.white.withAlphaComponent(0.16).cgColor
        view.clipsToBounds = true
        return view
    }()
    
    private let blurView: UIVisualEffectView = {
        let effect = UIBlurEffect(style: .systemThinMaterial)
        let view = UIVisualEffectView(effect: effect)
        view.isUserInteractionEnabled = false
        view.alpha = 0.90
        return view
    }()
    
    private let overlayView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white.withAlphaComponent(0.01)
        view.isUserInteractionEnabled = false
        return view
    }()
    
    /// 灰雾染色层：给系统模糊补一层偏灰的雾面质感，避免看起来像纯系统默认毛玻璃
    private let mistTintView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 0.42, green: 0.45, blue: 0.50, alpha: 0.16)
        view.isUserInteractionEnabled = false
        return view
    }()
    
    /// 冷色调校正层：轻微加入灰蓝色，让玻璃更接近参考图里的冷调半透明材质
    private let coolTintView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 0.30, green: 0.36, blue: 0.46, alpha: 0.08)
        view.isUserInteractionEnabled = false
        return view
    }()
    
    /// 顶部高光承载层：用于放置顶部高光渐变，模拟玻璃上沿被环境光照到的反射
    private let topHighlightView: UIView = {
        let view = UIView()
        view.isUserInteractionEnabled = false
        return view
    }()
    
    /// 中部反射层：承载纵向反光渐变，让底栏更像真实玻璃而不是普通半透明背景
    private let glassReflectionView: UIView = {
        let view = UIView()
        view.isUserInteractionEnabled = false
        return view
    }()
    
    /// 底部压暗层：轻微压住底部亮度，增加玻璃厚度感，同时避免底部内容过亮影响可读性
    private let bottomTintView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.035)
        view.isUserInteractionEnabled = false
        return view
    }()
    
    private let topHighlightLayer = CAGradientLayer()
    private let glassReflectionLayer = CAGradientLayer()
    private let mistGradientLayer = CAGradientLayer()
    private let contentStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .center
        stack.distribution = .fill
        stack.spacing = CustomTabBarLayout.buttonSpacing
        return stack
    }()
    
    private lazy var centerButton: UIButton = {
        let button = UIButton(type: .custom)
        button.backgroundColor = UIColor(red: 0.16, green: 0.42, blue: 0.15, alpha: 0.98)
        button.layer.cornerRadius = CustomTabBarLayout.centerButtonSize / 2
        button.layer.shadowColor = UIColor(red: 0.07, green: 0.12, blue: 0.06, alpha: 1).cgColor
        button.layer.shadowOpacity = 0.28
        button.layer.shadowOffset = CGSize(width: 0, height: 10)
        button.layer.shadowRadius = 18
        button.addTarget(self, action: #selector(centerButtonTapped), for: .touchUpInside)
        
        let innerCircle = UIView()
        innerCircle.isUserInteractionEnabled = false
        innerCircle.backgroundColor = UIColor(red: 0.12, green: 0.33, blue: 0.11, alpha: 0.94)
        innerCircle.layer.cornerRadius = CustomTabBarLayout.centerButtonInnerSize / 2
        button.addSubview(innerCircle)
        innerCircle.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(CustomTabBarLayout.centerButtonInnerSize)
        }
        
        let innerHighlight = UIView()
        innerHighlight.isUserInteractionEnabled = false
        innerHighlight.backgroundColor = UIColor.white.withAlphaComponent(0.10)
        innerHighlight.layer.cornerRadius = 11
        innerCircle.addSubview(innerHighlight)
        innerHighlight.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview().inset(4)
            make.height.equalTo(10)
        }
        
        let iconView = UIImageView(image: UIImage(systemName: "sparkle.magnifyingglass"))
        iconView.tintColor = UIColor(red: 0.74, green: 0.95, blue: 0.66, alpha: 1)
        iconView.contentMode = .scaleAspectFit
        iconView.isUserInteractionEnabled = false
        button.addSubview(iconView)
        iconView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(20)
        }
        
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupItems()
        updateSelectionState(animated: false)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .clear
        
        addSubview(shadowContainer)
        shadowContainer.addSubview(backgroundContainer)
        backgroundContainer.addSubview(blurView)
        backgroundContainer.addSubview(overlayView)
        backgroundContainer.addSubview(mistTintView)
        backgroundContainer.addSubview(coolTintView)
        backgroundContainer.addSubview(bottomTintView)
        backgroundContainer.addSubview(topHighlightView)
        backgroundContainer.addSubview(glassReflectionView)
        backgroundContainer.addSubview(selectionGlowView)
        backgroundContainer.addSubview(selectionPillView)
        selectionPillView.addSubview(selectionHighlightView)
        selectionPillView.addSubview(selectionSheenView)
        backgroundContainer.addSubview(contentStack)
        
        shadowContainer.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(CustomTabBarLayout.horizontalInset)
            make.bottom.equalTo(safeAreaLayoutGuide.snp.bottom).inset(CustomTabBarLayout.bottomInset)
            make.height.equalTo(CustomTabBarLayout.barHeight)
        }
        
        backgroundContainer.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        blurView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        overlayView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        mistTintView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        coolTintView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(10)
        }
        
        bottomTintView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.56)
        }
        
        topHighlightView.snp.makeConstraints { make in
            make.leading.trailing.top.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.48)
        }
        
        glassReflectionView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.42)
        }
        
        contentStack.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 6, left: CustomTabBarLayout.capsuleHorizontalInset, bottom: 6, right: CustomTabBarLayout.capsuleHorizontalInset))
        }
        
        selectionGlowView.backgroundColor = UIColor.white.withAlphaComponent(0.045)
        selectionGlowView.alpha = 0
        selectionGlowView.isUserInteractionEnabled = false
        
        selectionPillView.backgroundColor = UIColor.white.withAlphaComponent(0.22)
        selectionPillView.alpha = 0
        selectionPillView.isUserInteractionEnabled = false
        
        selectionHighlightView.backgroundColor = UIColor.white.withAlphaComponent(0.08)
        selectionHighlightView.isUserInteractionEnabled = false
        
        selectionSheenView.isUserInteractionEnabled = false
        selectionSheenLayer.colors = [
            UIColor.white.withAlphaComponent(0.0).cgColor,
            UIColor.white.withAlphaComponent(0.10).cgColor,
            UIColor.white.withAlphaComponent(0.0).cgColor
        ]
        selectionSheenLayer.startPoint = CGPoint(x: 0, y: 0.5)
        selectionSheenLayer.endPoint = CGPoint(x: 1, y: 0.5)
        selectionSheenLayer.locations = [0, 0.5, 1]
        selectionSheenView.layer.insertSublayer(selectionSheenLayer, at: 0)
        
        topHighlightLayer.colors = [
            UIColor.white.withAlphaComponent(0.18).cgColor,
            UIColor.white.withAlphaComponent(0.05).cgColor,
            UIColor.white.withAlphaComponent(0.01).cgColor
        ]
        topHighlightLayer.locations = [0, 0.42, 1]
        topHighlightView.layer.insertSublayer(topHighlightLayer, at: 0)
        
        mistGradientLayer.colors = [
            UIColor.white.withAlphaComponent(0.08).cgColor,
            UIColor.white.withAlphaComponent(0.02).cgColor,
            UIColor.black.withAlphaComponent(0.03).cgColor
        ]
        mistGradientLayer.locations = [0, 0.58, 1]
        mistGradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        mistGradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
        mistTintView.layer.insertSublayer(mistGradientLayer, at: 0)
        
        glassReflectionLayer.colors = [
            UIColor.white.withAlphaComponent(0.00).cgColor,
            UIColor.white.withAlphaComponent(0.045).cgColor,
            UIColor.white.withAlphaComponent(0.00).cgColor
        ]
        glassReflectionLayer.startPoint = CGPoint(x: 0, y: 0.5)
        glassReflectionLayer.endPoint = CGPoint(x: 1, y: 0.5)
        glassReflectionLayer.locations = [0, 0.5, 1]
        glassReflectionView.layer.insertSublayer(glassReflectionLayer, at: 0)
        
    }
    
    private func setupItems() {
        let items: [(title: String, icon: String)] = [
            ("Home", "house.fill"),
            ("Portfolio", "chart.line.uptrend.xyaxis"),
            ("Discover", "lightbulb"),
            ("Account", "person")
        ]
        
        let leftItems = Array(items.prefix(2))
        let rightItems = Array(items.suffix(2))
        
        for (index, item) in leftItems.enumerated() {
            let itemView = makeItemView(title: item.title, iconName: item.icon, tag: index)
            itemViews.append(itemView)
            contentStack.addArrangedSubview(itemView)
            itemView.snp.makeConstraints { make in
                make.width.equalTo(CustomTabBarLayout.sideItemWidth)
            }
        }
        
        let centerSlot = UIView()
        centerSlot.backgroundColor = .clear
        centerSlot.addSubview(centerButton)
        contentStack.addArrangedSubview(centerSlot)
        centerSlot.snp.makeConstraints { make in
            make.width.equalTo(CustomTabBarLayout.centerSlotWidth)
        }
        centerButton.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(CustomTabBarLayout.centerButtonSize)
        }
        
        for (offset, item) in rightItems.enumerated() {
            let realIndex = offset + leftItems.count
            let itemView = makeItemView(title: item.title, iconName: item.icon, tag: realIndex)
            itemViews.append(itemView)
            contentStack.addArrangedSubview(itemView)
            itemView.snp.makeConstraints { make in
                make.width.equalTo(CustomTabBarLayout.sideItemWidth)
            }
        }
    }
    
    private func makeItemView(title: String, iconName: String, tag: Int) -> TabItemView {
        let itemView = TabItemView(title: title, iconName: iconName)
        itemView.tag = tag
        itemView.addTarget(self, action: #selector(tabItemTapped(_:)), for: .touchUpInside)
        return itemView
    }
    
    override var intrinsicContentSize: CGSize {
        CGSize(width: UIView.noIntrinsicMetric, height: CustomTabBarLayout.overallHeight)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        topHighlightLayer.frame = topHighlightView.bounds
        glassReflectionLayer.frame = glassReflectionView.bounds
        mistGradientLayer.frame = mistTintView.bounds
        selectionSheenLayer.frame = selectionSheenView.bounds
        shadowContainer.layer.shadowPath = UIBezierPath(
            roundedRect: shadowContainer.bounds,
            cornerRadius: shadowContainer.bounds.height / 2
        ).cgPath
        centerButton.layer.shadowPath = UIBezierPath(
            roundedRect: centerButton.bounds,
            cornerRadius: centerButton.bounds.height / 2
        ).cgPath
        updateSelectionIndicatorFrame(animated: false)
        
        if !hasAppliedInitialSelectionIndicator {
            hasAppliedInitialSelectionIndicator = true
            DispatchQueue.main.async { [weak self] in
                self?.updateSelectionState(animated: false)
            }
        }
    }
    
    @objc private func tabItemTapped(_ sender: UIControl) {
        let index = sender.tag
        setSelectedIndex(index)
        delegate?.customTabBar(self, didSelectIndex: index)
    }
    
    @objc private func centerButtonTapped() {
        animateCenterButton()
        delegate?.customTabBarDidSelectCenterButton(self)
    }
    
    func setSelectedIndex(_ index: Int) {
        selectedIndex = index
        updateSelectionState(animated: true)
    }
    
    private func updateSelectionState(animated: Bool) {
        for (index, itemView) in itemViews.enumerated() {
            itemView.setSelected(index == selectedIndex, animated: animated)
        }
        updateSelectionIndicatorFrame(animated: animated)
    }
    
    private func updateSelectionIndicatorFrame(animated: Bool) {
        guard itemViews.indices.contains(selectedIndex) else { return }
        let targetView = itemViews[selectedIndex]
        // 将目标按钮的坐标系转换到底栏容器内，后续共享胶囊统一在 backgroundContainer 中定位。
        let targetFrame = targetView.convert(targetView.bounds, to: backgroundContainer)
        guard targetFrame.width > 1, targetFrame.height > 1 else { return }
        // 主胶囊直接包裹目标按钮区域，并通过固定高度维持统一的“水滴胶囊”视觉。
        let pillFrame = CGRect(
            x: targetFrame.minX + CustomTabBarLayout.activePillHorizontalInset,
            y: targetFrame.midY - (CustomTabBarLayout.activePillHeight / 2),
            width: targetFrame.width - (CustomTabBarLayout.activePillHorizontalInset * 2),
            height: CustomTabBarLayout.activePillHeight
        )
        // 外发光层比主胶囊略大一圈，用来制造更柔和的液态扩散边缘。
        let glowFrame = pillFrame.insetBy(dx: -CustomTabBarLayout.activePillGlowInset, dy: -1.5)
        
        let applyFrames = {
            // 这一组 frame 是“动画结束后的稳定态”，包括主胶囊、发光、高光和流光层。
            self.selectionGlowView.frame = glowFrame
            self.selectionPillView.frame = pillFrame
            self.selectionGlowView.layer.cornerRadius = glowFrame.height / 2
            self.selectionPillView.layer.cornerRadius = pillFrame.height / 2
            self.selectionHighlightView.frame = CGRect(x: 3.5, y: 3.5, width: max(0, pillFrame.width - 7), height: 10)
            self.selectionHighlightView.layer.cornerRadius = 11
            self.selectionSheenView.frame = CGRect(x: pillFrame.width * 0.225, y: 0, width: pillFrame.width * 0.55, height: pillFrame.height)
            self.selectionGlowView.alpha = 1
            self.selectionPillView.alpha = 1
        }
        
        if animated {
            // sourceFrame 表示胶囊当前所在位置；首次进入时没有历史位置，就直接从目标位置开始。
            let sourceFrame = lastIndicatorFrame == .zero ? pillFrame : lastIndicatorFrame
            // 通过水平位移判断滑动方向，并用位移量决定拉伸程度，让移动更像液态而不是刚性平移。
            let deltaX = pillFrame.midX - sourceFrame.midX
            let stretch = min(28, abs(deltaX) * 0.32)
            // stretchedFrame 是“中间态”：胶囊会先朝目标方向被拉长，再弹回目标尺寸。
            let stretchedFrame = CGRect(
                x: min(sourceFrame.minX, pillFrame.minX),
                y: pillFrame.minY,
                width: max(sourceFrame.maxX, pillFrame.maxX) - min(sourceFrame.minX, pillFrame.minX) + stretch,
                height: pillFrame.height
            )
            // 先把共享胶囊放回当前起点，再开始做液态拉伸动画。
            self.selectionGlowView.frame = glowFrame
            self.selectionPillView.frame = sourceFrame
            self.selectionGlowView.layer.cornerRadius = glowFrame.height / 2
            self.selectionPillView.layer.cornerRadius = sourceFrame.height / 2
            self.selectionHighlightView.frame = CGRect(x: 3.5, y: 3.5, width: max(0, sourceFrame.width - 7), height: 10)
            self.selectionHighlightView.layer.cornerRadius = 11
            self.selectionSheenView.frame = CGRect(x: sourceFrame.width * 0.225, y: 0, width: sourceFrame.width * 0.55, height: sourceFrame.height)
            self.selectionGlowView.alpha = 1
            self.selectionPillView.alpha = 1
            
            // 第一段动画：快速拉伸，强调“液体被拖拽”的感觉。
            UIView.animate(withDuration: 0.16,
                           delay: 0,
                           options: [.curveEaseOut, .beginFromCurrentState]) {
                self.selectionPillView.frame = stretchedFrame
                self.selectionGlowView.frame = stretchedFrame.insetBy(dx: -CustomTabBarLayout.activePillGlowInset, dy: -1.5)
                self.selectionPillView.layer.cornerRadius = stretchedFrame.height / 2
                self.selectionGlowView.layer.cornerRadius = (stretchedFrame.height + 3) / 2
                self.selectionHighlightView.frame = CGRect(x: 3.5, y: 3.5, width: max(0, stretchedFrame.width - 7), height: 10)
                self.selectionSheenView.frame = CGRect(x: stretchedFrame.width * 0.225, y: 0, width: stretchedFrame.width * 0.55, height: stretchedFrame.height)
            } completion: { _ in
                // 第二段动画：用弹簧参数回到稳定态，让胶囊像水滴一样“收回来”。
                UIView.animate(withDuration: 0.34,
                               delay: 0,
                               usingSpringWithDamping: 0.74,
                               initialSpringVelocity: 1.05,
                               options: [.curveEaseOut, .beginFromCurrentState]) {
                    applyFrames()
                }
            }
            // 流光根据移动方向扫过胶囊，进一步强化“液态滑移”的动态提示。
            selectionSheenView.layer.removeAllAnimations()
            let animation = CABasicAnimation(keyPath: "transform.translation.x")
            animation.fromValue = deltaX >= 0 ? -18 : 18
            animation.toValue = 0
            animation.duration = 0.42
            animation.timingFunction = CAMediaTimingFunction(name: .easeOut)
            selectionSheenView.layer.add(animation, forKey: "shared.liquid.sheen")
        } else {
            applyFrames()
        }
        // 记录这次最终位置，作为下次切换时的起点。
        lastIndicatorFrame = pillFrame
    }
    
    private func animateCenterButton() {
        UIView.animateKeyframes(withDuration: 0.48, delay: 0, options: [.calculationModeCubic, .beginFromCurrentState]) {
            UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.22) {
                self.centerButton.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            }
            UIView.addKeyframe(withRelativeStartTime: 0.22, relativeDuration: 0.28) {
                self.centerButton.transform = CGAffineTransform(scaleX: 1.08, y: 1.08)
            }
            UIView.addKeyframe(withRelativeStartTime: 0.50, relativeDuration: 0.18) {
                self.centerButton.transform = CGAffineTransform(scaleX: 0.98, y: 0.98)
            }
            UIView.addKeyframe(withRelativeStartTime: 0.68, relativeDuration: 0.32) {
                self.centerButton.transform = .identity
            }
        }
    }
}

private final class TabItemView: UIControl {
    
    private enum Style {
        static let selectedTint = UIColor(red: 0.27, green: 0.94, blue: 0.45, alpha: 1)
        static let normalTint = UIColor.white.withAlphaComponent(0.92)
        static let selectedTextAlpha: CGFloat = 1
        static let normalTextAlpha: CGFloat = 0.92
    }
    
    private let iconView = UIImageView()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 9.5, weight: .semibold)
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.72
        return label
    }()
    
    init(title: String, iconName: String) {
        super.init(frame: .zero)
        setupUI()
        titleLabel.text = title
        iconView.image = UIImage(systemName: iconName)?.withConfiguration(
            UIImage.SymbolConfiguration(pointSize: CustomTabBarLayout.iconSize, weight: .medium)
        )
        setSelected(false, animated: false)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        addSubview(iconView)
        addSubview(titleLabel)
        
        iconView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(7)
            make.size.equalTo(CustomTabBarLayout.iconSize)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(iconView.snp.bottom).offset(CustomTabBarLayout.labelTopSpacing)
            make.leading.trailing.equalToSuperview()
            make.bottom.lessThanOrEqualToSuperview().inset(4)
        }
    }
    
    func setSelected(_ selected: Bool, animated: Bool) {
        let updates = {
            self.iconView.tintColor = selected ? Style.selectedTint : Style.normalTint
            self.titleLabel.textColor = selected ? Style.selectedTint : Style.normalTint
            self.titleLabel.alpha = selected ? Style.selectedTextAlpha : Style.normalTextAlpha
        }
        
        if animated {
            UIView.animate(withDuration: 0.38,
                           delay: 0,
                           usingSpringWithDamping: 0.62,
                           initialSpringVelocity: 1.6,
                           options: .curveEaseOut,
                           animations: updates)
        } else {
            updates()
        }
    }
}
