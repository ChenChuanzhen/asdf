import UIKit

enum HomeRoute {
    case main
    case detail // Example
}

class HomeRouter {
    
    static func createModule() -> UIViewController {
        let homeVC = HomeViewController()
        let nav = BaseNavigationController(rootViewController: homeVC)
        nav.tabBarItem = UITabBarItem(title: "Home", image: UIImage(systemName: "house"), selectedImage: UIImage(systemName: "house.fill"))
        return nav
    }
    
    static func navigate(to route: HomeRoute, from context: UIViewController?) {
        guard let source = context else { return }
        switch route {
        case .main:
            // Already there
            break
        case .detail:
            print("Navigate to Home Detail")
        }
    }
}
