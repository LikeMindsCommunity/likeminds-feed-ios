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
        
        LMFeedCore.shared.setupFeedCoreCallback(with: self)
        
        initiateSDK { [weak self] tokens in
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


extension ViewController: LMFeedCoreCallback {
    func onAccessTokenExpiredAndRefreshed(accessToken: String, refreshToken: String) {
        print("\(#function)-\(#file)")
    }
    
    func onRefreshTokenExpired(_ completionHandler: (((accessToken: String, refreshToken: String)) -> Void)?) {
        print("\(#function)-\(#file)")
        initiateSDK { tokens in
            completionHandler?(tokens)
        }
    }
    
    func initiateSDK(_ completionHandler: (((accessToken: String, refreshToken: String)) -> Void)?) {
        // Create the URL
        guard let url = URL(string: "https://betaauth.likeminds.community/sdk/initiate") else {
            fatalError("Invalid URL")
        }

        // Create the request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        // Add headers
        request.addValue("br;q=1.0, gzip;q=0.9, deflate;q=0.8", forHTTPHeaderField: "Accept-Encoding")
        request.addValue("lm-feed-sample-app/1.0.2 (com.likeminds.lm-feed-sample-app; build:3; iOS 15.8.2) Alamofire/5.7.1", forHTTPHeaderField: "User-Agent")
        request.addValue("en-IN;q=1.0", forHTTPHeaderField: "Accept-Language")
        request.addValue("ios", forHTTPHeaderField: "x-platform-code")
        request.addValue("9", forHTTPHeaderField: "x-version-code")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("6b51af13-ce28-444b-a571-53a3fb125444", forHTTPHeaderField: "x-api-key")
        request.addValue("feed", forHTTPHeaderField: "x-sdk-source")

        // JSON body data
        let body: [String: Any] = [
            "is_guest": false,
            "api_key": "6b51af13-ce28-444b-a571-53a3fb125444",
            "uuid": "devansh",
            "token_expiry_beta": 1,
            "rtm_token_expiry_beta": 2
        ]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
        } catch {
            print("Error serializing JSON: \(error)")
            return
        }

        // Create the URLSession
        let session = URLSession.shared

        // Create the data task
        let task = session.dataTask(with: request) { data, response, error in
            // Handle response
            if let error = error {
                print("Error: \(error)")
                return
            }

            guard let data = data, let httpResponse = response as? HTTPURLResponse else {
                print("No data or response")
                return
            }

            print("Status code: \(httpResponse.statusCode)")

            // Define a struct for the JSON response
            struct ResponseData: Codable {
                let success: Bool
                let data: DataClass
            }

            struct DataClass: Codable {
                let refreshToken: String
                let accessToken: String

                enum CodingKeys: String, CodingKey {
                    case refreshToken = "refresh_token"
                    case accessToken = "access_token"
                }
            }

            // Parse the JSON data
            do {
                let response = try JSONDecoder().decode(ResponseData.self, from: data)
                let accessToken = response.data.accessToken
                let refreshToken = response.data.refreshToken

                debugPrint("====Calling From \(#file)====")
                debugPrint("Access Token: \(accessToken)")
                debugPrint("Refresh Token: \(refreshToken)")
                debugPrint("====Calling From \(#file)====")
                
                completionHandler?((accessToken, refreshToken))
            } catch {
                print("Error parsing JSON: \(error)")
            }
        }

        // Start the task
        task.resume()
    }
}
