import UIKit
import SnapKit

final class HomePartnersView: UIView {
    
    private enum Metrics {
        static let cornerRadius: CGFloat = 10
        static let borderWidth: CGFloat = 1
        static let horizontalInset: CGFloat = 14
        static let verticalInset: CGFloat = 14
        static let logoSize: CGFloat = 35
        static let logoSpacing: CGFloat = 4
        static let logoCornerRadius: CGFloat = 8
    }
    
    private let containerView = UIView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let logosStack = UIStackView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        containerView.backgroundColor = HomeDesign.Color.partnerBackground
        containerView.layer.cornerRadius = Metrics.cornerRadius
        containerView.layer.borderWidth = Metrics.borderWidth
        containerView.layer.borderColor = HomeDesign.Color.line.cgColor
        
        titleLabel.text = "Explore Partners"
        titleLabel.textColor = HomeDesign.Color.textPrimary
        titleLabel.font = .dmSansFont(ofSize: 14, weight: .semibold)
        
        subtitleLabel.text = "Our trusted partners"
        subtitleLabel.textColor = HomeDesign.Color.textPrimary
        subtitleLabel.font = .dmSansFont(ofSize: 12, weight: .regular)
        
        logosStack.axis = .horizontal
        logosStack.spacing = Metrics.logoSpacing
        logosStack.alignment = .center
        logosStack.distribution = .fillEqually
        
        addSubview(containerView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(subtitleLabel)
        containerView.addSubview(logosStack)
        
        [HomeDesign.PartnerAsset.kenanga,
         HomeDesign.PartnerAsset.kdi,
         HomeDesign.PartnerAsset.kdx,
         HomeDesign.PartnerAsset.rakuten].forEach { url in
            logosStack.addArrangedSubview(makeLogoView(url: url))
        }
        
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints { make in
            make.leading.top.equalToSuperview().inset(Metrics.horizontalInset)
        }
        
        subtitleLabel.snp.makeConstraints { make in
            make.leading.equalTo(titleLabel)
            make.top.equalTo(titleLabel.snp.bottom).offset(2)
            make.bottom.equalToSuperview().inset(Metrics.verticalInset)
        }
        
        logosStack.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(Metrics.horizontalInset)
            make.centerY.equalToSuperview()
            make.leading.greaterThanOrEqualTo(subtitleLabel.snp.trailing).offset(10)
            make.height.equalTo(Metrics.logoSize)
        }
    }
    
    private func makeLogoView(url: String) -> UIView {
        let container = UIView()
        let imageView = RemoteImageView()
        container.backgroundColor = .white
        container.layer.cornerRadius = Metrics.logoCornerRadius
        container.layer.shadowColor = UIColor.black.cgColor
        container.layer.shadowOpacity = 0.06
        container.layer.shadowRadius = 4
        container.layer.shadowOffset = CGSize(width: 0, height: 2)
        
        imageView.contentMode = .scaleAspectFit
        imageView.setImage(urlString: url)
        
        container.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        container.snp.makeConstraints { make in
            make.size.equalTo(Metrics.logoSize)
        }
        return container
    }
}
