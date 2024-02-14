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
    
    // MARK: Common Components
    public var documentPreview: LMFeedDocumentPreview.Type = LMFeedDocumentPreview.self
    public var imagePreviewCell: LMFeedImageCollectionCell.Type = LMFeedImageCollectionCell.self
    public var linkPreview: LMFeedLinkPreview.Type = LMFeedLinkPreview.self
    public var videoPreviewCell: LMFeedVideoCollectionCell.Type = LMFeedVideoCollectionCell.self
    
    // MARK: Universal Feed Components
    public var documentCell: LMFeedPostDocumentCell.Type = LMFeedPostDocumentCell.self
    public var footerCell: LMFeedPostFooterView.Type = LMFeedPostFooterView.self
    public var headerCell: LMFeedPostHeaderView.Type = LMFeedPostHeaderView.self
    public var linkCell: LMFeedPostLinkCell.Type = LMFeedPostLinkCell.self
    public var postCell: LMFeedPostMediaCell.Type = LMFeedPostMediaCell.self
    
    // MARK: Post Detail Components
    public var commentCell: LMFeedPostDetailCommentCell.Type = LMFeedPostDetailCommentCell.self
    public var commentHeaderView: LMFeedPostDetailCommentHeaderView.Type = LMFeedPostDetailCommentHeaderView.self
    public var loadMoreReplies: LMFeedPostMoreRepliesCell.Type = LMFeedPostMoreRepliesCell.self
    public var noCommentFooter: LMFeedNoCommentWidget.Type = LMFeedNoCommentWidget.self
    public var postDetailDocumentCell: LMFeedPostDetailDocumentCell.Type = LMFeedPostDetailDocumentCell.self
    public var postDetailLinkCell: LMFeedPostDetailLinkCell.Type = LMFeedPostDetailLinkCell.self
    public var postDetailMediaCell: LMFeedPostDetailMediaCell.Type = LMFeedPostDetailMediaCell.self
    public var totalCommentFooter: LMFeedPostDetailTotalCommentCell.Type = LMFeedPostDetailTotalCommentCell.self
    
    
    // MARK: Topic Feed Components
    public var topicFeed: LMFeedTopicView.Type = LMFeedTopicView.self
    public var topicFeedCollectionCell: LMFeedTopicViewCell.Type = LMFeedTopicViewCell.self
    public var topicFeedEditCollectionCell: LMFeedTopicEditViewCell.Type = LMFeedTopicEditViewCell.self
    public var topicFeedEditIconCollectionCell: LMFeedTopicEditIconViewCell.Type = LMFeedTopicEditIconViewCell.self
    public var topicSelectIconCollectionCell: LMFeedSelectTopicViewCell.Type = LMFeedSelectTopicViewCell.self
    
    // MARK: Tagging View
    public var taggingTableViewCell: LMFeedTaggingUserTableCell.Type = LMFeedTaggingUserTableCell.self
    
    // MARK: Create Post Components
    public var createPostAddMediaView: LMFeedCreatePostAddMediaView.Type = LMFeedCreatePostAddMediaView.self
    public var createPostHeaderView: LMFeedCreatePostHeaderView.Type = LMFeedCreatePostHeaderView.self
    
    // MARK: Like Count Screen Components
    public var likedUserTableCell: LMFeedLikeUserTableCell.Type = LMFeedLikeUserTableCell.self
    
    // MARK: Notification Screen Components
    public var notificationTableCell: LMFeedNotificationView.Type = LMFeedNotificationView.self
    
    // MARK: Report Screen Components
    public var reportCollectionCell: LMFeedReportViewCell.Type = LMFeedReportViewCell.self
}
