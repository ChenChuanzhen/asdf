import UIKit

enum AccountRoute {
    case main
    case settings
}

class AccountRouter {
    static func createModule() -> UIViewController {
        let vc = AccountViewController()
        let nav = BaseNavigationController(rootViewController: vc)
        nav.tabBarItem = UITabBarItem(title: "Account", image: UIImage(systemName: "person"), selectedImage: UIImage(systemName: "person.fill"))
        return nav
    }
    
    static func navigate(to route: AccountRoute, from context: UIViewController?) {
         // Handle nav
    }
}
