import UIKit

enum GoRoute {
    case main
}

class GoRouter {
    static func createModule() -> UIViewController {
        let vc = GoViewController()
        let nav = BaseNavigationController(rootViewController: vc)
        nav.tabBarItem = UITabBarItem(title: nil, image: UIImage(systemName: "circle.circle.fill"), selectedImage: nil)
        nav.tabBarItem.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
        return nav
    }
    
    static func navigate(to route: GoRoute, from context: UIViewController?) {
         // Handle nav
    }
}
