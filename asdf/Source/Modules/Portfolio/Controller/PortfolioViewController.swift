import UIKit
import SnapKit

fileprivate enum PortfolioColor {
    static let textPrimary = UIColor(hex: "#202123")
    static let textNavy = UIColor(hex: "#031D45")
    static let textMuted = UIColor(hex: "#9FA4AB")
    static let blue = UIColor(hex: "#0D42BA")
    static let blueDark = UIColor(hex: "#003584")
    static let blueSoft = UIColor(hex: "#E7F1FF")
    static let divider = UIColor(hex: "#E6E6E6")
    static let border = UIColor(hex: "#DBDEEA")
    static let chipSelected = UIColor(hex: "#00007D")
    static let kdiInvest = UIColor(hex: "#214CBC")
    static let kdiSave = UIColor(hex: "#69A9D3")
    static let kdx = UIColor(hex: "#6F3DE9")
    static let rakuten = UIColor(hex: "#CF2369")
    static let kenanga = UIColor(hex: "#1A6F7E")
    static let callout = UIColor(hex: "#2C2C31")
}

@MainActor
final class PortfolioViewController: BaseViewController {
    
    private struct PortfolioItem {
        let name: String
        let partner: String
        let valueText: String
        let logoURL: String
        let dotColor: UIColor
        let share: CGFloat
    }
    
    private enum Layout {
        static let sideInset: CGFloat = 18
        static let sectionGap: CGFloat = 22
        static let rowGap: CGFloat = 0
        static let bottomInset: CGFloat = 112
    }
    
    private let items: [PortfolioItem] = [
        .init(
            name: "KDI Save",
            partner: "Kenanga Digital Investing",
            valueText: "RM 51,300.00",
            logoURL: "https://www.figma.com/api/mcp/asset/f811c9a9-9b3b-4258-9867-71c84824f2e2",
            dotColor: PortfolioColor.kdiSave,
            share: 0.15
        ),
        .init(
            name: "KDI Invest",
            partner: "Kenanga Digital Investing",
            valueText: "RM 12,300.00",
            logoURL: "https://www.figma.com/api/mcp/asset/f811c9a9-9b3b-4258-9867-71c84824f2e2",
            dotColor: PortfolioColor.kdiInvest,
            share: 0.25
        ),
        .init(
            name: "Kenanga Money",
            partner: "Merchantrade",
            valueText: "RM 10,000.00",
            logoURL: "https://www.figma.com/api/mcp/asset/8b7baff3-9d24-4fc8-b7f7-82f8b3c7ca08",
            dotColor: PortfolioColor.kenanga,
            share: 0.10
        ),
        .init(
            name: "KDX",
            partner: "Kinetic DAX Sdn Bhd",
            valueText: "RM 20,400.00",
            logoURL: "https://www.figma.com/api/mcp/asset/ae5f494c-0203-4a20-a736-de6c0ec4b0f6",
            dotColor: PortfolioColor.kdx,
            share: 0.28
        ),
        .init(
            name: "Rakuten Trade",
            partner: "Rakuten Trade",
            valueText: "RM 12,000.00",
            logoURL: "https://www.figma.com/api/mcp/asset/de641e8b-6ca8-422e-9cc4-33935d6ccb52",
            dotColor: PortfolioColor.rakuten,
            share: 0.22
        )
    ]
    
    private var selectedName: String? = "KDX"
    private var isAssetVisible = true
    
    private lazy var scrollView: UIScrollView = {
        let view = UIScrollView()
        view.showsVerticalScrollIndicator = false
        view.alwaysBounceVertical = true
        view.backgroundColor = .white
        return view
    }()
    
    private let contentView = UIView()
    private let headerView = PortfolioHeaderSummaryView()
    private let chartPanel = PortfolioChartPanelView()
    private let sectionTitleLabel = UILabel()
    private let modeSwitch = PortfolioModeSwitchView()
    private let listStack = UIStackView()
    private let addButton = UIButton(type: .system)
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
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
        
        headerView.onEyeTapped = { [weak self] in
            self?.isAssetVisible.toggle()
            self?.render()
        }
        
        chartPanel.onChipSelected = { [weak self] name in
            self?.selectedName = name
            self?.render()
        }
        
        sectionTitleLabel.text = "My portfolio"
        sectionTitleLabel.textColor = PortfolioColor.textPrimary
        sectionTitleLabel.font = .dmSansFont(ofSize: 25, weight: .bold)
        
        listStack.axis = .vertical
        listStack.spacing = Layout.rowGap
        
        addButton.setTitle("Add an account", for: .normal)
        addButton.setTitleColor(PortfolioColor.blue, for: .normal)
        addButton.titleLabel?.font = .dmSansFont(ofSize: 24, weight: .bold)
        addButton.backgroundColor = .white
        addButton.layer.cornerRadius = 13
        addButton.layer.borderWidth = 1.5
        addButton.layer.borderColor = PortfolioColor.border.cgColor
        
        contentView.addSubview(headerView)
        contentView.addSubview(chartPanel)
        contentView.addSubview(sectionTitleLabel)
        contentView.addSubview(modeSwitch)
        contentView.addSubview(listStack)
        contentView.addSubview(addButton)
        
        headerView.snp.makeConstraints { make in
            make.top.equalTo(contentView.safeAreaLayoutGuide.snp.top).offset(8)
            make.leading.trailing.equalToSuperview().inset(Layout.sideInset)
        }
        
        chartPanel.snp.makeConstraints { make in
            make.top.equalTo(headerView.snp.bottom).offset(18)
            make.leading.trailing.equalToSuperview()
        }
        
        sectionTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(chartPanel.snp.bottom).offset(28)
            make.leading.equalToSuperview().inset(Layout.sideInset)
        }
        
        modeSwitch.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(Layout.sideInset)
            make.centerY.equalTo(sectionTitleLabel)
            make.width.equalTo(136)
            make.height.equalTo(44)
        }
        
        listStack.snp.makeConstraints { make in
            make.top.equalTo(sectionTitleLabel.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(Layout.sideInset)
        }
        
        addButton.snp.makeConstraints { make in
            make.top.equalTo(listStack.snp.bottom).offset(24)
            make.leading.trailing.equalToSuperview().inset(Layout.sideInset)
            make.height.equalTo(58)
            make.bottom.equalToSuperview().inset(Layout.bottomInset)
        }
    }
    
    override func setupData() {
        items.enumerated().forEach { index, item in
            let row = PortfolioListRowView()
            row.configure(
                name: item.name,
                partner: item.partner,
                valueText: item.valueText,
                logoURL: item.logoURL,
                dotColor: item.dotColor,
                showsDivider: index < items.count - 1
            )
            listStack.addArrangedSubview(row)
        }
        
        render()
    }
    
    private func render() {
        headerView.configure(
            totalValue: isAssetVisible ? "RM 106,000.00" : "RM ••••••••",
            availableCash: isAssetVisible ? "RM 10,000.00" : "RM ••••••••",
            investedValue: isAssetVisible ? "RM 96,000.00" : "RM ••••••••",
            isVisible: isAssetVisible
        )
        
        chartPanel.configure(
            items: items.map {
                PortfolioChartPanelView.ChartItem(
                    name: $0.name,
                    valueText: $0.name == "KDX" ? "RM 20,400.00" : $0.valueText,
                    share: $0.share,
                    color: $0.dotColor
                )
            },
            selectedName: selectedName,
            isAssetVisible: isAssetVisible
        )
        
        listStack.arrangedSubviews.compactMap { $0 as? PortfolioListRowView }.forEach { row in
            row.setValueVisible(isAssetVisible)
        }
    }
}

private final class PortfolioHeaderSummaryView: UIView {
    
    var onEyeTapped: (() -> Void)?
    
    private let titleRow = UIStackView()
    private let titleLabel = UILabel()
    private let eyeButton = UIButton(type: .system)
    private let amountLabel = UILabel()
    private let timeLabel = UILabel()
    private let divider = UIView()
    private let metricsStack = UIStackView()
    private let cashView = PortfolioMiniMetricView(title: "Available cash")
    private let investView = PortfolioMiniMetricView(title: "You invested")
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        titleRow.axis = .horizontal
        titleRow.alignment = .center
        titleRow.spacing = 4
        
        titleLabel.text = "Total asset value"
        titleLabel.textColor = PortfolioColor.textPrimary
        titleLabel.font = .dmSansFont(ofSize: 22, weight: .medium)
        
        eyeButton.tintColor = PortfolioColor.blue
        eyeButton.setImage(UIImage(systemName: "eye"), for: .normal)
        eyeButton.setPreferredSymbolConfiguration(.init(pointSize: 18, weight: .medium), forImageIn: .normal)
        eyeButton.addTarget(self, action: #selector(handleEyeTap), for: .touchUpInside)
        
        amountLabel.textColor = PortfolioColor.blue
        amountLabel.font = .robotoFont(ofSize: 34, weight: .bold)
        
        timeLabel.text = "as of 11 Oct 2024 15:32"
        timeLabel.textColor = PortfolioColor.textMuted
        timeLabel.font = .dmSansFont(ofSize: 13, weight: .regular)
        
        divider.backgroundColor = PortfolioColor.divider
        
        metricsStack.axis = .horizontal
        metricsStack.distribution = .fillEqually
        metricsStack.spacing = 20
        
        addSubview(titleRow)
        addSubview(amountLabel)
        addSubview(timeLabel)
        addSubview(divider)
        addSubview(metricsStack)
        
        titleRow.addArrangedSubview(titleLabel)
        titleRow.addArrangedSubview(eyeButton)
        metricsStack.addArrangedSubview(cashView)
        metricsStack.addArrangedSubview(investView)
        
        titleRow.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }
        
        eyeButton.snp.makeConstraints { make in
            make.size.equalTo(24)
        }
        
        amountLabel.snp.makeConstraints { make in
            make.top.equalTo(titleRow.snp.bottom).offset(4)
            make.leading.trailing.equalToSuperview()
        }
        
        timeLabel.snp.makeConstraints { make in
            make.top.equalTo(amountLabel.snp.bottom).offset(4)
            make.leading.trailing.equalToSuperview()
        }
        
        divider.snp.makeConstraints { make in
            make.top.equalTo(timeLabel.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(1)
        }
        
        metricsStack.snp.makeConstraints { make in
            make.top.equalTo(divider.snp.bottom).offset(16)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    func configure(totalValue: String, availableCash: String, investedValue: String, isVisible: Bool) {
        amountLabel.text = totalValue
        cashView.configure(value: availableCash)
        investView.configure(value: investedValue)
        eyeButton.setImage(UIImage(systemName: isVisible ? "eye" : "eye.slash"), for: .normal)
    }
    
    @objc private func handleEyeTap() {
        onEyeTapped?()
    }
}

private final class PortfolioMiniMetricView: UIView {
    
    private let iconView = UIImageView()
    private let titleRow = UIStackView()
    private let titleLabel = UILabel()
    private let chevronView = UIImageView()
    private let valueLabel = UILabel()
    
    init(title: String) {
        super.init(frame: .zero)
        titleLabel.text = title
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        let root = UIStackView()
        root.axis = .horizontal
        root.alignment = .center
        root.spacing = 10
        
        let textStack = UIStackView()
        textStack.axis = .vertical
        textStack.alignment = .leading
        textStack.spacing = 1
        
        iconView.tintColor = PortfolioColor.blue
        iconView.image = UIImage(systemName: "dollarsign.circle")
        iconView.preferredSymbolConfiguration = .init(pointSize: 21, weight: .medium)
        
        titleRow.axis = .horizontal
        titleRow.alignment = .center
        titleRow.spacing = 2
        
        titleLabel.textColor = PortfolioColor.textMuted
        titleLabel.font = .dmSansFont(ofSize: 13, weight: .regular)
        
        chevronView.tintColor = PortfolioColor.textMuted
        chevronView.image = UIImage(systemName: "chevron.right")
        chevronView.preferredSymbolConfiguration = .init(pointSize: 10, weight: .bold)
        
        valueLabel.textColor = PortfolioColor.textPrimary
        valueLabel.font = .robotoFont(ofSize: 18, weight: .bold)
        
        addSubview(root)
        root.addArrangedSubview(iconView)
        root.addArrangedSubview(textStack)
        textStack.addArrangedSubview(titleRow)
        textStack.addArrangedSubview(valueLabel)
        titleRow.addArrangedSubview(titleLabel)
        titleRow.addArrangedSubview(chevronView)
        
        root.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        iconView.snp.makeConstraints { make in
            make.size.equalTo(22)
        }
    }
    
    func configure(value: String) {
        valueLabel.text = value
    }
}

private final class PortfolioChartPanelView: UIView {
    
    struct ChartItem {
        let name: String
        let valueText: String
        let share: CGFloat
        let color: UIColor
    }
    
    var onChipSelected: ((String?) -> Void)?
    
    private var chartItems: [ChartItem] = []
    private var selectedName: String?
    private var selectedValueText = "RM 20,400.00"
    private var isAssetVisible = true
    
    private let donutView = PortfolioDonutView()
    private let firstRow = UIStackView()
    private let secondRow = UIStackView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = PortfolioColor.blueSoft
        
        firstRow.axis = .horizontal
        firstRow.alignment = .center
        firstRow.distribution = .fillProportionally
        firstRow.spacing = 10
        
        secondRow.axis = .horizontal
        secondRow.alignment = .center
        secondRow.distribution = .fillProportionally
        secondRow.spacing = 10
        
        addSubview(donutView)
        addSubview(firstRow)
        addSubview(secondRow)
        
        donutView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(18)
            make.centerX.equalToSuperview()
            make.size.equalTo(286)
        }
        
        firstRow.snp.makeConstraints { make in
            make.top.equalTo(donutView.snp.bottom).offset(18)
            make.centerX.equalToSuperview()
            make.leading.greaterThanOrEqualToSuperview().offset(18)
            make.trailing.lessThanOrEqualToSuperview().offset(-18)
        }
        
        secondRow.snp.makeConstraints { make in
            make.top.equalTo(firstRow.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
            make.leading.greaterThanOrEqualToSuperview().offset(18)
            make.trailing.lessThanOrEqualToSuperview().offset(-18)
            make.bottom.equalToSuperview().inset(22)
        }
    }
    
    func configure(items: [ChartItem], selectedName: String?, isAssetVisible: Bool) {
        self.chartItems = items
        self.selectedName = selectedName
        self.isAssetVisible = isAssetVisible
        self.selectedValueText = items.first(where: { $0.name == selectedName })?.valueText ?? "RM 106,000.00"
        
        donutView.configure(
            segments: items.map {
                PortfolioDonutView.Segment(name: $0.name, share: $0.share, color: $0.color)
            },
            centerValue: isAssetVisible ? selectedValueText : "RM ••••••••",
            centerTitle: selectedName ?? "All",
            selectedName: selectedName,
            calloutText: selectedName == nil ? nil : "\(selectedName ?? "")\n28%"
        )
        
        rebuildChips()
    }
    
    private func rebuildChips() {
        [firstRow, secondRow].forEach { row in
            row.arrangedSubviews.forEach {
                row.removeArrangedSubview($0)
                $0.removeFromSuperview()
            }
        }
        
        let chipRows: [[(String?, UIColor?)]] = [
            [(nil, nil), ("KDI Invest", PortfolioColor.kdiInvest), ("KDI Save", PortfolioColor.kdiSave), ("KDX", PortfolioColor.kdx)],
            [("Rakuten Trade", PortfolioColor.rakuten), ("Kenanga Money", PortfolioColor.kenanga)]
        ]
        
        for (rowIndex, rowData) in chipRows.enumerated() {
            let row = rowIndex == 0 ? firstRow : secondRow
            rowData.forEach { row.addArrangedSubview(makeChip(title: $0.0 ?? "All", color: $0.1)) }
        }
    }
    
    private func makeChip(title: String, color: UIColor?) -> UIButton {
        let button = UIButton(type: .system)
        let isSelected = (title == "All" && selectedName == nil) || title == selectedName
        
        var configuration = UIButton.Configuration.plain()
        configuration.title = title
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 14, bottom: 8, trailing: 14)
        configuration.background.backgroundColor = isSelected ? PortfolioColor.chipSelected : .white
        configuration.background.cornerRadius = 18
        configuration.baseForegroundColor = isSelected ? .white : PortfolioColor.textPrimary
        
        if let color {
            configuration.image = UIImage.dot(color: color)
            configuration.imagePadding = 8
        }
        
        button.configuration = configuration
        button.titleLabel?.font = .dmSansFont(ofSize: 14, weight: .medium)
        button.addAction(UIAction(handler: { [weak self] _ in
            self?.onChipSelected?(title == "All" ? nil : title)
        }), for: .touchUpInside)
        return button
    }
}

private final class PortfolioModeSwitchView: UIView {
    
    private let container = UIView()
    private let gridButton = UIButton(type: .system)
    private let listButton = UIButton(type: .system)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        container.backgroundColor = PortfolioColor.blueSoft
        container.layer.cornerRadius = 8
        
        let stack = UIStackView(arrangedSubviews: [gridButton, listButton])
        stack.axis = .horizontal
        stack.spacing = 0
        stack.distribution = .fillEqually
        
        addSubview(container)
        container.addSubview(stack)
        
        container.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        stack.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(2)
        }
        
        style(button: gridButton, title: "Grid", icon: "square.grid.2x2", selected: false)
        style(button: listButton, title: "List", icon: "list.bullet", selected: true)
    }
    
    private func style(button: UIButton, title: String, icon: String, selected: Bool) {
        var configuration = UIButton.Configuration.plain()
        configuration.title = title
        configuration.image = UIImage(systemName: icon)
        configuration.imagePadding = 6
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 12, bottom: 10, trailing: 12)
        configuration.baseForegroundColor = selected ? PortfolioColor.blue : PortfolioColor.blueDark
        configuration.background.cornerRadius = 7
        configuration.background.backgroundColor = selected ? .white : .clear
        button.configuration = configuration
        button.layer.cornerRadius = 7
        button.layer.borderWidth = selected ? 1 : 0
        button.layer.borderColor = selected ? UIColor(hex: "#8AB2FF").cgColor : UIColor.clear.cgColor
        button.titleLabel?.font = .dmSansFont(ofSize: 14, weight: selected ? .bold : .regular)
    }
}

private final class PortfolioListRowView: UIView {
    
    private let logoView = RemoteImageView()
    private let dotView = UIView()
    private let nameLabel = UILabel()
    private let poweredByLabel = UILabel()
    private let partnerLabel = UILabel()
    private let valueLabel = UILabel()
    private let captionLabel = UILabel()
    private let divider = UIView()
    private var actualValueText = ""
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        let leftStack = UIStackView()
        leftStack.axis = .horizontal
        leftStack.alignment = .center
        leftStack.spacing = 14
        
        let textStack = UIStackView()
        textStack.axis = .vertical
        textStack.alignment = .leading
        textStack.spacing = 4
        
        let titleRow = UIStackView()
        titleRow.axis = .horizontal
        titleRow.alignment = .center
        titleRow.spacing = 8
        
        let partnerRow = UIStackView()
        partnerRow.axis = .horizontal
        partnerRow.alignment = .firstBaseline
        partnerRow.spacing = 5
        
        let valueStack = UIStackView()
        valueStack.axis = .vertical
        valueStack.alignment = .trailing
        valueStack.spacing = 3
        
        logoView.contentMode = .scaleAspectFit
        logoView.layer.cornerRadius = 13
        logoView.clipsToBounds = true
        
        dotView.layer.cornerRadius = 4
        
        nameLabel.textColor = PortfolioColor.textNavy
        nameLabel.font = .dmSansFont(ofSize: 18, weight: .bold)
        
        poweredByLabel.text = "Powered by"
        poweredByLabel.textColor = PortfolioColor.textMuted
        poweredByLabel.font = .dmSansFont(ofSize: 10.5, weight: .regular)
        
        partnerLabel.textColor = PortfolioColor.textPrimary
        partnerLabel.font = .dmSansFont(ofSize: 10.5, weight: .bold)
        
        valueLabel.textColor = PortfolioColor.blue
        valueLabel.font = .robotoFont(ofSize: 18, weight: .bold)
        
        captionLabel.text = "Total value"
        captionLabel.textColor = PortfolioColor.textMuted
        captionLabel.font = .dmSansFont(ofSize: 11.5, weight: .regular)
        
        divider.backgroundColor = PortfolioColor.divider
        
        addSubview(leftStack)
        addSubview(valueStack)
        addSubview(divider)
        
        leftStack.addArrangedSubview(logoView)
        leftStack.addArrangedSubview(textStack)
        textStack.addArrangedSubview(titleRow)
        textStack.addArrangedSubview(partnerRow)
        titleRow.addArrangedSubview(dotView)
        titleRow.addArrangedSubview(nameLabel)
        partnerRow.addArrangedSubview(poweredByLabel)
        partnerRow.addArrangedSubview(partnerLabel)
        
        valueStack.addArrangedSubview(valueLabel)
        valueStack.addArrangedSubview(captionLabel)
        
        leftStack.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(18)
            make.leading.equalToSuperview()
            make.bottom.equalToSuperview().offset(-18)
            make.trailing.lessThanOrEqualTo(valueStack.snp.leading).offset(-14)
        }
        
        valueStack.snp.makeConstraints { make in
            make.centerY.equalTo(leftStack)
            make.trailing.equalToSuperview()
        }
        
        logoView.snp.makeConstraints { make in
            make.size.equalTo(46)
        }
        
        dotView.snp.makeConstraints { make in
            make.size.equalTo(8)
        }
        
        divider.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(1)
        }
    }
    
    func configure(name: String, partner: String, valueText: String, logoURL: String, dotColor: UIColor, showsDivider: Bool) {
        nameLabel.text = name
        partnerLabel.text = partner
        actualValueText = valueText
        logoView.setImage(urlString: logoURL)
        dotView.backgroundColor = dotColor
        divider.isHidden = !showsDivider
        valueLabel.text = valueText
    }
    
    func setValueVisible(_ visible: Bool) {
        valueLabel.text = visible ? actualValueText : "RM ••••••••"
    }
}

private final class PortfolioDonutView: UIView {
    
    struct Segment {
        let name: String
        let share: CGFloat
        let color: UIColor
    }
    
    private var segments: [Segment] = []
    private var selectedName: String?
    private let centerValueLabel = UILabel()
    private let centerTitleLabel = UILabel()
    private let calloutView = UIView()
    private let calloutLabel = UILabel()
    private let centerMaskView = UIView()
    private var segmentLayers: [CAShapeLayer] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .clear
        
        centerMaskView.backgroundColor = PortfolioColor.blueSoft
        centerMaskView.layer.cornerRadius = 82
        centerMaskView.isHidden = true
        
        centerValueLabel.textColor = PortfolioColor.textPrimary
        centerValueLabel.font = .robotoFont(ofSize: 20, weight: .bold)
        centerValueLabel.textAlignment = .center
        
        centerTitleLabel.textColor = PortfolioColor.textNavy
        centerTitleLabel.font = .dmSansFont(ofSize: 13, weight: .regular)
        centerTitleLabel.textAlignment = .center
        
        calloutView.backgroundColor = PortfolioColor.callout
        calloutView.layer.cornerRadius = 4
        calloutView.layer.shadowColor = UIColor.black.cgColor
        calloutView.layer.shadowOpacity = 0.14
        calloutView.layer.shadowOffset = CGSize(width: 0, height: 6)
        calloutView.layer.shadowRadius = 10
        
        calloutLabel.textColor = UIColor(hex: "#F2F2F5")
        calloutLabel.font = .dmSansFont(ofSize: 12, weight: .bold)
        calloutLabel.numberOfLines = 2
        
        addSubview(centerMaskView)
        addSubview(centerValueLabel)
        addSubview(centerTitleLabel)
        addSubview(calloutView)
        calloutView.addSubview(calloutLabel)
        
        centerMaskView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(164)
        }
        
        centerValueLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-6)
        }
        
        centerTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(centerValueLabel.snp.bottom).offset(3)
            make.centerX.equalToSuperview()
        }
        
        calloutLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8))
        }
    }
    
    func configure(segments: [Segment], centerValue: String, centerTitle: String, selectedName: String?, calloutText: String?) {
        self.segments = segments
        self.selectedName = selectedName
        centerValueLabel.text = centerValue
        centerTitleLabel.text = centerTitle
        calloutLabel.text = calloutText
        calloutView.isHidden = calloutText == nil
        setNeedsLayout()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        drawSegments()
    }
    
    private func drawSegments() {
        segmentLayers.forEach { $0.removeFromSuperlayer() }
        segmentLayers.removeAll()
        
        guard !segments.isEmpty else { return }
        
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let outerRadius: CGFloat = 130
        let innerRadius: CGFloat = 74
        let selectedOuterRadius: CGFloat = 135
        let selectedInnerRadius: CGFloat = 69
        var startAngle = -CGFloat.pi / 2
        var calloutPoint: CGPoint?
        
        for segment in segments {
            let endAngle = startAngle + (segment.share * 2 * .pi)
            let midAngle = (startAngle + endAngle) / 2
            let isSelected = segment.name == selectedName
            let segmentOuterRadius = isSelected ? selectedOuterRadius : outerRadius
            let segmentInnerRadius = isSelected ? selectedInnerRadius : innerRadius
            
            let path = UIBezierPath()
            path.addArc(
                withCenter: center,
                radius: segmentOuterRadius,
                startAngle: startAngle,
                endAngle: endAngle,
                clockwise: true
            )
            path.addArc(
                withCenter: center,
                radius: segmentInnerRadius,
                startAngle: endAngle,
                endAngle: startAngle,
                clockwise: false
            )
            path.close()
            
            let layer = CAShapeLayer()
            layer.path = path.cgPath
            layer.fillColor = segment.color.cgColor
            layer.strokeColor = segment.color.cgColor
            layer.lineWidth = 0
            
            if isSelected {
                layer.shadowColor = UIColor.black.cgColor
                layer.shadowOpacity = 0.16
                layer.shadowOffset = CGSize(width: 0, height: 8)
                layer.shadowRadius = 12
                calloutPoint = CGPoint(
                    x: center.x + cos(midAngle) * 126,
                    y: center.y + sin(midAngle) * 126
                )
            }
            
            self.layer.insertSublayer(layer, below: centerValueLabel.layer)
            segmentLayers.append(layer)
            startAngle += segment.share * 2 * .pi
        }
        
        if let calloutPoint, !calloutView.isHidden {
            calloutView.snp.remakeConstraints { make in
                make.centerX.equalToSuperview().offset(calloutPoint.x - bounds.midX + 18)
                make.centerY.equalToSuperview().offset(calloutPoint.y - bounds.midY + 10)
            }
        }
    }
}

private extension UIImage {
    static func dot(color: UIColor) -> UIImage? {
        let size = CGSize(width: 8, height: 8)
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            color.setFill()
            context.cgContext.fillEllipse(in: CGRect(origin: .zero, size: size))
        }
    }
}
