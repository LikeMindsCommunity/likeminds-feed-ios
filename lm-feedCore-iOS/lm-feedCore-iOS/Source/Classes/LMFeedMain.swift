//
//  LMFeedMain.swift
//  likeminds-feed-iOS
//
//  Created by Devansh Mohata on 28/12/23.
//

import LikeMindsFeed
// Keep Onyl Auth Logic
public class LMFeedMain {
    
    private init() {}
    
    public static var shared: LMFeedMain = .init()
    
    public func initiateLikeMindsFeed(withViewController viewController: UIViewController, apiKey: String, username: String, userId: String) {
        let request = InitiateUserRequest.builder()
            .apiKey(apiKey)
            .userName(username)
            .uuid(userId)
            .isGuest(false)
            .build()
        
        LMAWSManager.shared.initialize()
        
        LMFeedClient.shared.initiateUser(request: request) { [weak self] response in
            print(response)
            guard let user = response.data?.user else {
                let alert = UIAlertController(title: "Error", message: response.errorMessage ?? "", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                viewController.present(alert, animated: false)
                return
            }
            if response.data?.appAccess == false {
                self?.logout(response.data?.refreshToken ?? "", deviceId: UIDevice.current.identifierForVendor?.uuidString ?? "")
                return
            }
            
            LocalPreferences.apiKey = apiKey
            LocalPreferences.userObj = user
            
            let homeFeedVC = UINavigationController(rootViewController: LMUniversalFeedViewModel.createModule())
            homeFeedVC.modalPresentationStyle = .fullScreen
            viewController.navigationController?.present(homeFeedVC, animated: true)
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
