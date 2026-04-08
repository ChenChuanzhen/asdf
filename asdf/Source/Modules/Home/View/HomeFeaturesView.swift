import UIKit
import SnapKit

protocol HomeFeaturesViewDelegate: AnyObject {
    func didTapFeature(_ feature: String)
}

final class HomeFeaturesView: UIView {
    
    private struct FeatureItem {
        let title: String
        let imageURL: String
    }
    
    private enum Metrics {
        static let spacing: CGFloat = 10
        static let cardHeight: CGFloat = 182.5
        static let cornerRadius: CGFloat = 7
        static let titleInset: CGFloat = 12
    }
    
    weak var delegate: HomeFeaturesViewDelegate?
    
    private let items: [FeatureItem] = [
        FeatureItem(title: "Investor Insights", imageURL: HomeDesign.FeatureAsset.investorInsights),
        FeatureItem(title: "Top Movers", imageURL: HomeDesign.FeatureAsset.topMovers)
    ]
    
    private let stackView = UIStackView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        stackView.axis = .horizontal
        stackView.spacing = Metrics.spacing
        stackView.distribution = .fillEqually
        
        addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalTo(Metrics.cardHeight)
        }
        
        items.forEach { stackView.addArrangedSubview(makeCard(item: $0)) }
    }
    
    private func makeCard(item: FeatureItem) -> UIControl {
        let control = UIControl()
        let imageView = RemoteImageView()
        let overlay = UIView()
        let titleLabel = UILabel()
        
        control.layer.cornerRadius = Metrics.cornerRadius
        control.clipsToBounds = true
        control.accessibilityIdentifier = item.title
        control.addTarget(self, action: #selector(featureTapped(_:)), for: .touchUpInside)
        
        imageView.contentMode = .scaleAspectFill
        imageView.setImage(urlString: item.imageURL)
        
        overlay.backgroundColor = UIColor.black.withAlphaComponent(0.18)
        
        titleLabel.text = item.title
        titleLabel.textColor = .white
        titleLabel.font = .dmSansFont(ofSize: 14, weight: .bold)
        
        control.addSubview(imageView)
        control.addSubview(overlay)
        control.addSubview(titleLabel)
        
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        overlay.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints { make in
            make.leading.bottom.equalToSuperview().inset(Metrics.titleInset)
            make.trailing.lessThanOrEqualToSuperview().inset(Metrics.titleInset)
        }
        
        return control
    }
    
    @objc private func featureTapped(_ sender: UIControl) {
        guard let feature = sender.accessibilityIdentifier else { return }
        delegate?.didTapFeature(feature)
    }
}
