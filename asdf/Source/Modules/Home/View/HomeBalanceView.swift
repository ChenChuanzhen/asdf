import UIKit
import SnapKit

protocol HomeBalanceViewDelegate: AnyObject {
    func didTapBalanceItem(_ item: String)
    func didTapSettings()
}

final class HomeBalanceView: UIView {
    
    struct AssetItem {
        let title: String
        let value: String
        let showsHelpIcon: Bool
        let showsSeparator: Bool
    }
    
    weak var delegate: HomeBalanceViewDelegate?
    
    private var isAssetVisible = true
    private var walletBalance = "RM 10,000.00"
    private var detailItems: [AssetItem] = []
    
    private let containerView = UIView()
    private let titleRow = UIStackView()
    private let titleLabel = UILabel()
    private let helpImageView = UIImageView()
    private let settingsButton = UIButton(type: .custom)
    private let settingsImageView = UIImageView()
    private let walletRowButton = UIButton(type: .custom)
    private let walletTitleLabel = UILabel()
    private let walletValueLabel = UILabel()
    private let walletArrowImageView = UIImageView()
    private let contentStack = UIStackView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        configureDefaultData()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        containerView.backgroundColor = HomeDesign.Color.cardBackground
        containerView.layer.cornerRadius = AppConstants.Home.Balance.cardCornerRadius
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOpacity = AppConstants.Home.Balance.shadowOpacity
        containerView.layer.shadowOffset = CGSize(width: 0, height: 0)
        containerView.layer.shadowRadius = AppConstants.Home.Balance.shadowRadius
        
        titleRow.axis = .horizontal
        titleRow.alignment = .center
        titleRow.spacing = AppConstants.Home.Balance.titleIconSpacing
        
        titleLabel.text = "e-Wallet"
        titleLabel.textColor = HomeDesign.Color.headerBlue
        titleLabel.font = .dmSansFont(ofSize: AppConstants.Home.Balance.sectionTitleFontSize, weight: .semibold)
        
        helpImageView.contentMode = .scaleAspectFit
        helpImageView.tintColor = HomeDesign.Color.headerBlue
        helpImageView.image = UIImage(systemName: "questionmark.circle")
        helpImageView.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: AppConstants.Home.Balance.helpIconSize, weight: .regular)
        
        settingsButton.addTarget(self, action: #selector(settingsTapped), for: .touchUpInside)
        settingsImageView.contentMode = .scaleAspectFit
        settingsImageView.tintColor = UIColor(hex: "#555555")
        settingsImageView.image = UIImage(systemName: "gearshape")
        settingsImageView.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: AppConstants.Home.Balance.settingsSize, weight: .regular)
        
        walletTitleLabel.text = "Wallet Balance"
        walletTitleLabel.textColor = HomeDesign.Color.textPrimary
        walletTitleLabel.font = .dmSansFont(ofSize: AppConstants.Home.Balance.walletTitleFontSize, weight: .bold)
        
        walletValueLabel.textColor = HomeDesign.Color.headerBlue
        walletValueLabel.font = .robotoFont(ofSize: AppConstants.Home.Balance.walletValueFontSize, weight: .bold)
        walletValueLabel.textAlignment = .right
        
        walletArrowImageView.contentMode = .scaleAspectFit
        walletArrowImageView.tintColor = HomeDesign.Color.headerBlue
        walletArrowImageView.image = UIImage(systemName: "chevron.right.circle.fill")
        walletArrowImageView.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: AppConstants.Home.Balance.arrowSize, weight: .medium)
        
        walletRowButton.addTarget(self, action: #selector(walletTapped), for: .touchUpInside)
        
        contentStack.axis = .vertical
        contentStack.spacing = 0
        
        addSubview(containerView)
        containerView.addSubview(titleRow)
        containerView.addSubview(settingsButton)
        containerView.addSubview(walletTitleLabel)
        containerView.addSubview(walletValueLabel)
        containerView.addSubview(walletArrowImageView)
        containerView.addSubview(walletRowButton)
        containerView.addSubview(contentStack)
        
        titleRow.addArrangedSubview(titleLabel)
        titleRow.addArrangedSubview(helpImageView)
        settingsButton.addSubview(settingsImageView)
        
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 0, left: AppConstants.Home.Balance.horizontalInset, bottom: 0, right: AppConstants.Home.Balance.horizontalInset))
        }
        
        titleRow.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().inset(AppConstants.Home.Balance.cardPadding)
        }
        
        helpImageView.snp.makeConstraints { make in
            make.size.equalTo(AppConstants.Home.Balance.helpIconSize)
        }
        
        settingsButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(AppConstants.Home.Balance.cardPadding)
            make.centerY.equalTo(titleRow)
            make.size.equalTo(AppConstants.Home.Balance.settingsSize)
        }
        
        settingsImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        walletTitleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(AppConstants.Home.Balance.cardPadding)
            make.top.equalTo(titleRow.snp.bottom).offset(AppConstants.Home.Balance.sectionSpacing)
        }
        
        walletArrowImageView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(AppConstants.Home.Balance.cardPadding)
            make.centerY.equalTo(walletTitleLabel)
            make.size.equalTo(AppConstants.Home.Balance.arrowSize)
        }
        
        walletValueLabel.snp.makeConstraints { make in
            make.trailing.equalTo(walletArrowImageView.snp.leading).offset(-AppConstants.Home.Balance.valueSpacing)
            make.centerY.equalTo(walletTitleLabel)
            make.leading.greaterThanOrEqualTo(walletTitleLabel.snp.trailing).offset(12)
        }
        
        walletRowButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(AppConstants.Home.Balance.cardPadding)
            make.top.equalTo(walletTitleLabel).offset(-AppConstants.Home.Balance.rowVerticalPadding)
            make.bottom.equalTo(walletTitleLabel).offset(AppConstants.Home.Balance.rowVerticalPadding)
        }
        
        contentStack.snp.makeConstraints { make in
            make.top.equalTo(walletRowButton.snp.bottom).offset(AppConstants.Home.Balance.sectionSpacing)
            make.leading.trailing.bottom.equalToSuperview().inset(AppConstants.Home.Balance.cardPadding)
        }
    }
    
    private func configureDefaultData() {
        updateAssetData(totalAmount: "RM 124,000.00",
                        walletBalance: "RM 10,000.00",
                        totalAssetValue: "RM 83,000.00",
                        cashManagement: "RM 51,300.00",
                        digitalInvesting: "RM 12,300.00",
                        equity: "RM 20,400.00",
                        cryptocurrency: "RM 30,000.00")
    }
    
    func updateAssetData(totalAmount: String,
                         walletBalance: String,
                         totalAssetValue: String,
                         cashManagement: String,
                         digitalInvesting: String,
                         equity: String,
                         cryptocurrency: String) {
        self.walletBalance = walletBalance
        detailItems = [
            AssetItem(title: "Total Asset Value", value: totalAssetValue, showsHelpIcon: true, showsSeparator: false),
            AssetItem(title: "Cash Management", value: cashManagement, showsHelpIcon: false, showsSeparator: true),
            AssetItem(title: "Digital Investing", value: digitalInvesting, showsHelpIcon: false, showsSeparator: true),
            AssetItem(title: "Equity", value: equity, showsHelpIcon: false, showsSeparator: true),
            AssetItem(title: "Cryptocurrency", value: cryptocurrency, showsHelpIcon: false, showsSeparator: true)
        ]
        reloadRows()
    }
    
    func setAssetVisibility(_ visible: Bool) {
        isAssetVisible = visible
        reloadRows()
    }
    
    private func reloadRows() {
        walletValueLabel.text = isAssetVisible ? walletBalance : "RM ••••••••"
        contentStack.arrangedSubviews.forEach {
            contentStack.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }
        detailItems.forEach { item in
            contentStack.addArrangedSubview(makeRow(item: item))
        }
    }
    
    private func makeRow(item: AssetItem) -> UIView {
        let container = UIView()
        let titleStack = UIStackView()
        let titleLabel = UILabel()
        let helpImageView = UIImageView()
        let valueLabel = UILabel()
        let arrowImageView = UIImageView()
        let button = UIButton(type: .custom)
        
        titleStack.axis = .horizontal
        titleStack.alignment = .center
        titleStack.spacing = AppConstants.Home.Balance.titleIconSpacing
        
        titleLabel.text = item.title
        titleLabel.textColor = item.showsHelpIcon ? HomeDesign.Color.headerBlue : HomeDesign.Color.textPrimary
        titleLabel.font = .dmSansFont(ofSize: AppConstants.Home.Balance.sectionTitleFontSize, weight: item.showsHelpIcon ? .semibold : .bold)
        
        helpImageView.contentMode = .scaleAspectFit
        helpImageView.tintColor = HomeDesign.Color.headerBlue
        helpImageView.image = UIImage(systemName: "questionmark.circle")
        helpImageView.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: AppConstants.Home.Balance.helpIconSize, weight: .regular)
        helpImageView.isHidden = !item.showsHelpIcon
        
        valueLabel.text = isAssetVisible ? item.value : "RM ••••••••"
        valueLabel.textColor = HomeDesign.Color.headerBlue
        valueLabel.font = .robotoFont(ofSize: AppConstants.Home.Balance.detailValueFontSize, weight: .bold)
        
        arrowImageView.contentMode = .scaleAspectFit
        arrowImageView.tintColor = HomeDesign.Color.headerBlue
        arrowImageView.image = UIImage(systemName: "chevron.right.circle.fill")
        arrowImageView.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: AppConstants.Home.Balance.arrowSize, weight: .medium)
        
        button.accessibilityIdentifier = item.title
        button.addTarget(self, action: #selector(balanceItemTapped(_:)), for: .touchUpInside)
        
        container.addSubview(titleStack)
        container.addSubview(valueLabel)
        container.addSubview(arrowImageView)
        container.addSubview(button)
        
        titleStack.addArrangedSubview(titleLabel)
        titleStack.addArrangedSubview(helpImageView)
        
        titleStack.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        
        helpImageView.snp.makeConstraints { make in
            make.size.equalTo(AppConstants.Home.Balance.helpIconSize)
        }
        
        arrowImageView.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.centerY.equalToSuperview()
            make.size.equalTo(AppConstants.Home.Balance.arrowSize)
        }
        
        valueLabel.snp.makeConstraints { make in
            make.trailing.equalTo(arrowImageView.snp.leading).offset(-AppConstants.Home.Balance.valueSpacing)
            make.centerY.equalToSuperview()
            make.leading.greaterThanOrEqualTo(titleStack.snp.trailing).offset(10)
        }
        
        button.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        if item.showsSeparator {
            let separator = UIView()
            separator.backgroundColor = HomeDesign.Color.line
            container.addSubview(separator)
            separator.snp.makeConstraints { make in
                make.leading.trailing.bottom.equalToSuperview()
                make.height.equalTo(AppConstants.Home.Balance.separatorHeight)
            }
        }
        
        container.snp.makeConstraints { make in
            make.height.equalTo(item.showsHelpIcon ? AppConstants.Home.Balance.totalAssetRowHeight : AppConstants.Home.Balance.rowHeight)
        }
        
        return container
    }
    
    @objc private func settingsTapped() {
        delegate?.didTapSettings()
    }
    
    @objc private func walletTapped() {
        delegate?.didTapBalanceItem("Wallet Balance")
    }
    
    @objc private func balanceItemTapped(_ sender: UIButton) {
        guard let item = sender.accessibilityIdentifier else { return }
        delegate?.didTapBalanceItem(item)
    }
}
