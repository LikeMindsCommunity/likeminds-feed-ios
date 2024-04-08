//
//  Components.swift
//  LMFramework
//
//  Created by Devansh Mohata on 28/11/23.
//

import UIKit

public struct Components {
    public static var shared = Self()
    
    // MARK: Universal Feed
    public var universalFeedScreen: LMUniversalFeedScreen.Type = LMUniversalFeedScreen.self
    public var feedListScreen: LMFeedPostListScreen.Type = LMFeedPostListScreen.self
    
    // MARK: Post Detail
    public var postDetailScreen: LMFeedPostDetailScreen.Type = LMFeedPostDetailScreen.self
    
    // MARK: Topic Feed
    public var topicFeedSelectionScreen: LMFeedTopicSelectionScreen.Type = LMFeedTopicSelectionScreen.self
    
    // MARK: Like Screen
    public var likeListScreen: LMFeedLikeListScreen.Type = LMFeedLikeListScreen.self
    
    // MARK: Notification Screen
    public var notificationScreen: LMFeedNotificationScreen.Type = LMFeedNotificationScreen.self
    
    // MARK: Create Post
    public var createPostScreen: LMFeedCreatePostScreen.Type = LMFeedCreatePostScreen.self
    
    // MARK: Edit Post
    public var editPostScreen: LMFeedEditPostScreen.Type = LMFeedEditPostScreen.self
    
    // MARK: Delete Review Screen
    public var deleteReviewScreen: LMFeedDeleteScreen.Type = LMFeedDeleteScreen.self
    
    // MARK: Report Screem
    public var reportScreen: LMFeedReportContentScreen.Type = LMFeedReportContentScreen.self
}
