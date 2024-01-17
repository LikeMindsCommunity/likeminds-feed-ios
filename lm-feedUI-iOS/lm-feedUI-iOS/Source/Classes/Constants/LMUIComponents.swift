//
//  LMUIComponents.swift
//  LMFramework
//
//  Created by Devansh Mohata on 28/11/23.
//

import UIKit

public struct LMUIComponents {
    public static var shared = Self()
    
    private init() { }
    
    // MARK: Universal Feed Components
    public var headerCell: LMFeedPostHeaderView.Type = LMFeedPostHeaderView.self
    public var documentCell: LMFeedPostDocumentCell.Type = LMFeedPostDocumentCell.self
    public var linkCell: LMFeedPostLinkCell.Type = LMFeedPostLinkCell.self
    public var postCell: LMFeedPostMediaCell.Type = LMFeedPostMediaCell.self
    public var imageCollectionCell: LMFeedPostImageCollectionCell.Type = LMFeedPostImageCollectionCell.self
    public var videoCollectionCell: LMFeedPostVideoCollectionCell.Type = LMFeedPostVideoCollectionCell.self
    public var footerCell: LMFeedPostFooterView.Type = LMFeedPostFooterView.self
    
    // MARK: Post Detail Components
    public var totalCommentCell: LMFeedPostDetailTotalCommentCell.Type = LMFeedPostDetailTotalCommentCell.self
    public var commentHeaderView: LMFeedPostDetailCommentHeaderView.Type = LMFeedPostDetailCommentHeaderView.self
    public var commentCell: LMFeedPostDetailCommentCell.Type = LMFeedPostDetailCommentCell.self
    public var loadMoreReplies: LMFeedPostMoreRepliesCell.Type = LMFeedPostMoreRepliesCell.self
    
    // MARK: Topic Feed Components
    public var topicFeed: LMFeedTopicView.Type = LMFeedTopicView.self
    public var topicFeedCollectionCell: LMFeedTopicViewCell.Type = LMFeedTopicViewCell.self
    public var topicFeedEditIconCollectionCell: LMFeedTopicEditIconViewCell.Type = LMFeedTopicEditIconViewCell.self
    public var topicFeedEditCollectionCell: LMFeedTopicEditViewCell.Type = LMFeedTopicEditViewCell.self
    
    // MARK: Tagging View
    public var taggingTableViewCell: LMFeedTaggingUserTableCell.Type = LMFeedTaggingUserTableCell.self
    
    // MARK: Create Post Components
    public var createPostHeaderView: LMFeedCreatePostHeaderView.Type = LMFeedCreatePostHeaderView.self
    public var createPostLinkPreview: LMFeedCreatePostLinkPreview.Type = LMFeedCreatePostLinkPreview.self
    public var createPostAddMediaView: LMFeedCreatePostAddMediaView.Type = LMFeedCreatePostAddMediaView.self
}
