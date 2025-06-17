import FirebaseMessaging
import LikeMindsFeedUI
import LikeMindsFeedCore
import UIKit
extension UIViewController {
    var window: UIWindow? {
        if #available(iOS 13, *) {
            guard
                let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                let delegate = windowScene.delegate as? SceneDelegate,
                let window = delegate.window
            else { return nil }
            return window
        }
        return nil
    }
}
class ViewController: LMFeedViewController{
    // MARK: - UI Components
    private let apiKeyField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "API Key"
        textField.borderStyle = .roundedRect
        textField.returnKeyType = .next
        return textField
    }()
    private let userIdField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "User ID"
        textField.borderStyle = .roundedRect
        textField.returnKeyType = .next
        return textField
    }()
    private let userNameField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Username"
        textField.borderStyle = .roundedRect
        textField.returnKeyType = .next
        return textField
    }()
    private let postIdField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Post Ids to start feed with separated by comma"
        textField.borderStyle = .roundedRect
        textField.returnKeyType = .done
        return textField
    }()
    private let loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Submit", for: .normal)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.heightAnchor.constraint(equalToConstant: 44).isActive = true
        return button
    }()
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupKeyboardDismissal()
        isSavedData()
    }
    // MARK: - Setup UI
    private func setupUI() {
        view.backgroundColor = .white
        title = "Login"
        let stackView = UIStackView(arrangedSubviews: [apiKeyField, userIdField, userNameField, postIdField, loginButton])
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.alignment = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        loginButton.addTarget(self, action: #selector(loginButtonClicked(_:)), for: .touchUpInside)
    }
    private func setupKeyboardDismissal() {
        // Add tap gesture to dismiss keyboard
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
        
        // Set text field delegates
        apiKeyField.delegate = self
        userIdField.delegate = self
        userNameField.delegate = self
        postIdField.delegate = self
    }
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    // MARK: - Actions
    @objc func loginButtonClicked(_ sender: UIButton) {
        guard
            let apiKey = apiKeyField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !apiKey.isEmpty,
            let userId = userIdField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !userId.isEmpty,
            let username = userNameField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !username.isEmpty
        else {
            showAlert(message: "All fields are mandatory!")
            return
        }
        
        let postIds = postIdField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
            .components(separatedBy: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty } ?? []
        let userDefaults = UserDefaults.standard
        userDefaults.setValue(apiKey, forKey: "apiKey")
        userDefaults.setValue(userId, forKey: "userId")
        userDefaults.setValue(username, forKey: "username")
        userDefaults.synchronize()
        callInitiateApi(userId: userId, username: username, apiKey: apiKey, postIds: postIds)
    }
    // MARK: - Utilities
    @discardableResult
    func isSavedData() -> Bool {
        let userDefaults = UserDefaults.standard
        guard
            let apiKey = userDefaults.value(forKey: "apiKey") as? String,
            let userId = userDefaults.value(forKey: "userId") as? String,
            let username = userDefaults.value(forKey: "username") as? String
        else {
            return false
        }
        callInitiateApi(userId: userId, username: username, apiKey: apiKey, postIds: [])
        return true
    }
    func callInitiateApi(userId: String, username: String, apiKey: String, postIds: [String]) {
        self.showHideLoaderView(isShow: true, backgroundColor: .clear)
        LMFeedCore.shared.showFeed(apiKey: apiKey, username: username, uuid: userId) { [weak self] result in
            switch result {
            case .success:
                self?.showHideLoaderView(isShow: false, backgroundColor: .clear)
                let homeVC = try! LMFeedVideoFeedViewModel.createModule(postIds: postIds)
                let navigation = UINavigationController(rootViewController: homeVC)
                navigation.modalPresentationStyle = .overFullScreen
                self?.window?.rootViewController = navigation
            case .failure(let error):
                self?.showHideLoaderView(isShow: false, backgroundColor: .clear)
                self?.showAlert(message: error.localizedDescription)
            }
        }
    }
    func showAlert(message: String) {
        let alert = UIAlertController(
            title: nil,
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Ok", style: .cancel))
        present(alert, animated: true)
    }
}

// MARK: - UITextFieldDelegate
extension ViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case apiKeyField:
            userIdField.becomeFirstResponder()
        case userIdField:
            userNameField.becomeFirstResponder()
        case userNameField:
            postIdField.becomeFirstResponder()
        case postIdField:
            textField.resignFirstResponder()
        default:
            textField.resignFirstResponder()
        }
        return true
    }
}
