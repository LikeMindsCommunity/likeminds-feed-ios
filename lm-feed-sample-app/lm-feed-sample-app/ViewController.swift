//
//  ViewController.swift
//  likeminds-feed-iOS
//
//  Created by Devansh Mohata on 12/19/2023.
//  Copyright (c) 2023 Devansh Mohata. All rights reserved.
//

import UIKit
import LikeMindsFeedUI
import LikeMindsFeedCore

class ViewController: UIViewController {

    @IBOutlet private weak var apiKeyTextField: UITextField!
    @IBOutlet private weak var usernameTextField: UITextField!
    @IBOutlet private weak var userIdTextField: UITextField!
    @IBOutlet private weak var submitBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        submitBtn.layer.cornerRadius = 8
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(endEditing)))
        
        FeedTokenHandler.initiateSDK { [weak self] tokens in
            LMFeedCore.shared.setupFeed(accessToken: tokens.accessToken, refreshToken: tokens.refreshToken) { result in
                switch result {
                case .success(_):
                    guard let viewController = LMUniversalFeedViewModel.createModule() else { return }
                    UIApplication.shared.windows.first?.rootViewController = UINavigationController(rootViewController: viewController)
                    UIApplication.shared.windows.first?.makeKeyAndVisible()
                case .failure(let error):
                    let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
                    alert.addAction(.init(title: "OK", style: .default))
                    self?.present(alert, animated: true)
                }
            }
        }
    }
    
    @IBAction private func submitBtnClicked(_ sender: UIButton) {
        guard let apiKey = apiKeyTextField.text,
              !apiKey.isEmpty else {
            apiKeyTextField.layer.borderColor = UIColor.red.cgColor
            apiKeyTextField.layer.borderWidth = 1
            return
        }
        
        var username = usernameTextField.text ?? "username"
        var userId = userIdTextField.text ?? "userId"
        
        if username.isEmpty {
            username = "username"
        }
        
        if userId.isEmpty {
            userId = "userId"
        }
    }
    
    @objc
    private func endEditing() {
        view.endEditing(true)
    }
    
    
    func initateAPI(apiKey: String, username: String, userId: String) {
        LMFeedCore.shared.setupFeed(apiKey: apiKey, username: username, uuid: userId) { [weak self] result in
            switch result {
            case .success(_):
                guard let viewController = LMUniversalFeedViewModel.createModule() else { return }
                UIApplication.shared.windows.first?.rootViewController = UINavigationController(rootViewController: viewController)
                UIApplication.shared.windows.first?.makeKeyAndVisible()
            case .failure(let error):
                let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
                alert.addAction(.init(title: "OK", style: .default))
                self?.present(alert, animated: true)
            }
        }
    }
}
