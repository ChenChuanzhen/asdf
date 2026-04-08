import UIKit

protocol RouterProtocol {
    func setRoot(window: UIWindow?)
    func navigateToLogin()
    func navigateToHome()
}

final class AppRouter: RouterProtocol {
    
    static let shared = AppRouter()
    
    private var window: UIWindow?
    
    private init() {}
    
    // MARK: - Navigation
    
    // Top-level App Route
    enum AppRoute {
        case auth(action: AuthRoute)
        case home(action: HomeRoute)
        case portfolio(action: PortfolioRoute)
        case go(action: GoRoute)
        case discover(action: DiscoverRoute)
        case account(action: AccountRoute)
    }
    
    func navigate(to route: AppRoute, from source: UIViewController? = nil) {
        let fromVC = source ?? getTopViewController()
        
        switch route {
        case .auth(let action):
            AuthRouter.navigate(to: action, from: fromVC)
            
        case .home(let action):
            HomeRouter.navigate(to: action, from: fromVC)
            
        case .portfolio(let action):
            PortfolioRouter.navigate(to: action, from: fromVC)
            
        case .go(let action):
            GoRouter.navigate(to: action, from: fromVC)
            
        case .discover(let action):
            DiscoverRouter.navigate(to: action, from: fromVC)
            
        case .account(let action):
            AccountRouter.navigate(to: action, from: fromVC)
        }
    }
    
    func setRoot(window: UIWindow?) {
        self.window = window
        navigateToLogin()
        window?.makeKeyAndVisible()
    }
    
    func navigateToLogin() {
        let startModule = AuthRouter.createModule()
        changeRootViewController(startModule)
    }
    
    func navigateToHome() {
        let mainTabBar = MainTabBarController()
        changeRootViewController(mainTabBar)
    }
    
    private func getTopViewController(base: UIViewController? = nil) -> UIViewController? {
        let root = base ?? window?.rootViewController
        
        if let nav = root as? UINavigationController {
            return getTopViewController(base: nav.visibleViewController)
        }
        if let tab = root as? UITabBarController, let selected = tab.selectedViewController {
            return getTopViewController(base: selected)
        }
        if let presented = root?.presentedViewController {
            return getTopViewController(base: presented)
        }
        return root
    }

    private func changeRootViewController(_ vc: UIViewController) {
        window?.switchRootViewController(to: vc)
    }
}
