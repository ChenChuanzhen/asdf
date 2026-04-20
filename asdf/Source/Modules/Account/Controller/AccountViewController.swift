import UIKit
import SnapKit
import SVProgressHUD

private enum AccountLayout {
    static let horizontalInset: CGFloat = 20
    static let contentTopSpacing: CGFloat = 10
    static let sectionSpacing: CGFloat = 14
    static let cardSpacing: CGFloat = 12
    static let cardCornerRadius: CGFloat = 16
    static let contentBottomInset: CGFloat = 20
    static let rowHeight: CGFloat = 32
}

@MainActor
final class AccountViewController: BaseViewController {
    
    private lazy var scrollView: UIScrollView = {
        let view = UIScrollView()
        view.showsVerticalScrollIndicator = false
        view.alwaysBounceVertical = true
        view.backgroundColor = .white
        return view
    }()
    
    private let contentView = UIView()
    
    private lazy var stackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.spacing = AccountLayout.sectionSpacing
        return view
    }()
    
    private let headerView = AccountHeaderView()
    private let referralCardView = AccountReferralCardView()
    private let notificationPromptView = AccountNotificationPromptView()
    
    private lazy var primarySectionView = AccountMenuSectionView()
    private lazy var supportSectionView = AccountMenuSectionView()
    private lazy var logoutSectionView = AccountMenuSectionView()
    
    private var currentViewState: AccountViewState?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func setupUI() {
        view.backgroundColor = .white
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(stackView)
        
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }
        
        stackView.snp.makeConstraints { make in
            make.top.equalTo(contentView.safeAreaLayoutGuide.snp.top).offset(AccountLayout.contentTopSpacing)
            make.leading.trailing.equalToSuperview().inset(AccountLayout.horizontalInset)
            make.bottom.equalToSuperview().inset(AccountLayout.contentBottomInset)
        }
        
        let topStack = UIStackView(arrangedSubviews: [headerView, referralCardView, notificationPromptView])
        topStack.axis = .vertical
        topStack.spacing = AccountLayout.cardSpacing
        
        stackView.addArrangedSubview(topStack)
        stackView.addArrangedSubview(primarySectionView)
        stackView.addArrangedSubview(supportSectionView)
        stackView.addArrangedSubview(logoutSectionView)
        
        referralCardView.onCopyTapped = { [weak self] in
            guard let code = self?.currentViewState?.referralCode else { return }
            UIPasteboard.general.string = code
            SVProgressHUD.showSuccess(withStatus: "Referral code copied")
        }
        
        referralCardView.onShareTapped = { [weak self] in
            guard let self, let code = currentViewState?.referralCode else { return }
            let activity = UIActivityViewController(activityItems: [code], applicationActivities: nil)
            present(activity, animated: true)
        }
        
        notificationPromptView.onPrimaryTapped = { [weak self] in
            self?.handleAction(.enableNotifications)
        }
        
        primarySectionView.onItemSelected = { [weak self] action in
            self?.handleAction(action)
        }
        
        supportSectionView.onItemSelected = { [weak self] action in
            self?.handleAction(action)
        }
        
        logoutSectionView.onItemSelected = { [weak self] action in
            self?.handleAction(action)
        }
    }
    
    override func setupData() {
        render(makeInitialViewState())
    }
    
    private func render(_ viewState: AccountViewState) {
        currentViewState = viewState
        
        headerView.configure(with: viewState)
        referralCardView.configure(with: viewState)
        notificationPromptView.isHidden = viewState.isNotificationEnabled
        
        let sections = viewState.sections
        primarySectionView.configure(with: sections[safe: 0] ?? [])
        supportSectionView.configure(with: sections[safe: 1] ?? [])
        logoutSectionView.configure(with: sections[safe: 2] ?? [])
    }
    
    func updateNotificationStatus(isEnabled: Bool) {
        guard var state = currentViewState else { return }
        state.isNotificationEnabled = isEnabled
        render(state)
    }
    
    private func makeInitialViewState() -> AccountViewState {
        let preferredName = UserManager.shared.currentUser?.data.responses.preferredName
        let displayName = (preferredName?.isEmpty == false ? preferredName : nil) ?? "John Doe"
        
        return AccountViewState(
            displayName: displayName,
            verificationText: "Verified",
            campaignMessage: "Stay tuned for our upcoming campaigns.",
            referralCode: "GHFY - 133 - 9506",
            isNotificationEnabled: false,
            sections: [
                [
                    AccountMenuItem(title: "Personal Information", icon: .person, action: .personalInformation),
                    AccountMenuItem(title: "Accounts Management", icon: .accounts, action: .accountsManagement),
                    AccountMenuItem(title: "Wealth", icon: .wealth, badgeText: "New", action: .wealth),
                    AccountMenuItem(title: "Notification Settings", icon: .notification, action: .notificationSettings),
                    AccountMenuItem(title: "Security Center", icon: .security, action: .securityCenter)
                ],
                [
                    AccountMenuItem(title: "Feedback", icon: .feedback, action: .feedback),
                    AccountMenuItem(title: "Fees and Charges", icon: .fees, action: .feesAndCharges),
                    AccountMenuItem(title: "Contact Us", icon: .contact, action: .contactUs),
                    AccountMenuItem(title: "FAQ", icon: .faq, action: .faq),
                    AccountMenuItem(title: "About KDi GO", icon: .about, action: .about)
                ],
                [
                    AccountMenuItem(title: "Log Out", icon: .logout, action: .logout)
                ]
            ]
        )
    }
    
    private func handleAction(_ action: AccountAction) {
        switch action {
        case .logout:
            presentLogoutSheet()
        case .enableNotifications:
            if let settingsURL = URL(string: UIApplication.openSettingsURLString),
               UIApplication.shared.canOpenURL(settingsURL) {
                UIApplication.shared.open(settingsURL)
            }
        default:
            print("Selected account action: \(action)")
        }
    }
    
    private func presentLogoutSheet() {
        let logoutImage = UIImage(systemName: "rectangle.portrait.and.arrow.right")?
            .withConfiguration(UIImage.SymbolConfiguration(pointSize: 34, weight: .medium))
            .withTintColor(AccountDesign.Color.primaryBlue, renderingMode: .alwaysOriginal)
        
        CommonSheetView.show(
            configuration: .init(
                titleImage: logoutImage,
                title: "Are you sure\nyou want to log out?",
                message: nil,
                primaryAction: .init(title: "Log Out") { [weak self] in
                    self?.performLogout()
                },
                secondaryAction: .init(title: "Cancel", style: .secondary),
                showsContactSupport: false
            )
        )
    }
    
    private func performLogout() {
        Task { [weak self] in
            guard self != nil else { return }
            
            let isLoggedOut = await AuthService.shared.logout(token: TokenManager.shared.accessToken ?? "", showLoading: true)
            if isLoggedOut {
                AppRouter.shared.navigateToLogin()
            } else {
                SVProgressHUD.showError(withStatus: "Logout failed")
            }
        }
    }
}

private struct AccountViewState {
    let displayName: String
    let verificationText: String
    let campaignMessage: String
    let referralCode: String
    var isNotificationEnabled: Bool
    let sections: [[AccountMenuItem]]
}

private struct AccountMenuItem {
    let title: String
    let icon: AccountMenuIcon
    var badgeText: String? = nil
    let action: AccountAction
}

private enum AccountAction: CustomStringConvertible {
    case personalInformation
    case accountsManagement
    case wealth
    case notificationSettings
    case securityCenter
    case feedback
    case feesAndCharges
    case contactUs
    case faq
    case about
    case enableNotifications
    case logout
    
    var description: String {
        switch self {
        case .personalInformation: return "personalInformation"
        case .accountsManagement: return "accountsManagement"
        case .wealth: return "wealth"
        case .notificationSettings: return "notificationSettings"
        case .securityCenter: return "securityCenter"
        case .feedback: return "feedback"
        case .feesAndCharges: return "feesAndCharges"
        case .contactUs: return "contactUs"
        case .faq: return "faq"
        case .about: return "about"
        case .enableNotifications: return "enableNotifications"
        case .logout: return "logout"
        }
    }
}

private enum AccountMenuIcon {
    case person
    case accounts
    case wealth
    case notification
    case security
    case feedback
    case fees
    case contact
    case faq
    case about
    case logout
    
    var systemName: String {
        switch self {
        case .person:
            return "person.text.rectangle"
        case .accounts:
            return "list.bullet.clipboard"
        case .wealth:
            return "dollarsign.circle"
        case .notification:
            return "bell"
        case .security:
            return "shield"
        case .feedback:
            return "bubble.left.and.text.bubble.right"
        case .fees:
            return "bag"
        case .contact:
            return "envelope"
        case .faq:
            return "questionmark.circle"
        case .about:
            return "info.circle"
        case .logout:
            return "rectangle.portrait.and.arrow.right"
        }
    }
}

private enum AccountDesign {
    enum Color {
        static let primaryBlue = UIColor(hex: "#0D42BA")
        static let deepBlue = UIColor(hex: "#0134A6")
        static let softBlue = UIColor(hex: "#ABCEFF")
        static let title = UIColor(hex: "#202123")
        static let body = UIColor(hex: "#031D45")
        static let line = UIColor(hex: "#D5D5D7")
        static let lightLine = UIColor(hex: "#E6E6E6")
        static let cardBackground = UIColor(hex: "#F9FAFB")
        static let badgeBlue = UIColor(hex: "#39A3FB")
        static let badgeGreen = UIColor(hex: "#158D02")
        static let notificationText = UIColor(hex: "#161616")
        static let verificationGreen = UIColor(hex: "#158D02")
    }
}

private final class AccountHeaderView: UIView {
    
    private let avatarView = AccountAvatarView()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .dmSansFont(ofSize: 20, weight: .bold)
        label.textColor = AccountDesign.Color.title
        return label
    }()
    
    private let verifiedIconView: UIImageView = {
        let view = UIImageView(image: UIImage(systemName: "checkmark.seal.fill"))
        view.tintColor = AccountDesign.Color.verificationGreen
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    private let verifiedLabel: UILabel = {
        let label = UILabel()
        label.font = .dmSansFont(ofSize: 12, weight: .regular)
        label.textColor = AccountDesign.Color.title
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with viewState: AccountViewState) {
        nameLabel.text = viewState.displayName
        verifiedLabel.text = viewState.verificationText
    }
    
    private func setupUI() {
        addSubview(avatarView)
        addSubview(nameLabel)
        addSubview(verifiedIconView)
        addSubview(verifiedLabel)
        
        avatarView.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview()
            make.size.equalTo(40)
        }
        
        nameLabel.snp.makeConstraints { make in
            make.leading.equalTo(avatarView.snp.trailing).offset(12)
            make.top.equalToSuperview().offset(2)
            make.trailing.lessThanOrEqualToSuperview()
        }
        
        verifiedIconView.snp.makeConstraints { make in
            make.leading.equalTo(nameLabel)
            make.bottom.equalToSuperview().inset(2)
            make.size.equalTo(14)
        }
        
        verifiedLabel.snp.makeConstraints { make in
            make.leading.equalTo(verifiedIconView.snp.trailing).offset(4)
            make.centerY.equalTo(verifiedIconView)
            make.trailing.lessThanOrEqualToSuperview()
        }
    }
}

private final class AccountAvatarView: UIView {
    
    private let headView = UIView()
    private let bodyView = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = AccountDesign.Color.primaryBlue
        layer.cornerRadius = 20
        clipsToBounds = true
        
        headView.backgroundColor = .white
        headView.layer.cornerRadius = 7
        
        bodyView.backgroundColor = UIColor.white.withAlphaComponent(0.95)
        bodyView.layer.cornerRadius = 14
        
        addSubview(bodyView)
        addSubview(headView)
        
        headView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(8)
            make.size.equalTo(14)
        }
        
        bodyView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(8)
            make.width.equalTo(28)
            make.height.equalTo(20)
        }
    }
}

private final class AccountReferralCardView: UIView {
    
    private enum Layout {
        static let outerCornerRadius: CGFloat = 15
        static let innerCornerRadius: CGFloat = 15
        static let outerHorizontalInset: CGFloat = 20
        static let outerVerticalInset: CGFloat = 24
        static let topRowBottomSpacing: CGFloat = 24
        static let campaignIconBackgroundSize: CGFloat = 32
        static let campaignIconSize: CGFloat = 20
        static let topRowIconSpacing: CGFloat = 14
        static let innerHorizontalInset: CGFloat = 24
        static let innerVerticalInset: CGFloat = 20
        static let referralLabelSpacing: CGFloat = 0
        static let actionSpacing: CGFloat = 16
        static let actionIconSize: CGFloat = 24
        static let minimumInnerHeight: CGFloat = 58
    }
    
    var onCopyTapped: (() -> Void)?
    var onShareTapped: (() -> Void)?
    
    private let campaignContainer: UIView = {
        let view = UIView()
        view.backgroundColor = AccountDesign.Color.primaryBlue
        view.layer.cornerRadius = Layout.outerCornerRadius
        view.clipsToBounds = true
        return view
    }()
    
    private let campaignIconBackground: UIView = {
        let view = UIView()
        view.backgroundColor = AccountDesign.Color.softBlue
        view.layer.cornerRadius = Layout.campaignIconBackgroundSize / 2
        return view
    }()
    
    private let campaignIconView: UIImageView = {
        let image = UIImage(systemName: "megaphone.fill")?.withConfiguration(UIImage.SymbolConfiguration(pointSize: 12, weight: .medium))
        let view = UIImageView(image: image)
        view.tintColor = AccountDesign.Color.primaryBlue
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    private let campaignLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .dmSansFont(ofSize: 14, weight: .regular)
        label.textColor = AccountDesign.Color.softBlue
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return label
    }()
    
    private let referralContainer: UIView = {
        let view = UIView()
        view.backgroundColor = AccountDesign.Color.deepBlue
        view.layer.cornerRadius = Layout.innerCornerRadius
        return view
    }()
    
    private let referralTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .dmSansFont(ofSize: 12, weight: .regular)
        label.textColor = UIColor.white.withAlphaComponent(0.8)
        label.text = "Referral Code"
        return label
    }()
    
    private let referralValueLabel: UILabel = {
        let label = UILabel()
        label.font = .dmSansFont(ofSize: 14, weight: .regular)
        label.textColor = .white
        return label
    }()
    
    private lazy var copyButton = makeActionButton(systemName: "doc.on.doc.fill", pointSize: 18, action: #selector(handleCopy))
    private lazy var shareButton = makeActionButton(systemName: "shareplay", pointSize: 18, action: #selector(handleShare))
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with viewState: AccountViewState) {
        campaignLabel.text = viewState.campaignMessage
        referralValueLabel.text = viewState.referralCode
    }
    
    private func setupUI() {
        addSubview(campaignContainer)
        campaignContainer.addSubview(campaignIconBackground)
        campaignIconBackground.addSubview(campaignIconView)
        campaignContainer.addSubview(campaignLabel)
        campaignContainer.addSubview(referralContainer)
        
        let referralTextStack = UIStackView(arrangedSubviews: [referralTitleLabel, referralValueLabel])
        referralTextStack.axis = .vertical
        referralTextStack.spacing = Layout.referralLabelSpacing
        
        let actionsStack = UIStackView(arrangedSubviews: [copyButton, shareButton])
        actionsStack.axis = .horizontal
        actionsStack.alignment = .center
        actionsStack.spacing = Layout.actionSpacing
        
        referralContainer.addSubview(referralTextStack)
        referralContainer.addSubview(actionsStack)
        
        campaignContainer.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        campaignIconBackground.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(Layout.outerHorizontalInset)
            make.top.equalToSuperview().inset(Layout.outerVerticalInset)
            make.size.equalTo(Layout.campaignIconBackgroundSize)
        }
        
        campaignIconView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(Layout.campaignIconSize)
        }
        
        campaignLabel.snp.makeConstraints { make in
            make.leading.equalTo(campaignIconBackground.snp.trailing).offset(Layout.topRowIconSpacing)
            make.trailing.equalToSuperview().inset(Layout.outerHorizontalInset)
            make.centerY.equalTo(campaignIconBackground)
        }
        
        referralContainer.snp.makeConstraints { make in
            make.top.equalTo(campaignIconBackground.snp.bottom).offset(Layout.topRowBottomSpacing)
            make.leading.trailing.equalToSuperview().inset(12)
            make.bottom.equalToSuperview().inset(12)
            make.height.greaterThanOrEqualTo(Layout.minimumInnerHeight)
        }
        
        referralTextStack.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(Layout.innerHorizontalInset)
            make.centerY.equalToSuperview()
            make.top.greaterThanOrEqualToSuperview().inset(Layout.innerVerticalInset - 2)
            make.bottom.lessThanOrEqualToSuperview().inset(Layout.innerVerticalInset - 2)
        }
        
        actionsStack.snp.makeConstraints { make in
            make.leading.greaterThanOrEqualTo(referralTextStack.snp.trailing).offset(12)
            make.trailing.equalToSuperview().inset(Layout.innerHorizontalInset)
            make.centerY.equalToSuperview()
        }
        
        copyButton.snp.makeConstraints { make in
            make.size.equalTo(Layout.actionIconSize)
        }
        
        shareButton.snp.makeConstraints { make in
            make.size.equalTo(Layout.actionIconSize)
        }
    }
    
    private func makeActionButton(systemName: String, pointSize: CGFloat, action: Selector) -> UIButton {
        let button = UIButton(type: .system)
        button.tintColor = .white
        let image = UIImage(systemName: systemName)?.withConfiguration(UIImage.SymbolConfiguration(pointSize: pointSize, weight: .medium))
        button.setImage(image, for: .normal)
        button.addTarget(self, action: action, for: .touchUpInside)
        return button
    }
    
    @objc private func handleCopy() {
        onCopyTapped?()
    }
    
    @objc private func handleShare() {
        onShareTapped?()
    }
}

private final class AccountNotificationPromptView: UIView {
    
    var onPrimaryTapped: (() -> Void)?
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .dmSansFont(ofSize: 14, weight: .medium)
        label.textColor = .black
        label.textAlignment = .center
        label.text = "Your notifications are off"
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .dmSansFont(ofSize: 12, weight: .regular)
        label.textColor = AccountDesign.Color.notificationText
        label.textAlignment = .center
        label.text = "Enable push notifications in your device settings to receive important updates."
        return label
    }()
    
    private lazy var actionButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = AccountDesign.Color.badgeGreen
        button.layer.cornerRadius = 8
        button.setTitle("Enable Push Notifications", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .dmSansFont(ofSize: 14, weight: .medium)
        button.addTarget(self, action: #selector(handleTap), for: .touchUpInside)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        layer.cornerRadius = 10
        layer.borderWidth = 1
        layer.borderColor = AccountDesign.Color.line.cgColor
        backgroundColor = .white
        
        addSubview(titleLabel)
        addSubview(descriptionLabel)
        addSubview(actionButton)
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(14)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(28)
        }
        
        actionButton.snp.makeConstraints { make in
            make.top.equalTo(descriptionLabel.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(34)
            make.height.equalTo(44)
            make.bottom.equalToSuperview().inset(14)
        }
    }
    
    @objc private func handleTap() {
        onPrimaryTapped?()
    }
}

private final class AccountMenuSectionView: UIView {
    
    var onItemSelected: ((AccountAction) -> Void)?
    
    private let stackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.spacing = 8
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with items: [AccountMenuItem]) {
        stackView.arrangedSubviews.forEach {
            stackView.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }
        
        isHidden = items.isEmpty
        
        items.forEach { item in
            let rowView = AccountMenuRowView()
            rowView.configure(with: item)
            rowView.onTap = { [weak self] in
                self?.onItemSelected?(item.action)
            }
            stackView.addArrangedSubview(rowView)
            rowView.snp.makeConstraints { make in
                make.height.equalTo(AccountLayout.rowHeight)
            }
        }
    }
    
    private func setupUI() {
        backgroundColor = AccountDesign.Color.cardBackground
        layer.cornerRadius = AccountLayout.cardCornerRadius
        
        addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 14, left: 14, bottom: 14, right: 14))
        }
    }
}

private final class AccountMenuRowView: UIControl {
    
    var onTap: (() -> Void)?
    
    private let iconView: UIImageView = {
        let view = UIImageView()
        view.tintColor = AccountDesign.Color.primaryBlue
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .dmSansFont(ofSize: 14, weight: .semibold)
        label.textColor = AccountDesign.Color.body
        return label
    }()
    
    private let badgeLabel: PaddingLabel = {
        let label = PaddingLabel()
        label.insets = UIEdgeInsets(top: 2, left: 6, bottom: 2, right: 6)
        label.font = .dmSansFont(ofSize: 12, weight: .bold)
        label.textColor = .white
        label.backgroundColor = AccountDesign.Color.badgeBlue
        label.layer.cornerRadius = 5
        label.clipsToBounds = true
        label.isHidden = true
        return label
    }()
    
    private let chevronView: UIImageView = {
        let view = UIImageView(image: UIImage(systemName: "chevron.right"))
        view.tintColor = UIColor(hex: "#A6A6A6")
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with item: AccountMenuItem) {
        iconView.image = UIImage(systemName: item.icon.systemName)
        titleLabel.text = item.title
        badgeLabel.text = item.badgeText
        badgeLabel.isHidden = item.badgeText == nil
    }
    
    private func setupUI() {
        addTarget(self, action: #selector(handleTap), for: .touchUpInside)
        
        let titleStack = UIStackView(arrangedSubviews: [titleLabel, badgeLabel])
        titleStack.axis = .horizontal
        titleStack.spacing = 8
        titleStack.alignment = .center
        
        addSubview(iconView)
        addSubview(titleStack)
        addSubview(chevronView)
        
        iconView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(2)
            make.centerY.equalToSuperview()
            make.size.equalTo(18)
        }
        
        titleStack.snp.makeConstraints { make in
            make.leading.equalTo(iconView.snp.trailing).offset(14)
            make.centerY.equalToSuperview()
        }
        
        chevronView.snp.makeConstraints { make in
            make.leading.greaterThanOrEqualTo(titleStack.snp.trailing).offset(8)
            make.trailing.equalToSuperview()
            make.centerY.equalToSuperview()
            make.size.equalTo(14)
        }
    }
    
    @objc private func handleTap() {
        onTap?()
    }
}

private final class PaddingLabel: UILabel {
    var insets = UIEdgeInsets.zero
    
    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: size.width + insets.left + insets.right,
                      height: size.height + insets.top + insets.bottom)
    }
    
    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: insets))
    }
}

private extension Array {
    subscript(safe index: Int) -> Element? {
        guard indices.contains(index) else { return nil }
        return self[index]
    }
}
