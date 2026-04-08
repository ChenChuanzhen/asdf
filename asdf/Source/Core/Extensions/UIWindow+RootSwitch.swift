import UIKit

extension UIWindow {
    
    /// Swaps the root view controller with an animation
    /// - Parameters:
    ///   - viewController: The new root view controller
    ///   - animated: Whether to animate the transition
    ///   - duration: Animation duration (default is 0.3)
    ///   - options: Animation options (default is .transitionCrossDissolve)
    ///   - completion: Completion handler
    func switchRootViewController(to viewController: UIViewController,
                                  animated: Bool = true,
                                  duration: TimeInterval = 0.3,
                                  options: UIView.AnimationOptions = .transitionCrossDissolve,
                                  completion: (() -> Void)? = nil) {
        
        guard animated else {
            rootViewController = viewController
            completion?()
            return
        }
        
        UIView.transition(with: self,
                          duration: duration,
                          options: options,
                          animations: {
            let oldState = UIView.areAnimationsEnabled
            UIView.setAnimationsEnabled(false)
            self.rootViewController = viewController
            UIView.setAnimationsEnabled(oldState)
        }, completion: { _ in
            completion?()
        })
    }
}
