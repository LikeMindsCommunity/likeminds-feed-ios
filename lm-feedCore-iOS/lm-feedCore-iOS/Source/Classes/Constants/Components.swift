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
    public var universalFeedViewController: LMUniversalFeedViewController.Type = LMUniversalFeedViewController.self
    public var feedListViewController: LMFeedPostListViewController.Type = LMFeedPostListViewController.self
    
    // MARK: Post Detail
    public var postDetailScreen: LMFeedPostDetailScreen.Type = LMFeedPostDetailScreen.self
    
    // MARK: Topic Feed
    public var topicFeedSelectionScreen: LMFeedTopicSelectionScreen.Type = LMFeedTopicSelectionScreen.self
    
    // MARK: Tagging List View
    public var taggingListView: LMFeedTaggingListView.Type = LMFeedTaggingListView.self
    
    // MARK: Like Screen
    public var likeListScreen: LMFeedLikeListScreen.Type = LMFeedLikeListScreen.self
    
    // MARK: Notification Screen
    public var notificationScreen: LMFeedNotificationScreen.Type = LMFeedNotificationScreen.self
    
    // MARK: Create Post
    public var createPostScreen: LMFeedCreatePostViewController.Type = LMFeedCreatePostViewController.self
    
    // MARK: Edit Post
    public var editPostScreen: LMFeedEditPostViewController.Type = LMFeedEditPostViewController.self
    
    // MARK: Delete Review Screen
    public var deleteReviewScreen: LMFeedDeleteReviewScreen.Type = LMFeedDeleteReviewScreen.self
    
    // MARK: Report Screem
    public var reportScreen: LMFeedReportContentViewController.Type = LMFeedReportContentViewController.self
}
