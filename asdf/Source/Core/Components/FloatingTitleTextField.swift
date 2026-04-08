import UIKit
import SnapKit

enum FloatingTextFieldInputType {
    case text
    case email
    case amount
    case password
}

final class FloatingTitleTextField: UIView {
    
    // MARK: - API Properties
    
    var placeholder: String = "" {
        didSet {
            titleLabel.text = placeholder
        }
    }
    
    var text: String {
        get { return unformattedText(from: textField.text ?? "") }
        set { 
            textField.text = newValue
            if inputType == .amount {
                textField.text = formattedAmount(from: newValue)
            }
            updateFloatingState(animated: false)
        }
    }
    
    var maxLength: Int = .max
    
    var inputType: FloatingTextFieldInputType = .text {
        didSet {
            configureForInputType()
        }
    }
    
    var isSecureToggleEnabled: Bool = false {
        didSet {
            rightButton.isHidden = !isSecureToggleEnabled
            updateTextFieldTrailingConstraint()
        }
    }
    
    var onTextChanged: ((String) -> Void)?
    
    // MARK: - Private State
    
    private var isFloating: Bool = false
    
    // MARK: - UI Components
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear // Transparent to let the component background show through if needed
        view.layer.cornerRadius = 8
        view.layer.borderWidth = 1
        view.layer.borderColor = AppTheme.Color.borderDefault.cgColor
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .systemGray
        label.font = .systemFont(ofSize: 16)
        label.isUserInteractionEnabled = false
        label.backgroundColor = .white // Covers the border when floating
        return label
    }()
    
    // We expose a read-only text field if the caller needs to become responder etc.
    lazy var textField: UITextField = {
        let tf = UITextField()
        tf.textColor = .black
        tf.font = .systemFont(ofSize: 16)
        tf.autocapitalizationType = .none
        tf.delegate = self
        tf.addTarget(self, action: #selector(textFieldEditingChanged), for: .editingChanged)
        tf.addTarget(self, action: #selector(textFieldDidBeginEditing), for: .editingDidBegin)
        tf.addTarget(self, action: #selector(textFieldDidEndEditing), for: .editingDidEnd)
        return tf
    }()
    
    private lazy var rightButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setImage(UIImage(systemName: "eye.slash"), for: .normal)
        btn.setImage(UIImage(systemName: "eye"), for: .selected)
        btn.tintColor = .systemGray3
        btn.isHidden = true
        btn.addTarget(self, action: #selector(handleRightButtonTapped), for: .touchUpInside)
        return btn
    }()
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        backgroundColor = .clear
        
        addSubview(containerView)
        addSubview(titleLabel)
        
        containerView.addSubview(textField)
        containerView.addSubview(rightButton)
        
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        rightButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-12)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(24)
        }
        
        // Initial setup for non-floating state
        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(containerView).offset(16)
            make.centerY.equalTo(containerView)
        }
        
        updateTextFieldTrailingConstraint()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleContainerTap))
        containerView.addGestureRecognizer(tap)
    }
    
    private func updateTextFieldTrailingConstraint() {
        textField.snp.remakeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.top.bottom.equalToSuperview()
            if rightButton.isHidden {
                make.trailing.equalToSuperview().offset(-16)
            } else {
                make.trailing.equalTo(rightButton.snp.leading).offset(-8)
            }
        }
    }
    
    private func configureForInputType() {
        switch inputType {
        case .text:
            textField.keyboardType = .default
            textField.isSecureTextEntry = false
            isSecureToggleEnabled = false
        case .email:
            textField.keyboardType = .emailAddress
            textField.isSecureTextEntry = false
            isSecureToggleEnabled = false
        case .amount:
            textField.keyboardType = .decimalPad
            textField.isSecureTextEntry = false
            isSecureToggleEnabled = false
        case .password:
            textField.keyboardType = .default
            textField.isSecureTextEntry = true
            isSecureToggleEnabled = true // Auto-enable eye button for password by default
        }
    }
    
    // MARK: - Actions
    
    @objc private func handleContainerTap() {
        textField.becomeFirstResponder()
    }
    
    @objc private func handleRightButtonTapped() {
        rightButton.isSelected.toggle()
        textField.isSecureTextEntry = !rightButton.isSelected
    }
    
    @objc private func textFieldEditingChanged() {
        if inputType == .amount, let rawText = textField.text {
            // Keep track of cursor if needed, but for native editingChanged,
            // standard substitution works ok if fully replaced.
            // Using shouldChangeCharactersIn handles cursor better.
        }
        updateFloatingState(animated: true)
        onTextChanged?(text)
    }
    
    @objc private func textFieldDidBeginEditing() {
        containerView.layer.borderColor = AppTheme.Color.activeState.cgColor
        titleLabel.textColor = .systemBlue
        updateFloatingState(animated: true)
    }
    
    @objc private func textFieldDidEndEditing() {
        containerView.layer.borderColor = AppTheme.Color.borderDefault.cgColor
        titleLabel.textColor = .systemGray
        updateFloatingState(animated: true)
    }
    
    // MARK: - Animation
    
    private func updateFloatingState(animated: Bool) {
        let hasText = !(textField.text?.isEmpty ?? true)
        let isFocused = textField.isFirstResponder
        let shouldFloat = hasText || isFocused
        
        if isFloating == shouldFloat { return }
        isFloating = shouldFloat
        
        let animationDuration = animated ? 0.25 : 0.0
        
        let yOffset = -(containerView.bounds.height / 2)
        let scale: CGFloat = 0.8
        
        UIView.animate(withDuration: animationDuration, delay: 0, options: [.curveEaseOut, .beginFromCurrentState]) {
            if shouldFloat {
                // Determine translation needed to keep the left edge aligned
                let translateX = -(self.titleLabel.bounds.width * (1 - scale) / 2)
                
                let transform = CGAffineTransform(translationX: translateX, y: yOffset).scaledBy(x: scale, y: scale)
                self.titleLabel.transform = transform
            } else {
                self.titleLabel.transform = .identity
            }
        }
    }
}

// MARK: - UITextFieldDelegate

extension FloatingTitleTextField: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        
        // 1. Check Max Length (ignoring thousand separators for amount)
        let rawUpdatedText = unformattedText(from: updatedText)
        if rawUpdatedText.count > maxLength {
            return false
        }
        
        // 2. Handle Amount Formatting
        if inputType == .amount {
            // Check if valid amount string
            // Allow only digits and one dot
            let regex = try! NSRegularExpression(pattern: "^[0-9]*\\.?[0-9]*$")
            if regex.firstMatch(in: unformattedText(from: updatedText), options: [], range: NSRange(location: 0, length: rawUpdatedText.utf16.count)) == nil {
                return false
            }
            
            formatAmountAndPreserveCursor(in: textField, currentText: currentText, range: range, replacementString: string)
            
            // Manually trigger editing changed actions since we returned false
            self.textFieldEditingChanged()
            return false // We updated it manually
        }
        
        // For other types, we might just let it proceed naturally, 
        // but to ensure onTextChanged gets the right raw length checking, we return true.
        return true
    }
    
    // MARK: - Amount Formatting Helpers
    
    private func formatAmountAndPreserveCursor(in textField: UITextField, currentText: String, range: NSRange, replacementString string: String) {
        
        // Get number of digits and dots before the cursor before editing
        let textBeforeEdit = (currentText as NSString).substring(to: range.location)
        let relevantCharsBeforeEdit = textBeforeEdit.filter { $0.isNumber || $0 == "." }.count
        
        // Apply edit
        let unformattedEdited = unformattedText(from: (currentText as NSString).replacingCharacters(in: range, with: string))
        
        // Format the new text
        let newlyFormatted = formattedAmount(from: unformattedEdited)
        textField.text = newlyFormatted
        
        // Track the relevant characters added
        let relevantCharsAdded = string.filter { $0.isNumber || $0 == "." }.count
        let targetRelevantCharsBeforeCursor = relevantCharsBeforeEdit + relevantCharsAdded
        
        // Find new cursor position
        var newCursorLocation = 0
        var foundRelevantChars = 0
        
        for (index, char) in newlyFormatted.enumerated() {
            if foundRelevantChars == targetRelevantCharsBeforeCursor {
                newCursorLocation = index
                break
            }
            if char.isNumber || char == "." {
                foundRelevantChars += 1
            }
            // If we've reached the end
            if index == newlyFormatted.count - 1 && foundRelevantChars <= targetRelevantCharsBeforeCursor {
                newCursorLocation = newlyFormatted.count
            }
        }
        // Fallback for empty
        if newlyFormatted.isEmpty {
            newCursorLocation = 0
        }
        
        // Set cursor position
        if let newPosition = textField.position(from: textField.beginningOfDocument, offset: newCursorLocation) {
            textField.selectedTextRange = textField.textRange(from: newPosition, to: newPosition)
        }
    }
    
    private func unformattedText(from text: String) -> String {
        return text.replacingOccurrences(of: ",", with: "")
    }
    
    private func formattedAmount(from text: String) -> String {
        let unformatted = unformattedText(from: text)
        guard !unformatted.isEmpty else { return "" }
        
        let components = unformatted.components(separatedBy: ".")
        var integerPart = components.first ?? ""
        let decimalPart = components.count > 1 ? "." + components[1] : (unformatted.hasSuffix(".") ? "." : "")
        
        // Format integer part
        if let intValue = Int64(integerPart) {
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            formatter.groupingSeparator = ","
            integerPart = formatter.string(from: NSNumber(value: intValue)) ?? integerPart
        } else if integerPart.isEmpty && decimalPart.starts(with: ".") {
            integerPart = "0"
        }
        
        return integerPart + decimalPart
    }
}
