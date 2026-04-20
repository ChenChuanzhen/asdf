import UIKit
import SnapKit

protocol HomeBannerViewDelegate: AnyObject {
    func didTapBanner(_ banner: HomeBannerModel?)
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
        static let pageIndicatorTopSpacing: CGFloat = 12
        static let defaultAutoScrollInterval: TimeInterval = 3
    }
    
    weak var delegate: HomeBannerViewDelegate?
    
    private var banners: [HomeBannerModel] = []
    private var currentIndex = 0
    private var autoScrollInterval = Metrics.defaultAutoScrollInterval
    private var autoScrollTimer: Timer?
    private var lastCollectionWidth: CGFloat = 0
    
    private let containerView = UIView()
    private let pageIndicatorStack = UIStackView()
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        collectionView.clipsToBounds = true
        collectionView.isPagingEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(HomeBannerCollectionViewCell.self, forCellWithReuseIdentifier: HomeBannerCollectionViewCell.reuseIdentifier)
        return collectionView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        stopAutoScroll()
    }
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        
        if window == nil {
            stopAutoScroll()
        } else {
            startAutoScrollIfNeeded()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let width = collectionView.bounds.width
        guard width > 0, width != lastCollectionWidth else { return }
        
        lastCollectionWidth = width
        collectionView.collectionViewLayout.invalidateLayout()
        collectionView.setContentOffset(CGPoint(x: CGFloat(currentIndex) * width, y: 0),
                                        animated: false)
    }
    
    private func setupUI() {
        containerView.layer.cornerRadius = Metrics.cornerRadius
        containerView.layer.borderWidth = 1
        containerView.layer.borderColor = HomeDesign.Color.line.cgColor
        containerView.layer.masksToBounds = true
        containerView.backgroundColor = .white
        
        pageIndicatorStack.axis = .horizontal
        pageIndicatorStack.spacing = Metrics.pageSpacing
        pageIndicatorStack.alignment = .center
        
        addSubview(containerView)
        addSubview(pageIndicatorStack)
        containerView.addSubview(collectionView)
        
        containerView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }
        
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalTo(Metrics.heroHeight + Metrics.bottomHeight)
        }
        
        pageIndicatorStack.snp.makeConstraints { make in
            make.top.equalTo(containerView.snp.bottom).offset(Metrics.pageIndicatorTopSpacing)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        updatePageIndicator(count: pageCount, selectedIndex: currentIndex)
    }
    
    func update(with banners: [HomeBannerModel], autoScrollInterval: TimeInterval? = nil) {
        self.banners = banners.sorted { $0.menuOrder < $1.menuOrder }
        currentIndex = 0
        
        if let autoScrollInterval {
            self.autoScrollInterval = autoScrollInterval
        }
        
        collectionView.reloadData()
        collectionView.layoutIfNeeded()
        updatePageIndicator(count: pageCount, selectedIndex: currentIndex)
        scrollToPage(at: currentIndex, animated: false)
        startAutoScrollIfNeeded()
    }
    
    func setAutoScrollInterval(_ interval: TimeInterval) {
        autoScrollInterval = interval
        startAutoScrollIfNeeded()
    }
    
    private var currentBanner: HomeBannerModel? {
        guard banners.indices.contains(currentIndex) else { return nil }
        return banners[currentIndex]
    }
    
    private var pageCount: Int {
        banners.isEmpty ? 1 : banners.count
    }
    
    private var shouldAutoScroll: Bool {
        window != nil && pageCount > 1 && autoScrollInterval > 0
    }
    
    private var defaultTitle: String {
        "Link your Kenanga Money account\nwith KDi GO"
    }
    
    private func title(at index: Int) -> String {
        guard banners.indices.contains(index) else { return defaultTitle }
        return banners[index].title
    }
    
    private func imageUrl(at index: Int) -> String? {
        guard banners.indices.contains(index) else { return HomeDesign.BannerAsset.hero }
        return banners[index].imageUrl
    }
    
    private func updatePageIndicator(count: Int, selectedIndex: Int) {
        pageIndicatorStack.arrangedSubviews.forEach { view in
            pageIndicatorStack.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
        
        guard count > 0 else { return }
        
        for index in 0..<count {
            let dot = UIView()
            dot.backgroundColor = index == selectedIndex ? HomeDesign.Color.headerBlue : HomeDesign.Color.line
            dot.layer.cornerRadius = Metrics.pageSize / 2
            dot.snp.makeConstraints { make in
                make.size.equalTo(Metrics.pageSize)
            }
            pageIndicatorStack.addArrangedSubview(dot)
        }
    }
    
    private func startAutoScrollIfNeeded() {
        stopAutoScroll()
        
        guard shouldAutoScroll else { return }
        
        let timer = Timer(timeInterval: autoScrollInterval,
                          target: self,
                          selector: #selector(handleAutoScrollTimer),
                          userInfo: nil,
                          repeats: true)
        RunLoop.main.add(timer, forMode: .common)
        autoScrollTimer = timer
    }
    
    private func stopAutoScroll() {
        autoScrollTimer?.invalidate()
        autoScrollTimer = nil
    }
    
    private func scrollToPage(at index: Int, animated: Bool) {
        layoutIfNeeded()
        
        guard collectionView.bounds.width > 0, pageCount > 0 else { return }
        
        let safeIndex = min(max(index, 0), pageCount - 1)
        let indexPath = IndexPath(item: safeIndex, section: 0)
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: animated)
    }
    
    private func updateCurrentIndex(from scrollView: UIScrollView) {
        let pageWidth = scrollView.bounds.width
        guard pageWidth > 0 else { return }
        
        let index = Int(round(scrollView.contentOffset.x / pageWidth))
        currentIndex = min(max(index, 0), pageCount - 1)
        updatePageIndicator(count: pageCount, selectedIndex: currentIndex)
    }
    
    @objc private func handleAutoScrollTimer() {
        guard shouldAutoScroll else {
            stopAutoScroll()
            return
        }
        
        let nextIndex = (currentIndex + 1) % pageCount
        currentIndex = nextIndex
        updatePageIndicator(count: pageCount, selectedIndex: nextIndex)
        scrollToPage(at: nextIndex, animated: true)
    }
}

extension HomeBannerView: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        pageCount
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HomeBannerCollectionViewCell.reuseIdentifier,
                                                           for: indexPath) as? HomeBannerCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        cell.configure(title: title(at: indexPath.item),
                       imageUrl: imageUrl(at: indexPath.item))
        cell.onShareTap = { [weak self] in
            guard let self else { return }
            self.currentIndex = indexPath.item
            self.updatePageIndicator(count: self.pageCount, selectedIndex: self.currentIndex)
            self.delegate?.didTapShare()
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: collectionView.bounds.width,
               height: Metrics.heroHeight + Metrics.bottomHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        currentIndex = indexPath.item
        updatePageIndicator(count: pageCount, selectedIndex: currentIndex)
        delegate?.didTapBanner(currentBanner)
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        stopAutoScroll()
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        updateCurrentIndex(from: scrollView)
        startAutoScrollIfNeeded()
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        updateCurrentIndex(from: scrollView)
    }
}

private final class HomeBannerCollectionViewCell: UICollectionViewCell {
    static let reuseIdentifier = "HomeBannerCollectionViewCell"
    
    var onShareTap: (() -> Void)?
    
    private let heroImageView = RemoteImageView()
    private let bottomContainer = UIView()
    private let titleLabel = UILabel()
    private let shareButton = UIButton(type: .custom)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        onShareTap = nil
        titleLabel.text = nil
        heroImageView.cancelImageLoad()
        heroImageView.image = nil
    }
    
    func configure(title: String, imageUrl: String?) {
        titleLabel.text = title
        heroImageView.setImage(urlString: imageUrl)
    }
    
    private func setupUI() {
        contentView.backgroundColor = .white
        
        heroImageView.contentMode = .scaleAspectFill
        heroImageView.clipsToBounds = true
        
        bottomContainer.backgroundColor = .white
        
        titleLabel.textColor = HomeDesign.Color.textSecondary
        titleLabel.font = .dmSansFont(ofSize: 14, weight: .regular)
        titleLabel.numberOfLines = 2
        titleLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        shareButton.backgroundColor = HomeDesign.Color.headerBlue
        shareButton.layer.cornerRadius = 15
        shareButton.setTitle("Share", for: .normal)
        shareButton.setTitleColor(.white, for: .normal)
        shareButton.titleLabel?.font = .dmSansFont(ofSize: 14, weight: .semibold)
        shareButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        shareButton.addTarget(self, action: #selector(shareTapped), for: .touchUpInside)
        
        contentView.addSubview(heroImageView)
        contentView.addSubview(bottomContainer)
        bottomContainer.addSubview(titleLabel)
        bottomContainer.addSubview(shareButton)
        
        heroImageView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(100)
        }
        
        bottomContainer.snp.makeConstraints { make in
            make.top.equalTo(heroImageView.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(50)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(10)
            make.centerY.equalToSuperview()
            make.trailing.lessThanOrEqualTo(shareButton.snp.leading).offset(-10)
        }
        
        shareButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(10)
            make.centerY.equalToSuperview()
            make.height.equalTo(30)
        }
    }
    
    @objc private func shareTapped() {
        onShareTap?()
    }
}
