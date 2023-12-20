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
    public var feedListViewController: LMUniversalFeedViewController.Type = LMUniversalFeedViewController.self
    public var headerCell: LMFeedPostHeaderView.Type = LMFeedPostHeaderView.self
    public var documentCell: LMFeedPostDocumentCell.Type = LMFeedPostDocumentCell.self
    public var linkCell: LMFeedPostLinkCell.Type = LMFeedPostLinkCell.self
    public var postCell: LMFeedPostMediaCell.Type = LMFeedPostMediaCell.self
    public var imageCollectionCell: LMFeedPostImageCollectionCell.Type = LMFeedPostImageCollectionCell.self
    public var videoCollectionCell: LMFeedPostVideoCollectionCell.Type = LMFeedPostVideoCollectionCell.self
    public var footerCell: LMFeedPostFooterView.Type = LMFeedPostFooterView.self
    
    // MARK: Post Detail
    public var postDetailScreen: LMFeedPostDetailViewController.Type = LMFeedPostDetailViewController.self
    public var totalCommentCell: LMFeedPostDetailTotalCommentCell.Type = LMFeedPostDetailTotalCommentCell.self
    public var commentHeaderView: LMFeedPostDetailCommentHeaderView.Type = LMFeedPostDetailCommentHeaderView.self
    public var commentCell: LMFeedPostDetailCommentCell.Type = LMFeedPostDetailCommentCell.self
    public var loadMoreReplies: LMFeedPostMoreRepliesCell.Type = LMFeedPostMoreRepliesCell.self
    
    // MARK: Topic Feed
    public var topicFeed: LMFeedTopicView.Type = LMFeedTopicView.self
    public var topicFeedCollectionCell: LMFeedTopicViewCell.Type = LMFeedTopicViewCell.self
    public var topicFeedEditIconCollectionCell: LMFeedTopicEditIconViewCell.Type = LMFeedTopicEditIconViewCell.self
    public var topicFeedEditCollectionCell: LMFeedTopicEditViewCell.Type = LMFeedTopicEditViewCell.self
}
