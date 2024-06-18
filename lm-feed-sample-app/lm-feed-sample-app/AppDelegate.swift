//
//  AppDelegate.swift
//  lm-feed-sample-app
//
//  Created by Devansh Mohata on 04/01/24.
//

import FirebaseCore
import FirebaseMessaging
import Kingfisher
import LikeMindsFeedCore
import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    static var fcmToken: String?
    
    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
        registerForPushNotifications(application: application)
        
        ImageCache.default.memoryStorage.config.totalCostLimit = 1 //1 in bytes
        return true
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        return true
    }

    // MARK: UISceneSession Lifecycle
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) { }
}


// MARK: UNUserNotificationCenterDelegate
extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse) async {
        handleNotification(notification: response.notification.request)
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
        handleNotification(notification: notification.request)
        
        if #available(iOS 14.0, *) {
            return .sound
        } else {
            return .alert
        }
    }
    
    func handleNotification(notification: UNNotificationRequest) {
        LMFeedCore.shared.didReceiveNotification(notification) { result in
            switch result {
            case .success(let lmVC):
                if let vc = UIApplication.shared.topMostViewController() {
                    lmVC.modalPresentationStyle = .overCurrentContext
                    vc.present(lmVC, animated: true)
                } else {
                    print("Cannot find Top View Controller")
                }
            case .failure(let error):
                print("Error in Notification Navigation: \(error)")
            }
        }
    }
    
    private func registerForPushNotifications(application: UIApplication) {
        UNUserNotificationCenter.current().delegate = self
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(options: authOptions) {
            (granted, error) in
            guard granted else { return }
            DispatchQueue.main.async {
                application.registerForRemoteNotifications()
            }
        }
    }
}


// MARK: Message
extension AppDelegate: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        Self.fcmToken = fcmToken
    }
}


extension UIApplication {
    func topMostViewController() -> UIViewController? {
        return UIApplication.shared.windows.filter {$0.isKeyWindow}.first?.rootViewController?.topMostViewController()
    }
}
