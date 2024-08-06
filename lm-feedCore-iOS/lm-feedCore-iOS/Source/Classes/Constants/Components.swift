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
    public var notificationScreen: LMFeedNotificationFeedScreen.Type = LMFeedNotificationFeedScreen.self
    
    // MARK: Create Post
    public var createPostScreen: LMFeedCreatePostScreen.Type = LMFeedCreatePostScreen.self
    
    // MARK: Edit Post
    public var editPostScreen: LMFeedEditPostScreen.Type = LMFeedEditPostScreen.self
    
    // MARK: Delete Review Screen
    public var deleteReviewScreen: LMFeedDeleteScreen.Type = LMFeedDeleteScreen.self
    
    // MARK: Report Screem
    public var reportScreen: LMFeedReportScreen.Type = LMFeedReportScreen.self
    
    // MARK: Create Poll
    public var createPollScreen: LMFeedCreatePollScreen.Type = LMFeedCreatePollScreen.self
    
    // MARK: Poll Result
    public var pollResultScreen: LMFeedPollResultScreen.Type = LMFeedPollResultScreen.self
    public var pollResultList: LMFeedPollResultListScreen.Type = LMFeedPollResultListScreen.self
    
    // MARK: Search Screen
    public var searchPostScreen: LMFeedSearchPostScreen.Type = LMFeedSearchPostScreen.self
    
    // MARK: QnA Feed
    public var qnaPostListScreen: LMFeedQnAPostListScreen.Type = LMFeedQnAPostListScreen.self
    public var qnaPostDetailScreen: LMFeedQnAPostDetailScreen.Type = LMFeedQnAPostDetailScreen.self
    public var qnaSearchPostScreen: LMFeedQnASearchPostScreen.Type = LMFeedQnASearchPostScreen.self
    public var qnaUniversalFeed: LMFeedQnAUniversalFeed.Type = LMFeedQnAUniversalFeed.self
}
