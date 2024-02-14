//
//  ViewController.swift
//  likeminds-feed-iOS
//
//  Created by Devansh Mohata on 12/19/2023.
//  Copyright (c) 2023 Devansh Mohata. All rights reserved.
//

import UIKit
import lm_feedUI_iOS
import lm_feedCore_iOS

class ViewController: UIViewController {

    @IBOutlet private weak var apiKeyTextField: UITextField!
    @IBOutlet private weak var usernameTextField: UITextField!
    @IBOutlet private weak var userIdTextField: UITextField!
    @IBOutlet private weak var submitBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        submitBtn.layer.cornerRadius = 8
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(endEditing)))
        
        if let apiKey = LocalPreferences.apiKey,
           !apiKey.isEmpty,
           let username = LocalPreferences.userObj?.name,
           let uuid = LocalPreferences.userObj?.sdkClientInfo?.uuid {
            LMFeedMain.shared.setupLikeMindsFeed(apiKey: apiKey, analytics: DummyAnalytics())
            LMFeedMain.shared.initiateLikeMindsFeed(username: username, userId: uuid) { [weak self] result in
                switch result {
                case .success(_):
                    guard let viewController = LMUniversalFeedViewModel.createModule() else { return }
                    self?.navigationController?.pushViewController(viewController, animated: true)
                case .failure(let error):
                    dump(error)
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
        
        LMFeedMain.shared.initiateLikeMindsFeed(username: username, userId: userId) { [weak self] result in
            switch result {
            case .success(_):
                guard let viewController = LMUniversalFeedViewModel.createModule() else { return }
                self?.navigationController?.pushViewController(viewController, animated: true)
            case .failure(let error):
                dump(error)
            }
        }
    }
    
    @objc
    private func endEditing() {
        view.endEditing(true)
    }
}
