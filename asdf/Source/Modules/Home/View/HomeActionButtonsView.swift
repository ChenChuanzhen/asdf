import UIKit
import SnapKit

enum HomeActionType: String, CaseIterable {
    case buySell = "Buy / Sell"
    case wallet = "e-Wallet"
    case deposit = "Deposit"
    case transfer = "Transfer"
    case wealth = "Wealth Tracker"
    case save = "KDI Save"
    case invest = "KDI Invest"
    case more = "More"
}

protocol HomeActionButtonsViewDelegate: AnyObject {
    func didTapActionButton(_ action: HomeActionType)
}

final class HomeActionButtonsView: UIView {
    
    private struct ActionItem {
        let type: HomeActionType
        let imageURL: String
        let title: String
        let showsNewBadge: Bool
        let usesImageBackground: Bool
    }
    
    private enum Metrics {
        static let titleFontSize: CGFloat = 14
        static let rowSpacing: CGFloat = 12
        static let itemSpacing: CGFloat = 12
        static let iconSize: CGFloat = 56
        static let iconCornerRadius: CGFloat = 28
        static let labelTopSpacing: CGFloat = 7
        static let badgeHeight: CGFloat = 16
        static let badgeHorizontalInset: CGFloat = 8
        static let badgeCornerRadius: CGFloat = 4
    }
    
    weak var delegate: HomeActionButtonsViewDelegate?
    
    private let items: [ActionItem] = [
        ActionItem(type: .buySell, imageURL: HomeDesign.FavoriteAsset.buySell, title: "Buy / Sell", showsNewBadge: false, usesImageBackground: false),
        ActionItem(type: .wallet, imageURL: HomeDesign.FavoriteAsset.wallet, title: "e-Wallet", showsNewBadge: false, usesImageBackground: false),
        ActionItem(type: .deposit, imageURL: HomeDesign.FavoriteAsset.deposit, title: "Deposit", showsNewBadge: false, usesImageBackground: false),
        ActionItem(type: .transfer, imageURL: HomeDesign.FavoriteAsset.transfer, title: "Transfer", showsNewBadge: false, usesImageBackground: false),
        ActionItem(type: .wealth, imageURL: HomeDesign.FavoriteAsset.wealth, title: "Wealth\nTracker", showsNewBadge: true, usesImageBackground: false),
        ActionItem(type: .save, imageURL: HomeDesign.FavoriteAsset.kdi, title: "KDI Save", showsNewBadge: false, usesImageBackground: true),
        ActionItem(type: .invest, imageURL: HomeDesign.FavoriteAsset.kdi, title: "KDI Invest", showsNewBadge: false, usesImageBackground: true),
        ActionItem(type: .more, imageURL: HomeDesign.FavoriteAsset.more, title: "More", showsNewBadge: false, usesImageBackground: false)
    ]
    
    private let titleLabel = UILabel()
    private let editButton = UIButton(type: .custom)
    private let contentStack = UIStackView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        titleLabel.text = "My Favourites"
        titleLabel.textColor = HomeDesign.Color.textSecondary
        titleLabel.font = .dmSansFont(ofSize: Metrics.titleFontSize, weight: .semibold)
        
        editButton.setTitle("Edit", for: .normal)
        editButton.setTitleColor(HomeDesign.Color.headerBlue, for: .normal)
        editButton.titleLabel?.font = .dmSansFont(ofSize: Metrics.titleFontSize, weight: .semibold)
        
        contentStack.axis = .vertical
        contentStack.spacing = Metrics.rowSpacing
        contentStack.distribution = .fillEqually
        
        addSubview(titleLabel)
        addSubview(editButton)
        addSubview(contentStack)
        
        titleLabel.snp.makeConstraints { make in
            make.top.leading.equalToSuperview()
        }
        
        editButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.centerY.equalTo(titleLabel)
        }
        
        contentStack.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(14)
            make.leading.trailing.bottom.equalToSuperview()
        }
        
        stride(from: 0, to: items.count, by: 4).forEach { start in
            let rowStack = UIStackView()
            rowStack.axis = .horizontal
            rowStack.spacing = Metrics.itemSpacing
            rowStack.distribution = .fillEqually
            items[start..<min(start + 4, items.count)].forEach { rowStack.addArrangedSubview(makeActionView(item: $0)) }
            contentStack.addArrangedSubview(rowStack)
        }
    }
    
    private func makeActionView(item: ActionItem) -> UIView {
        let container = UIView()
        let button = UIButton(type: .custom)
        let iconContainer = UIView()
        let imageView = RemoteImageView()
        let label = UILabel()
        
        button.tag = item.type.hashValue
        button.addTarget(self, action: #selector(actionTapped(_:)), for: .touchUpInside)
        
        iconContainer.backgroundColor = item.usesImageBackground ? .clear : HomeDesign.Color.favoriteBackground
        iconContainer.layer.cornerRadius = Metrics.iconCornerRadius
        iconContainer.layer.borderWidth = item.usesImageBackground ? 0 : 0.5
        iconContainer.layer.borderColor = HomeDesign.Color.line.cgColor
        
        imageView.contentMode = item.usesImageBackground ? .scaleAspectFill : .scaleAspectFit
        imageView.layer.cornerRadius = Metrics.iconCornerRadius
        imageView.clipsToBounds = true
        imageView.setImage(urlString: item.imageURL)
        
        label.text = item.title
        label.textColor = HomeDesign.Color.textPrimary
        label.font = .dmSansFont(ofSize: 14, weight: .regular)
        label.numberOfLines = 2
        label.textAlignment = .center
        
        container.addSubview(iconContainer)
        container.addSubview(label)
        container.addSubview(button)
        iconContainer.addSubview(imageView)
        
        iconContainer.snp.makeConstraints { make in
            make.top.centerX.equalToSuperview()
            make.size.equalTo(Metrics.iconSize)
        }
        
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        label.snp.makeConstraints { make in
            make.top.equalTo(iconContainer.snp.bottom).offset(Metrics.labelTopSpacing)
            make.leading.trailing.bottom.equalToSuperview()
        }
        
        button.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        if item.showsNewBadge {
            let badge = UILabel()
            badge.text = "New"
            badge.textColor = .white
            badge.backgroundColor = HomeDesign.Color.orange
            badge.font = .dmSansFont(ofSize: 12, weight: .medium)
            badge.textAlignment = .center
            badge.layer.cornerRadius = Metrics.badgeCornerRadius
            badge.clipsToBounds = true
            container.addSubview(badge)
            badge.snp.makeConstraints { make in
                make.top.equalTo(iconContainer)
                make.trailing.equalTo(iconContainer).offset(8)
                make.height.equalTo(Metrics.badgeHeight)
                make.leading.greaterThanOrEqualTo(iconContainer.snp.centerX)
            }
        }
        
        return container
    }
    
    @objc private func actionTapped(_ sender: UIButton) {
        guard let action = HomeActionType.allCases.first(where: { $0.hashValue == sender.tag }) else { return }
        delegate?.didTapActionButton(action)
    }
}
