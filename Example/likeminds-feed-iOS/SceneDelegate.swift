//
//  SceneDelegate.swift
//  likeminds-feed-iOS_Example
//
//  Created by Devansh Mohata on 19/12/23.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import likeminds_feed_iOS
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        //        Components.shared.feedListViewController = CustomTableView.self
        //        Components.shared.headerCell = CustomHeaderView.self
        //        Components.shared.postCell = CustomTableCell.self
        //        Components.shared.imageCollectionCell = CustomImageView.self
        
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            
            let vc = Components.shared.feedListViewController.init()
            window.rootViewController = UINavigationController(rootViewController: vc)
            
            self.window = window
            window.makeKeyAndVisible()
        }
    }
}