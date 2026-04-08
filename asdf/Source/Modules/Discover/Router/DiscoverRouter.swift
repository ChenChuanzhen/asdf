import UIKit

enum DiscoverRoute {
    case main
    case article(id: String)
}

class DiscoverRouter {
    static func createModule() -> UIViewController {
        let vc = DiscoverViewController()
        let nav = BaseNavigationController(rootViewController: vc)
        nav.tabBarItem = UITabBarItem(title: "Discover", image: UIImage(systemName: "lightbulb"), selectedImage: UIImage(systemName: "lightbulb.fill"))
        return nav
    }
    
    static func navigate(to route: DiscoverRoute, from context: UIViewController?) {
         // Handle nav
    }
}
