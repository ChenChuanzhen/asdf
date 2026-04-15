import UIKit
import SnapKit

final class MainTabBarController: UITabBarController {
    
    // MARK: - Properties
    private lazy var customTabBar: CustomTabBarView = {
        let view = CustomTabBarView()
        view.delegate = self
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabs()
//        setupCustomTabBar()
    }
    
    private func setupTabs() {
        let homeNav = HomeRouter.createModule()
        let portfolioNav = PortfolioRouter.createModule()
        let discoverNav = DiscoverRouter.createModule()
        let accountNav = AccountRouter.createModule()
        viewControllers = [homeNav, portfolioNav, discoverNav, accountNav]
    }
    
    private func setupCustomTabBar() {
        // 隐藏系统的 TabBar
        tabBar.isHidden = true
        
        // 将自定义 TabBar 添加到 view 上
        view.addSubview(customTabBar)
        
        customTabBar.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(0)
            make.right.equalToSuperview().offset(0)
            make.bottom.equalTo(view.snp.bottom).offset(0)
            make.height.equalTo(92)
        }
    }
}

// MARK: - CustomTabBarViewDelegate
extension MainTabBarController: CustomTabBarViewDelegate {
    func customTabBar(_ tabBar: CustomTabBarView, didSelectIndex index: Int) {
        // 切换 ViewControllers
        selectedIndex = index
    }
    
    func customTabBarDidSelectCenterButton(_ tabBar: CustomTabBarView) {
        
    }
}
