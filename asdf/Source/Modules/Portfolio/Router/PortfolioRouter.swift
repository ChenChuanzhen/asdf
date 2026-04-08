import UIKit

enum PortfolioRoute {
    case main
    case detail(id: String)
}

class PortfolioRouter {
    static func createModule() -> UIViewController {
        let vc = PortfolioViewController()
        let nav = BaseNavigationController(rootViewController: vc)
        nav.tabBarItem = UITabBarItem(title: "Portfolio", image: UIImage(systemName: "chart.pie"), selectedImage: UIImage(systemName: "chart.pie.fill"))
        return nav
    }
    
    static func navigate(to route: PortfolioRoute, from context: UIViewController?) {
        guard let source = context else { return }
        switch route {
        case .main: break
        case .detail(let id):
            print("Portfolio Detail \(id)")
        }
    }
}
