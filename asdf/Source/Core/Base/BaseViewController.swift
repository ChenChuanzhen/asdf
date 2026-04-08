import UIKit
import SnapKit

class BaseViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
        setupBindings()
        setupData()
    }
    
    /// Override this method to configure the UI hierarchy and constraints
    func setupUI() {
        // Subclasses to implement
    }
    
    /// Override this method to setup ViewModel bindings
    func setupBindings() {
        // Subclasses to implement
    }
    
    /// Override this method to initialize data
    func setupData() {
        // Subclasses to implement
    }
    
    deinit {
        print("\(String(describing: self)) deinit")
    }
}
