import UIKit
import SnapKit

protocol HomeBannerViewDelegate: AnyObject {
    func didTapBanner()
    func didTapShare()
}

final class HomeBannerView: UIView {
    
    private enum Metrics {
        static let cornerRadius: CGFloat = 10
        static let heroHeight: CGFloat = 100
        static let bottomHeight: CGFloat = 50
        static let shareButtonHeight: CGFloat = 30
        static let shareHorizontalInset: CGFloat = 20
        static let pageSize: CGFloat = 6
        static let pageSpacing: CGFloat = 7
    }
    
    weak var delegate: HomeBannerViewDelegate?
    
    private let containerButton = UIButton(type: .custom)
    private let heroImageView = RemoteImageView()
    private let bottomContainer = UIView()
    private let titleLabel = UILabel()
    private let shareButton = UIButton(type: .custom)
    private let pageIndicatorStack = UIStackView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        containerButton.layer.cornerRadius = Metrics.cornerRadius
        containerButton.layer.borderWidth = 1
        containerButton.layer.borderColor = HomeDesign.Color.line.cgColor
        containerButton.layer.masksToBounds = true
        containerButton.backgroundColor = .white
        containerButton.addTarget(self, action: #selector(bannerTapped), for: .touchUpInside)
        
        heroImageView.contentMode = .scaleAspectFill
        heroImageView.setImage(urlString: HomeDesign.BannerAsset.hero)
        heroImageView.clipsToBounds = true
        
        bottomContainer.backgroundColor = .white
        
        titleLabel.text = "Link your Kenanga Money account\nwith KDi GO"
        titleLabel.textColor = HomeDesign.Color.textSecondary
        titleLabel.font = .dmSansFont(ofSize: 14, weight: .regular)
        titleLabel.numberOfLines = 2
        titleLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        shareButton.backgroundColor = HomeDesign.Color.headerBlue
        shareButton.layer.cornerRadius = Metrics.shareButtonHeight / 2
        shareButton.setTitle("Share", for: .normal)
        shareButton.setTitleColor(.white, for: .normal)
        shareButton.titleLabel?.font = .dmSansFont(ofSize: 14, weight: .semibold)
        shareButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: Metrics.shareHorizontalInset, bottom: 0, right: Metrics.shareHorizontalInset)
        shareButton.addTarget(self, action: #selector(shareTapped), for: .touchUpInside)
        
        pageIndicatorStack.axis = .horizontal
        pageIndicatorStack.spacing = Metrics.pageSpacing
        pageIndicatorStack.alignment = .center
        
        [HomeDesign.Color.headerBlue, HomeDesign.Color.line, HomeDesign.Color.line].forEach { color in
            let dot = UIView()
            dot.backgroundColor = color
            dot.layer.cornerRadius = Metrics.pageSize / 2
            dot.snp.makeConstraints { make in
                make.size.equalTo(Metrics.pageSize)
            }
            pageIndicatorStack.addArrangedSubview(dot)
        }
        
        addSubview(containerButton)
        addSubview(pageIndicatorStack)
        containerButton.addSubview(heroImageView)
        containerButton.addSubview(bottomContainer)
        bottomContainer.addSubview(titleLabel)
        bottomContainer.addSubview(shareButton)
        
        containerButton.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }
        
        heroImageView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(Metrics.heroHeight)
        }
        
        bottomContainer.snp.makeConstraints { make in
            make.top.equalTo(heroImageView.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(Metrics.bottomHeight)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(10)
            make.centerY.equalToSuperview()
            make.trailing.lessThanOrEqualTo(shareButton.snp.leading).offset(-10)
        }
        
        shareButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(10)
            make.centerY.equalToSuperview()
            make.height.equalTo(Metrics.shareButtonHeight)
        }
        
        pageIndicatorStack.snp.makeConstraints { make in
            make.top.equalTo(containerButton.snp.bottom).offset(12)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
    
    @objc private func bannerTapped() {
        delegate?.didTapBanner()
    }
    
    @objc private func shareTapped() {
        delegate?.didTapShare()
    }
}
