import UIKit
import SnapKit

class BaseNavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
        setupData()
    }
    
    /// Override this method to configure the UI hierarchy and constraints
    func setupUI() {
        // Subclasses to implement
        // Default appearance configuration can go here
        view.backgroundColor = .white
    }
    
    /// Override this method to setup ViewModel bindings
    func setupBindings() {
        // Subclasses to implement
    }
    
    /// Override this method to initialize data
    func setupData() {
        // Subclasses to implement
    }
    
    // MARK: - Status Bar
    override var childForStatusBarStyle: UIViewController? {
        return topViewController
    }
    
    override var childForStatusBarHidden: UIViewController? {
        return topViewController
    }
    
    deinit {
        print("\(String(describing: self)) deinit")
    }
}
