import UIKit
import SnapKit

@MainActor
class HomeViewController: BaseViewController {
    private struct AssetSummary {
        let totalAmount: String
        let walletBalance: String
        let totalAssetValue: String
        let cashManagement: String
        let digitalInvesting: String
        let equity: String
        let cryptocurrency: String
    }
    
    // MARK: - UI Components
    private lazy var scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = false
        sv.backgroundColor = .white
        sv.contentInsetAdjustmentBehavior = .never
        return sv
    }()
    
    private lazy var contentView = UIView()
    private let gradientBackgroundLayer = CAGradientLayer()
    
    private var isAssetVisible = true
    
    private lazy var blueBackgroundView: UIView = {
        let v = UIView()
        v.clipsToBounds = true
        return v
    }()
    
    private lazy var headerView: HomeHeaderView = {
        let view = HomeHeaderView()
        view.delegate = self
        return view
    }()
    
    private lazy var balanceView: HomeBalanceView = {
        let view = HomeBalanceView()
        view.delegate = self
        return view
    }()
    
    private lazy var bannerView: HomeBannerView = {
        let view = HomeBannerView()
        view.delegate = self
        return view
    }()
    
    private lazy var actionsView: HomeActionButtonsView = {
        let view = HomeActionButtonsView()
        view.delegate = self
        return view
    }()
    
    private lazy var partnersView: HomePartnersView = {
        let view = HomePartnersView()
        return view
    }()
    
    private lazy var featuresView: HomeFeaturesView = {
        let view = HomeFeaturesView()
        view.delegate = self
        return view
    }()
    
    // MARK: - Lifecycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - Setup
    override func setupUI() {
        view.backgroundColor = .white
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }
        
        contentView.addSubview(blueBackgroundView)
        contentView.addSubview(headerView)
        contentView.addSubview(balanceView)
        contentView.addSubview(bannerView)
        contentView.addSubview(actionsView)
        contentView.addSubview(partnersView)
        contentView.addSubview(featuresView)
        
        blueBackgroundView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.bottom.equalTo(balanceView.snp.bottom).offset(AppConstants.Home.Screen.balanceBottomInsetInBlueArea)
        }
        
        headerView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(AppConstants.Home.Screen.headerHeight)
        }
        
        balanceView.snp.makeConstraints { make in
            make.top.equalTo(headerView.snp.bottom).offset(AppConstants.Home.Screen.headerToBalanceSpacing)
            make.leading.trailing.equalToSuperview()
        }
        
        bannerView.snp.makeConstraints { make in
            make.top.equalTo(blueBackgroundView.snp.bottom).offset(AppConstants.Home.Screen.bannerTopSpacing)
            make.leading.trailing.equalToSuperview().inset(AppConstants.Home.Screen.contentHorizontalInset)
        }
        
        actionsView.snp.makeConstraints { make in
            make.top.equalTo(bannerView.snp.bottom).offset(AppConstants.Home.Screen.sectionSpacing)
            make.leading.trailing.equalToSuperview().inset(AppConstants.Home.Screen.contentHorizontalInset)
        }
        
        partnersView.snp.makeConstraints { make in
            make.top.equalTo(actionsView.snp.bottom).offset(AppConstants.Home.Screen.sectionSpacing)
            make.leading.trailing.equalToSuperview().inset(AppConstants.Home.Screen.contentHorizontalInset)
        }
        
        featuresView.snp.makeConstraints { make in
            make.top.equalTo(partnersView.snp.bottom).offset(AppConstants.Home.Screen.featuresTopSpacing)
            make.leading.trailing.equalToSuperview().inset(AppConstants.Home.Screen.contentHorizontalInset)
            make.bottom.equalToSuperview().inset(AppConstants.Home.Screen.bottomInset)
        }
        
        gradientBackgroundLayer.colors = [
            AppTheme.Color.homeGradientCyan.cgColor,
            AppTheme.Color.homeSecondaryBlue.cgColor,
            AppTheme.Color.homeGradientIndigo.cgColor
        ]
        gradientBackgroundLayer.startPoint = CGPoint(x: 0.7, y: 0.0)
        gradientBackgroundLayer.endPoint = CGPoint(x: 0.2, y: 1.0)
        blueBackgroundView.layer.insertSublayer(gradientBackgroundLayer, at: 0)
    }
    
    override func setupBindings() {
    }
    
    override func setupData() {
        Task { [weak self] in
            guard let self = self else { return }
            await self.loadHomeData()
        }
    }
    
    // MARK: - Data Loading
    private func loadHomeData() async {
        async let preferredName = fetchPreferredName()
        async let assetSummary = fetchAssetSummary()
        
        let (name, summary) = await (preferredName, assetSummary)
        
        if let name {
            headerView.updateUserInfo(name)
        }
        
        balanceView.updateAssetData(totalAmount: summary.totalAmount,
                                    walletBalance: summary.walletBalance,
                                    totalAssetValue: summary.totalAssetValue,
                                    cashManagement: summary.cashManagement,
                                    digitalInvesting: summary.digitalInvesting,
                                    equity: summary.equity,
                                    cryptocurrency: summary.cryptocurrency)
        headerView.updateTotalAmount(summary.totalAmount)
        headerView.updateTimestamp("as of 9 Jun 2025 15:32")
        applyAssetVisibility()
    }
    
    private func fetchPreferredName() async -> String? {
        await Task.yield()
        return UserManager.shared.currentUser?.data.responses.preferredName
    }
    
    private func fetchAssetSummary() async -> AssetSummary {
        await Task.yield()
        return AssetSummary(totalAmount: "RM 124,000.00",
                            walletBalance: "RM 10,000.00",
                            totalAssetValue: "RM 83,000.00",
                            cashManagement: "RM 51,300.00",
                            digitalInvesting: "RM 12,300.00",
                            equity: "RM 20,400.00",
                            cryptocurrency: "RM 30,000.00")
    }
    
    // MARK: - Actions
    private func handleNotificationTap() {
        print("Notification tapped")
    }
    
    private func handleEyeIconTap() {
        isAssetVisible.toggle()
        applyAssetVisibility()
    }
    
    private func applyAssetVisibility() {
        headerView.setAssetVisibility(isAssetVisible)
        balanceView.setAssetVisibility(isAssetVisible)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientBackgroundLayer.frame = blueBackgroundView.bounds
        headerView.updateSafeAreaTopInset(view.safeAreaInsets.top)
    }
}

// MARK: - HomeHeaderViewDelegate
extension HomeViewController: HomeHeaderViewDelegate {
    func didTapNotification() {
        handleNotificationTap()
    }
    
    func didTapEyeIcon() {
        handleEyeIconTap()
    }
}

// MARK: - HomeBalanceViewDelegate
extension HomeViewController: HomeBalanceViewDelegate {
    func didTapBalanceItem(_ item: String) {
        print("Balance item tapped: \(item)")
    }
    
    func didTapSettings() {
        print("Settings tapped")
    }
}

// MARK: - HomeBannerViewDelegate
extension HomeViewController: HomeBannerViewDelegate {
    func didTapBanner() {
        print("Banner tapped")
    }
    
    func didTapShare() {
        print("Share tapped")
    }
}

// MARK: - HomeActionButtonsViewDelegate
extension HomeViewController: HomeActionButtonsViewDelegate {
    func didTapActionButton(_ action: HomeActionType) {
        print("Action tapped: \(action)")
        switch action {
        case .buySell:
            break
        case .wallet:
            break
        case .deposit:
            break
        case .transfer:
            break
        case .wealth:
            break
        case .save:
            break
        case .invest:
            break
        case .more:
            break
        }
    }
}

// MARK: - HomeFeaturesViewDelegate
extension HomeViewController: HomeFeaturesViewDelegate {
    func didTapFeature(_ feature: String) {
        print("Feature tapped: \(feature)")
    }
}
