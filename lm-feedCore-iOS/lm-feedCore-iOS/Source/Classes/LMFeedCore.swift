//
//  LMFeedCore.swift
//  likeminds-feed-iOS
//
//  Created by Devansh Mohata on 28/12/23.
//

import FirebaseCore
import FirebaseMessaging
import LikeMindsFeedUI
import LikeMindsFeed

public protocol LMFeedCoreCallback: AnyObject {
    func onAccessTokenExpiredAndRefreshed(accessToken: String, refreshToken: String)
    func onRefreshTokenExpired(_ completionHandler: (((accessToken: String, refreshToken: String)) -> Void)?)
}

// Keep Only Auth Logic
public class LMFeedCore {
    private init() {}
    
    public static var shared: LMFeedCore = .init()
    static var analytics: LMFeedAnalyticsProtocol?
    static private(set) var isInitialized: Bool = false
    private(set) var coreCallback: LMFeedCoreCallback?
    var deviceId: String?
    
    
    public func setupAnalytics(_ analytics: LMFeedAnalyticsProtocol) {
        Self.analytics = analytics
    }
    
    public func setupFeed(deviceId: String? = nil) {
        self.deviceId = deviceId
        LMFeedClient.shared.setTokenManager(with: self)
        LMAWSManager.shared.initialize()
    }
    
    public func showFeed(apiKey: String, username: String, uuid: String, completionHandler: ((Result<Void, LMFeedError>) -> Void)?) {
        let tokens = LMFeedClient.shared.getTokens()
        
        if tokens.success,
           let accessToken = tokens.data?.accessToken,
           let refreshToken = tokens.data?.refreshToken {
            validateUser(accessToken: accessToken, refreshToken: refreshToken) { result in
                completionHandler?(result)
            }
        } else {
            initiateLikeMindsFeed(apiKey: apiKey, username: username, userId: uuid, completionHandler: completionHandler)
        }
    }
    
    public func showFeed(accessToken: String?, refreshToken: String?, handler: LMFeedCoreCallback?, completionHandler: ((Result<Void, LMFeedError>) -> Void)?) {
        self.coreCallback = handler
        
        if let accessToken,
           let refreshToken {
            validateUser(accessToken: accessToken, refreshToken: refreshToken, completionHandler: completionHandler)
        } else if let accessToken = LMFeedClient.shared.getTokens().data?.accessToken,
                  let refreshToken = LMFeedClient.shared.getTokens().data?.refreshToken {
            validateUser(accessToken: accessToken, refreshToken: refreshToken, completionHandler: completionHandler)
        } else {
            completionHandler?(.failure(.apiInitializationFailed(error: "Invalid Tokens")))
            return
        }
    }
    
    private func validateUser(accessToken: String, refreshToken: String, completionHandler: ((Result<Void, LMFeedError>) -> Void)?) {
        let request = ValidateUserRequest
            .builder()
            .accessToken(accessToken)
            .refreshToken(refreshToken)
            .build()
        
        LMFeedClient.shared.validateUser(request) { [weak self] response in
            guard response.success else {
                completionHandler?(.failure(.apiInitializationFailed(error: response.errorMessage)))
                return
            }
            
            if response.data?.appAccess == false {
                self?.logout(refreshToken, deviceId: UIDevice.current.identifierForVendor?.uuidString ?? "")
                completionHandler?(.failure(.appAccessFalse))
                return
            }
            
            if let deviceId = self?.deviceId, !deviceId.isEmpty{
                self?.registerDevice(deviceId: deviceId)
            }
            
            Self.isInitialized = true
            self?.fetchCommunityConfiguration()
            
            completionHandler?(.success(()))
        }
    }
    
    private func initiateLikeMindsFeed(apiKey: String, username: String?, userId: String, completionHandler: ((Result<Void, LMFeedError>) -> Void)?) {
        let request = InitiateUserRequest.builder()
            .apiKey(apiKey)
            .userName(username)
            .uuid(userId)
            .isGuest(false)
            .build()
        
        LMFeedClient.shared.initiateUser(request: request) { [weak self] response in
            guard response.success else {
                completionHandler?(.failure(.apiInitializationFailed(error: response.errorMessage)))
                return
            }
            
            if response.data?.appAccess == false {
                self?.logout(response.data?.refreshToken ?? "", deviceId: UIDevice.current.identifierForVendor?.uuidString ?? "")
                completionHandler?(.failure(.appAccessFalse))
                return
            }
            
            if let deviceId = self?.deviceId, !deviceId.isEmpty{
                self?.registerDevice(deviceId: deviceId)
            }
            
            Self.isInitialized = true
            self?.fetchCommunityConfiguration()
            
            completionHandler?(.success(()))
        }
    }
    
    // This function extracts FCM Token and calls registerDevice api
    private func registerDevice(deviceId: String, completion: ((Result<Void, LMFeedError>) -> Void)? = nil) {
        Messaging.messaging().token { token, error in
          if let error {
            debugPrint(error)
          } else if let token {
              self.registerDevice(with: token, deviceId: deviceId)
          }
        }
    }
    
    /// Registers the current device for push notifications with the LikeMinds system.
    ///
    /// This function performs two main tasks:
    /// 1. Registers the device with the chat system using the obtained FCM token and provided device ID.
    ///
    /// - Parameter deviceId: A unique identifier for the current device.
    /// - Parameter fcmToken: FCM Token
    ///
    /// - Note: This function relies on Firebase Messaging to obtain the FCM token. Ensure that Firebase is properly configured in your project before calling this function.
    ///
    /// - Important: This function does not handle Firebase initialization. Make sure Firebase is initialized before calling this function.
    ///
    /// The function follows these steps:
    /// 1. If the token is successfully retrieved, it creates a `RegisterDeviceRequest` with the device ID and FCM token.
    /// 2. Sends the registration request to LikeMinds system using `LMChatClient.shared.registerDevice`.
    /// 3. Prints an error message if the registration fails.I
    ///
    public func registerDevice(with token: String, deviceId: String, completion: ((Result<Void, LMFeedError>) -> Void)? = nil){
        let request = RegisterDeviceRequest.builder()
            .token(token)
            .deviceId(deviceId)
            .build()
        
        LMFeedClient.shared.registerDevice(request: request) { response in
            if response.success {
                completion?(.success(()))
            } else {
                completion?(.failure(.notificationRegisterationFailed(error: response.errorMessage)))
            }
        }
    }
    
    public func logout(_ refreshToken: String, deviceId: String, completion: ((Result<Void, LMFeedError>) -> Void)? = nil) {
        let request = LogoutRequest.builder()
            .refreshToken(refreshToken)
            .deviceId(deviceId)
            .build()
        
        LMFeedClient.shared.logout(request: request) { response in
            if response.success {
                completion?(.success(()))
            } else {
                completion?(.failure(.logoutFailed(error: response.errorMessage)))
            }
        }
    }
    
    public func didReceiveNotification(_ notification: UNNotificationRequest, completion: ((Result<LMViewController, LMFeedError>) -> Void)?) {
        guard Self.isInitialized,
              let route = notification.content.userInfo["route"] as? String else {
            completion?(.failure(.feedNotInitialized))
            return
        }
        
        LMFeedRouter.fetchRoute(from: route) { result in
            switch result {
            case .success(let viewcontroller):
                completion?(.success(viewcontroller))
            case .failure(let error):
                completion?(.failure(error))
            }
        }
    }
    
    func fetchCommunityConfiguration() {
        LMFeedClient.shared.getCommunityConfiguration(GetCommunityConfigurationRequest.builder()) { response in
            let configurations = response.data?.communityConfigurations ?? []
            LocalPreferences.communityConfiguration = .init(configs: configurations)
        }
    }
}


extension LMFeedCore: LMFeedSDKCallback {
    public func onAccessTokenExpiredAndRefreshed(accessToken: String, refreshToken: String) {
        coreCallback?.onAccessTokenExpiredAndRefreshed(accessToken: accessToken, refreshToken: refreshToken)
    }
    
    public func onRefreshTokenExpired(_ completionHandler: (((accessToken: String, refreshToken: String)?) -> Void)?) {
        let apiData = LMFeedClient.shared.getAPIKey()
        
        if let apiKey = apiData.data,
           let uuid =  LMFeedClient.shared.getUserDetails()?.sdkClientInfo?.uuid {
            initiateLikeMindsFeed(apiKey: apiKey, username: nil, userId: uuid) { response in
                switch response {
                case .success():
                    let tokens = LMFeedClient.shared.getTokens()
                    if tokens.success,
                       let accessToken = tokens.data?.accessToken,
                       let refreshToken = tokens.data?.refreshToken {
                        completionHandler?((accessToken, refreshToken))
                        return
                    }
                case .failure(_):
                    break
                }
                completionHandler?(nil)
            }
        } else {
            coreCallback?.onRefreshTokenExpired(completionHandler)
        }
    }
}
