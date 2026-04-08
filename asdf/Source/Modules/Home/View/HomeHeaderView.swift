import UIKit
import SnapKit

protocol HomeHeaderViewDelegate: AnyObject {
    func didTapNotification()
    func didTapEyeIcon()
}

final class HomeHeaderView: UIView {
    weak var delegate: HomeHeaderViewDelegate?
    
    private var safeAreaTopInset: CGFloat = 0
    private var totalAmountText = "RM 124,000.00"
    private var isAssetVisible = true
    
    private let amountStack = UIStackView()
    private let titleLabel = UILabel()
    private let timestampLabel = UILabel()
    private let eyeButton = UIButton(type: .custom)
    private let notificationButton = UIButton(type: .custom)
    private let notificationImageView = UIImageView()
    private let badgeView = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        amountStack.axis = .horizontal
        amountStack.alignment = .center
        amountStack.spacing = AppConstants.Home.Header.amountSpacing
        
        titleLabel.textColor = .white
        titleLabel.font = .robotoFont(ofSize: AppConstants.Home.Header.amountFontSize, weight: .bold)
        titleLabel.text = totalAmountText
        
        timestampLabel.textColor = .white
        timestampLabel.font = .dmSansFont(ofSize: AppConstants.Home.Header.dateFontSize, weight: .regular)
        timestampLabel.text = "as of 9 Jun 2025 15:32"
        
        eyeButton.tintColor = .white
        eyeButton.setImage(UIImage(systemName: "eye"), for: .normal)
        eyeButton.setPreferredSymbolConfiguration(UIImage.SymbolConfiguration(pointSize: AppConstants.Home.Header.iconSize, weight: .regular), forImageIn: .normal)
        eyeButton.addTarget(self, action: #selector(eyeTapped), for: .touchUpInside)
        
        notificationButton.layer.cornerRadius = AppConstants.Home.Header.notificationCornerRadius
        notificationButton.layer.borderWidth = AppConstants.Home.Header.notificationBorderWidth
        notificationButton.layer.borderColor = UIColor.white.cgColor
        notificationButton.addTarget(self, action: #selector(notificationTapped), for: .touchUpInside)
        
        notificationImageView.contentMode = .scaleAspectFit
        notificationImageView.tintColor = .white
        notificationImageView.image = UIImage(systemName: "bell")
        notificationImageView.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: AppConstants.Home.Header.notificationIconSize, weight: .regular)
        
        badgeView.backgroundColor = HomeDesign.Color.orange
        badgeView.layer.cornerRadius = AppConstants.Home.Header.badgeSize / 2
        
        addSubview(amountStack)
        addSubview(timestampLabel)
        addSubview(notificationButton)
        notificationButton.addSubview(notificationImageView)
        notificationButton.addSubview(badgeView)
        
        amountStack.addArrangedSubview(titleLabel)
        amountStack.addArrangedSubview(eyeButton)
        
        amountStack.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(safeAreaTopInset + AppConstants.Home.Header.amountTopInset)
            make.leading.equalToSuperview().inset(AppConstants.Home.Header.horizontalInset)
            make.trailing.lessThanOrEqualTo(notificationButton.snp.leading).offset(-AppConstants.Home.Header.actionSpacing)
        }
        
        eyeButton.snp.makeConstraints { make in
            make.size.equalTo(AppConstants.Home.Header.iconSize)
        }
        
        timestampLabel.snp.makeConstraints { make in
            make.leading.equalTo(amountStack)
            make.top.equalTo(amountStack.snp.bottom).offset(AppConstants.Home.Header.dateTopSpacing)
            make.bottom.equalToSuperview().inset(AppConstants.Home.Header.contentBottomInset)
        }
        
        notificationButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(AppConstants.Home.Header.horizontalInset)
            make.centerY.equalTo(amountStack)
            make.size.equalTo(AppConstants.Home.Header.notificationSize)
        }
        
        notificationImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(AppConstants.Home.Header.notificationIconSize)
        }
        
        badgeView.snp.makeConstraints { make in
            make.size.equalTo(AppConstants.Home.Header.badgeSize)
            make.top.equalToSuperview().offset(AppConstants.Home.Header.badgeTopOffset)
            make.trailing.equalToSuperview().offset(AppConstants.Home.Header.badgeTrailingOffset)
        }
        
        applyVisibilityState()
    }
    
    func updateSafeAreaTopInset(_ inset: CGFloat) {
        guard abs(safeAreaTopInset - inset) > 0.5 else { return }
        safeAreaTopInset = inset
        amountStack.snp.updateConstraints { make in
            make.top.equalToSuperview().offset(safeAreaTopInset + AppConstants.Home.Header.amountTopInset)
        }
    }
    
    func updateUserInfo(_ userName: String?) {
    }
    
    func updateTotalAmount(_ amount: String) {
        totalAmountText = amount
        applyVisibilityState()
    }
    
    func updateTimestamp(_ text: String) {
        timestampLabel.text = text
    }
    
    func setAssetVisibility(_ visible: Bool) {
        isAssetVisible = visible
        applyVisibilityState()
    }
    
    private func applyVisibilityState() {
        titleLabel.text = isAssetVisible ? totalAmountText : "RM ••••••••"
        eyeButton.setImage(UIImage(systemName: isAssetVisible ? "eye" : "eye.slash"), for: .normal)
    }
    
    @objc private func notificationTapped() {
        delegate?.didTapNotification()
    }
    
    @objc private func eyeTapped() {
        delegate?.didTapEyeIcon()
    }
}
