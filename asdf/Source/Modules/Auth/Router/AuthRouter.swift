import UIKit

enum AuthRoute {
    case login
    case register
}

class AuthRouter {
    
    static func createModule() -> UIViewController {
        let loginVC = LoginViewController()
        let nav = BaseNavigationController(rootViewController: loginVC)
        return nav
    }
    
    static func navigate(to route: AuthRoute, from context: UIViewController?) {
        guard let source = context else { return }
        
        switch route {
        case .login:
            source.navigationController?.popToRootViewController(animated: true)
            
        case .register:
            let registerVC = RegisterViewController()
            source.navigationController?.pushViewController(registerVC, animated: true)
        }
    }
}
