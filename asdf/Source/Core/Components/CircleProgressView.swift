//
//  CircleProgressView.swift
//  asdf
//
//  Created by 咸鱼悠游 on 2026/4/9.
//

import Foundation
import UIKit
import SnapKit

final class CircleProgressView: UIView {
    
    // MARK: - Public API
    
    var lineWidth: CGFloat = 14 {
        didSet {
            backgroundLayer.lineWidth = lineWidth
            progressLayer.lineWidth = lineWidth
            setNeedsLayout()
        }
    }
    
    var ringBackgroundColor: UIColor = AppTheme.Color.borderLight {
        didSet {
            backgroundLayer.strokeColor = ringBackgroundColor.cgColor
        }
    }
    
    var progressStartColor: UIColor = UIColor(hex: "#7FB8FF") {
        didSet {
            updateGradientColors()
        }
    }
    
    var progressEndColor: UIColor = UIColor(hex: "#0F5DEB") {
        didSet {
            updateGradientColors()
        }
    }
    
    var centerTextColor: UIColor = .black {
        didSet {
            valueLabel.textColor = centerTextColor
        }
    }
    
    var centerFont: UIFont = .systemFont(ofSize: 24, weight: .bold) {
        didSet {
            valueLabel.font = centerFont
        }
    }
    
    var progress: CGFloat {
        currentProgress
    }
    
    var onCountdownFinished: (() -> Void)?
    
    // MARK: - Private State
    
    private var currentProgress: CGFloat = 0
    private var countdownTimer: Timer?
    private var countdownTotalSeconds: Int = 0
    private var countdownRemainingSeconds: Int = 0
    private var hasTriggeredCountdownFinished = false
    
    // MARK: - Layers
    
    private let backgroundLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.fillColor = UIColor.clear.cgColor
        layer.lineCap = .round
        return layer
    }()
    
    private let progressLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.fillColor = UIColor.clear.cgColor
        layer.lineCap = .round
        layer.strokeEnd = 0
        return layer
    }()
    
    private let gradientLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.type = .conic
        layer.startPoint = CGPoint(x: 0.5, y: 0.5)
        layer.endPoint = CGPoint(x: 0.5, y: 0)
        return layer
    }()
    
    // MARK: - UI
    
    private let valueLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .black
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.text = "0%"
        return label
    }()
    
    // MARK: - Init
    
    convenience init(
        lineWidth: CGFloat = 14,
        ringBackgroundColor: UIColor = AppTheme.Color.borderLight,
        progressStartColor: UIColor = UIColor(hex: "#7FB8FF"),
        progressEndColor: UIColor = UIColor(hex: "#0F5DEB"),
        centerTextColor: UIColor = .black,
        centerFont: UIFont = .systemFont(ofSize: 24, weight: .bold),
        onCountdownFinished: (() -> Void)? = nil
    ) {
        self.init(frame: .zero)
        self.lineWidth = lineWidth
        self.ringBackgroundColor = ringBackgroundColor
        self.progressStartColor = progressStartColor
        self.progressEndColor = progressEndColor
        self.centerTextColor = centerTextColor
        self.centerFont = centerFont
        self.onCountdownFinished = onCountdownFinished
        
        backgroundLayer.lineWidth = lineWidth
        backgroundLayer.strokeColor = ringBackgroundColor.cgColor
        progressLayer.lineWidth = lineWidth
        updateGradientColors()
        valueLabel.textColor = centerTextColor
        valueLabel.font = centerFont
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    deinit {
        countdownTimer?.invalidate()
    }
    
    // MARK: - Public Methods
    
    func configure(
        ringBackgroundColor: UIColor? = nil,
        progressStartColor: UIColor? = nil,
        progressEndColor: UIColor? = nil,
        centerTextColor: UIColor? = nil,
        lineWidth: CGFloat? = nil
    ) {
        if let ringBackgroundColor {
            self.ringBackgroundColor = ringBackgroundColor
        }
        if let progressStartColor {
            self.progressStartColor = progressStartColor
        }
        if let progressEndColor {
            self.progressEndColor = progressEndColor
        }
        if let centerTextColor {
            self.centerTextColor = centerTextColor
        }
        if let lineWidth {
            self.lineWidth = lineWidth
        }
    }
    
    func setProgress(_ progress: CGFloat, animated: Bool = false, duration: TimeInterval = 0.25) {
        countdownTimer?.invalidate()
        countdownTimer = nil
        
        let clampedProgress = clamp(progress)
        currentProgress = clampedProgress
        updateProgressLayer(animated: animated, duration: duration)
        valueLabel.text = "\(Int(round(clampedProgress * 100)))%"
    }
    
    func setProgress(_ progress: CGFloat, text: String?, animated: Bool = false, duration: TimeInterval = 0.25) {
        countdownTimer?.invalidate()
        countdownTimer = nil
        
        currentProgress = clamp(progress)
        updateProgressLayer(animated: animated, duration: duration)
        valueLabel.text = text
    }
    
    func setCountdown(totalSeconds: Int, remainingSeconds: Int, animated: Bool = false) {
        countdownTimer?.invalidate()
        countdownTimer = nil
        
        countdownTotalSeconds = max(totalSeconds, 0)
        countdownRemainingSeconds = min(max(remainingSeconds, 0), countdownTotalSeconds)
        hasTriggeredCountdownFinished = false
        renderCountdown(animated: animated)
        
        if countdownRemainingSeconds == 0 {
            notifyCountdownFinishedIfNeeded()
        }
    }
    
    func startCountdown(seconds: Int) {
        countdownTimer?.invalidate()
        countdownTimer = nil
        
        countdownTotalSeconds = max(seconds, 0)
        countdownRemainingSeconds = countdownTotalSeconds
        hasTriggeredCountdownFinished = false
        renderCountdown(animated: false)
        
        guard countdownTotalSeconds > 0 else {
            notifyCountdownFinishedIfNeeded()
            return
        }
        
        let timer = Timer.scheduledTimer(
            timeInterval: 1,
            target: self,
            selector: #selector(handleCountdownTick),
            userInfo: nil,
            repeats: true
        )
        RunLoop.main.add(timer, forMode: .common)
        countdownTimer = timer
    }
    
    func stopCountdown() {
        countdownTimer?.invalidate()
        countdownTimer = nil
    }
    
    // MARK: - Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let radius = max((min(bounds.width, bounds.height) - lineWidth) / 2, 0)
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let startAngle = -CGFloat.pi / 2
        let endAngle = startAngle + (2 * CGFloat.pi)
        let path = UIBezierPath(
            arcCenter: center,
            radius: radius,
            startAngle: startAngle,
            endAngle: endAngle,
            clockwise: true
        )
        
        backgroundLayer.frame = bounds
        backgroundLayer.path = path.cgPath
        
        gradientLayer.frame = bounds
        gradientLayer.transform = CATransform3DMakeRotation(-CGFloat.pi / 2, 0, 0, 1)
        
        progressLayer.frame = bounds
        progressLayer.path = path.cgPath
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        backgroundColor = .clear
        
        layer.addSublayer(backgroundLayer)
        layer.addSublayer(gradientLayer)
        gradientLayer.mask = progressLayer
        
        addSubview(valueLabel)
        valueLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        backgroundLayer.strokeColor = ringBackgroundColor.cgColor
        backgroundLayer.lineWidth = lineWidth
        progressLayer.lineWidth = lineWidth
        updateGradientColors()
    }
    
    private func updateGradientColors() {
        gradientLayer.colors = [
            progressStartColor.cgColor,
            progressEndColor.cgColor,
            progressStartColor.cgColor
        ]
        gradientLayer.locations = [0, 0.65, 1]
    }
    
    private func updateProgressLayer(animated: Bool, duration: TimeInterval) {
        if animated {
            let animation = CABasicAnimation(keyPath: "strokeEnd")
            animation.fromValue = progressLayer.presentation()?.strokeEnd ?? progressLayer.strokeEnd
            animation.toValue = currentProgress
            animation.duration = duration
            animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            progressLayer.add(animation, forKey: "circle-progress")
        } else {
            progressLayer.removeAnimation(forKey: "circle-progress")
        }
        
        progressLayer.strokeEnd = currentProgress
    }
    
    private func renderCountdown(animated: Bool) {
        let progress: CGFloat
        if countdownTotalSeconds == 0 {
            progress = 0
        } else {
            progress = CGFloat(countdownRemainingSeconds) / CGFloat(countdownTotalSeconds)
        }
        
        currentProgress = progress
        updateProgressLayer(animated: animated, duration: 0.2)
        valueLabel.text = "\(countdownRemainingSeconds)s"
    }
    
    private func clamp(_ value: CGFloat) -> CGFloat {
        max(0, min(value, 1))
    }
    
    private func notifyCountdownFinishedIfNeeded() {
        guard !hasTriggeredCountdownFinished else { return }
        hasTriggeredCountdownFinished = true
        onCountdownFinished?()
    }
    
    @objc private func handleCountdownTick() {
        guard countdownRemainingSeconds > 0 else {
            stopCountdown()
            notifyCountdownFinishedIfNeeded()
            return
        }
        
        countdownRemainingSeconds -= 1
        renderCountdown(animated: true)
        
        if countdownRemainingSeconds == 0 {
            stopCountdown()
            notifyCountdownFinishedIfNeeded()
        }
    }
}
