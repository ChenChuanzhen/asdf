import UIKit
import SVProgressHUD
import SnapKit

final class LoginViewController: BaseViewController {
    
    // MARK: - Properties
    
    private lazy var viewModel = AuthViewModel()
    
    // MARK: - UI Components
    
    private lazy var topHalfView: UIView = {
        let view = UIView()
        view.backgroundColor = AppTheme.Color.primaryBlue
        view.clipsToBounds = true
        return view
    }()
    
    private lazy var circleDecoView: UIView = {
        let view = UIView()
        view.backgroundColor = AppTheme.Color.primaryDarkBlue
        return view
    }()
    
    private lazy var faqButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("FAQ?", for: .normal)
        btn.setTitleColor(AppTheme.Color.whiteAlpha60, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        btn.addTarget(self, action: #selector(handleFAQ), for: .touchUpInside)
        return btn
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Log in to\nyour account"
        label.textColor = .white
        label.font = .systemFont(ofSize: 32, weight: .bold)
        label.numberOfLines = 2
        return label
    }()
    
    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Welcome back!"
        label.textColor = .white
        label.font = .systemFont(ofSize: 16, weight: .regular)
        return label
    }()
    
    private lazy var emailTextField: FloatingTitleTextField = {
        let tf = FloatingTitleTextField()
        tf.placeholder = "Email address"
        tf.inputType = .email
        return tf
    }()
    
    private lazy var passwordTextField: FloatingTitleTextField = {
        let tf = FloatingTitleTextField()
        tf.placeholder = "Password"
        tf.inputType = .password
        tf.isSecureToggleEnabled = true
        return tf
    }()
    
    private lazy var troubleButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Having trouble logging in?", for: .normal)
        btn.setTitleColor(AppTheme.Color.primaryBlue, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 14, weight: .bold)
        btn.addTarget(self, action: #selector(handleTroubleLogin), for: .touchUpInside)
        return btn
    }()
    
    private lazy var loginButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Log in", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = AppTheme.Color.primaryLightBlue
        btn.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
        btn.layer.cornerRadius = 8
        btn.addTarget(self, action: #selector(handleLogin), for: .touchUpInside)
        return btn
    }()
    
    private lazy var registerContainerView: UIView = {
        let view = UIView()
        return view
    }()
    
    private lazy var noAccountLabel: UILabel = {
        let label = UILabel()
        label.text = "Don't have account yet? "
        label.textColor = .darkGray
        label.font = .systemFont(ofSize: 14)
        return label
    }()
    
    private lazy var registerButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Register now", for: .normal)
        btn.setTitleColor(AppTheme.Color.primaryBlue, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 14, weight: .bold)
        btn.addTarget(self, action: #selector(handleRegister), for: .touchUpInside)
        return btn
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        circleDecoView.layer.cornerRadius = circleDecoView.bounds.width / 2
    }
    
    // MARK: - Setup
    
    override func setupUI() {
        view.backgroundColor = .white
        
        // 1. Top half view
        view.addSubview(topHalfView)
        topHalfView.addSubview(circleDecoView)
        topHalfView.addSubview(faqButton)
        topHalfView.addSubview(titleLabel)
        topHalfView.addSubview(subtitleLabel)
        
        // 2. Input Fields
        view.addSubview(emailTextField)
        view.addSubview(passwordTextField)
        
        // 3. Buttons
        view.addSubview(troubleButton)
        view.addSubview(loginButton)
        
        // 4. Register Area
        view.addSubview(registerContainerView)
        registerContainerView.addSubview(noAccountLabel)
        registerContainerView.addSubview(registerButton)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        topHalfView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            // ~1/3 of the screen for the blue portion
            make.height.equalTo(view.snp.height).multipliedBy(0.32)
        }
        
        circleDecoView.snp.makeConstraints { make in
            // Right and slightly down from the center
            make.centerY.equalTo(topHalfView.snp.bottom).offset(-50).priority(.high)
            make.trailing.equalToSuperview().offset(50)
            make.width.height.equalTo(240)
        }
        
        faqButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(10)
            make.trailing.equalToSuperview().offset(-20)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(30)
            make.bottom.equalTo(subtitleLabel.snp.top).offset(-8)
        }
        
        subtitleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(30)
            make.bottom.equalToSuperview().offset(-40)
        }
        
        emailTextField.snp.makeConstraints { make in
            make.top.equalTo(topHalfView.snp.bottom).offset(40)
            make.leading.equalToSuperview().offset(24)
            make.trailing.equalToSuperview().offset(-24)
            make.height.equalTo(56)
        }
        
        passwordTextField.snp.makeConstraints { make in
            make.top.equalTo(emailTextField.snp.bottom).offset(20)
            make.leading.trailing.height.equalTo(emailTextField)
        }
        
        troubleButton.snp.makeConstraints { make in
            make.top.equalTo(passwordTextField.snp.bottom).offset(24)
            make.centerX.equalToSuperview()
        }
        
        loginButton.snp.makeConstraints { make in
            make.bottom.equalTo(registerContainerView.snp.top).offset(-40)
            make.leading.trailing.equalTo(emailTextField)
            make.height.equalTo(56)
        }
        
        registerContainerView.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-20)
            make.centerX.equalToSuperview()
            make.height.equalTo(30)
        }
        
        noAccountLabel.snp.makeConstraints { make in
            make.leading.centerY.equalToSuperview()
        }
        
        registerButton.snp.makeConstraints { make in
            make.leading.equalTo(noAccountLabel.snp.trailing)
            make.trailing.centerY.equalToSuperview()
        }
    }
    
    // MARK: - Bindings
    
    private func bindViewModel() {
        viewModel.onLoginSuccess = {
            AppRouter.shared.navigateToHome()
        }
        
        viewModel.onLoginFailure = { error in
            SVProgressHUD.showError(withStatus: error)
        }
    }
    
    // MARK: - Actions
    
    @objc private func handleLogin() {
        
        Task { [weak self] in
            guard let self = self else { return }
            await self.viewModel.login()
        }
    }
    
    @objc private func handleRegister() {
        AppRouter.shared.navigate(to: .auth(action: .register))
    }
    

    
    @objc private func handleFAQ() {
        print("FAQ button tapped")
    }
    
    @objc private func handleTroubleLogin() {
        print("Having trouble logging in? tapped")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        view.endEditing(true)
    }
}
