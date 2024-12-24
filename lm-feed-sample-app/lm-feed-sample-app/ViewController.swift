//
//  ViewController.swift
//  likeminds-feed-iOS
//
//  Created by Devansh Mohata on 12/19/2023.
//  Copyright (c) 2023 Devansh Mohata. All rights reserved.
//

import FirebaseMessaging
import LikeMindsFeedCore
import LikeMindsFeedUI
import UIKit

class ViewController: UIViewController {

    @IBOutlet private weak var apiKeyTextField: UITextField!
    @IBOutlet private weak var usernameTextField: UITextField!
    @IBOutlet private weak var userIdTextField: UITextField!
    @IBOutlet private weak var submitBtn: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        submitBtn.layer.cornerRadius = 8
        view.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(endEditing)))
        isSavedData()
    }

    @discardableResult
    func isSavedData() -> Bool {
        let userDefalut = UserDefaults.standard
        guard let apiKey = userDefalut.value(forKey: "apiKey") as? String,
            let userId = userDefalut.value(forKey: "userId") as? String,
            let username = userDefalut.value(forKey: "username") as? String
        else {
            return false
        }
        initateAPI(apiKey: apiKey, username: username, userId: userId)
        return true
    }

    @IBAction private func submitBtnClicked(_ sender: UIButton) {
        guard
            let apiKey = apiKeyTextField?.text?.trimmingCharacters(
                in: .whitespacesAndNewlines), !apiKey.isEmpty,
            let userId = userIdTextField?.text?.trimmingCharacters(
                in: .whitespacesAndNewlines), !userId.isEmpty,
            let username = usernameTextField?.text?.trimmingCharacters(
                in: .whitespacesAndNewlines), !username.isEmpty
        else {
            showAlert(message: "All fields are mandatory!")
            return
        }

        let userDefalut = UserDefaults.standard
        userDefalut.setValue(apiKey, forKey: "apiKey")
        userDefalut.setValue(userId, forKey: "userId")
        userDefalut.setValue(username, forKey: "username")
        userDefalut.synchronize()

        initateAPI(apiKey: apiKey, username: username, userId: userId)
    }

    @objc
    private func endEditing() {
        view.endEditing(true)
    }

    func initateAPI(apiKey: String, username: String, userId: String) {
        LMFeedCore.shared.showFeed(
            apiKey: apiKey, username: username, uuid: userId
        ) { [weak self] result in
            switch result {
            case .success(_):
                do {
                    let viewController =
                        try LMFeedSocialFeedViewModel.createModule()
                    UIApplication.shared.windows.first?.rootViewController =
                        UINavigationController(
                            rootViewController: viewController)
                    UIApplication.shared.windows.first?.makeKeyAndVisible()
                } catch {
                    print(error.localizedDescription)
                }
            case .failure(let error):
                self?.showAlert(message: error.localizedDescription)
            }
        }
    }
    
    func showAlert(message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .cancel))
        present(alert, animated: true)
    }
}

class CustomClientView: LMFeedPostCustomCell {
    
    
    private let customLabel: UILabel = {
        let label = UILabel()
        label.text = "Your Custom Text"
        label.textColor = .white  // Set text color
        label.textAlignment = .center  // Center align the text
        label.backgroundColor = .blue  // Set background color
        label.layer.cornerRadius = 8  // Optional: rounded corners
        label.clipsToBounds = true  // Ensure corners are clipped
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // MARK: setupViews
    open override func setupViews() {
        super.setupViews()

        contentView.addSubview(containerView)
        containerView.addSubview(contentStack)
        
        contentStack.addArrangedSubview(customLabel)
    }

    // MARK: setupLayouts
    open override func setupLayouts() {
        super.setupLayouts()

        contentView.pinSubView(subView: containerView)
        containerView.pinSubView(subView: contentStack)

        // Add constraints for customLabel
        NSLayoutConstraint.activate([
            customLabel.leadingAnchor.constraint(
                equalTo: contentStack.leadingAnchor, constant: 16),
            customLabel.trailingAnchor.constraint(
                equalTo: contentStack.trailingAnchor, constant: -16),
            customLabel.topAnchor.constraint(
                equalTo: contentStack.topAnchor, constant: 16),
            customLabel.heightAnchor.constraint(equalToConstant: 100),  // Optional height
        ])
    }

}
