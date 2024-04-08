//
//  LMFeedShareUtility.swift
//  lm-feedCore-iOS
//
//  Created by Devansh Mohata on 27/01/24.
//

import Foundation

public final class LMFeedShareUtility {
    static private(set) var domainURL: String = "lmfeed://yourdomain.com"
    
    public static func setupDomain(with url: String) {
        domainURL = url
    }
    
    static func sharePost(from viewcontroller: UIViewController, postID: String, description: String = "", excludedActivites: [UIActivity.ActivityType] = []) {
        let postString = "\(domainURL)/post?post_id=\(postID)"
        let items: [Any] = [postString, description]
        
        let activityViewController = UIActivityViewController(activityItems: items, applicationActivities: nil)
        activityViewController.excludedActivityTypes = excludedActivites
        
        viewcontroller.present(activityViewController, animated: true)
    }
}
