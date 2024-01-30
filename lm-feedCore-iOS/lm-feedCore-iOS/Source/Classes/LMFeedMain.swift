//
//  LMFeedMain.swift
//  likeminds-feed-iOS
//
//  Created by Devansh Mohata on 28/12/23.
//

import LikeMindsFeed
// Keep Only Auth Logic
public class LMFeedMain {
    
    private init() {}
    
    public static var shared: LMFeedMain = .init()
    public static private(set) var isInitialized: Bool = false
    
    public func initiateLikeMindsFeed(apiKey: String, username: String, userId: String, completionHandler: ((Result<Bool, LMFeedError>) -> Void)?) {
        let request = InitiateUserRequest.builder()
            .apiKey(apiKey)
            .userName(username)
            .uuid(userId)
            .isGuest(false)
            .build()
        
        LMAWSManager.shared.initialize()
        
        LMFeedClient.shared.initiateUser(request: request) { [weak self] response in
            guard response.success,
                  let user = response.data?.user else {
                completionHandler?(.failure(.apiInitializationFailed(error: response.errorMessage)))
                return
            }
            
            if response.data?.appAccess == false {
                self?.logout(response.data?.refreshToken ?? "", deviceId: UIDevice.current.identifierForVendor?.uuidString ?? "")
                completionHandler?(.failure(.appAccessFalse))
                return
            }
            
            LocalPreferences.apiKey = apiKey
            LocalPreferences.userObj = user
            
            Self.isInitialized = true
            
            completionHandler?(.success(true))
        }
    }
    
    public func logout(_ refreshToken: String, deviceId: String) {
        let request = LogoutRequest.builder()
            .refreshToken(refreshToken)
            .deviceId(deviceId)
            .build()
        LMFeedClient.shared.logout(request: request) { response in
            dump(response)
        }
    }
}
