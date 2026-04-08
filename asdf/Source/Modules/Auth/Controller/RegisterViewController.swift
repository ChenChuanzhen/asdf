import UIKit
import SnapKit

final class RegisterViewController: BaseViewController {
    
    private lazy var submitButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Create Account", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = .systemGreen
        btn.layer.cornerRadius = 8
        btn.addTarget(self, action: #selector(handleSubmit), for: .touchUpInside)
        return btn
    }()
    
    override func setupUI() {
        title = "Register"
        
        view.addSubview(submitButton)
        
        submitButton.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(200)
            make.height.equalTo(44)
        }
    }
    
    @objc private func handleSubmit() {
        // Mock registration
        navigationController?.popViewController(animated: true)
    }
}
