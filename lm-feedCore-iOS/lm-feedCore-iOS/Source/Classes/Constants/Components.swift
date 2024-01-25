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
    public var postDetailScreen: LMFeedPostDetailViewController.Type = LMFeedPostDetailViewController.self
    
    // MARK: Topic Feed
    public var topicFeedSelectionScreen: LMFeedTopicSelectionViewController.Type = LMFeedTopicSelectionViewController.self
    
    // MARK: Tagging List View
    public var taggingListView: LMFeedTaggingListView.Type = LMFeedTaggingListView.self
    
    // MARK: Like Screen
    public var likeListScreen: LMFeedLikeViewController.Type = LMFeedLikeViewController.self
    
    // MARK: Notification Screen
    public var notificationScreen: LMFeedNotificationViewController.Type = LMFeedNotificationViewController.self
    
    // MARK: Create Post
    public var createPostScreen: LMFeedCreatePostViewController.Type = LMFeedCreatePostViewController.self
    
    // MARK: Edit Post
    public var editPostScreen: LMFeedEditPostViewController.Type = LMFeedEditPostViewController.self
}
