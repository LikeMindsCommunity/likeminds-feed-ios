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
    public var imagePreview: LMFeedImageCollectionCell.Type = LMFeedImageCollectionCell.self
    public var linkPreview: LMFeedLinkPreview.Type = LMFeedLinkPreview.self
    public var videoPreview: LMFeedVideoCollectionCell.Type = LMFeedVideoCollectionCell.self
    
    // MARK: Media Preview Components
    public var mediaImageZoomPreview: LMFeedZoomImageViewContainer.Type = LMFeedZoomImageViewContainer.self
    public var mediaVideoPreviewCell: LMFeedMediaVideoPreview.Type = LMFeedMediaVideoPreview.self
    public var mediaImagePreviewCell: LMFeedMediaImagePreview.Type = LMFeedMediaImagePreview.self
    
    // MARK: Universal Feed Components
    public var textCell: LMFeedPostTextCell.Type = LMFeedPostTextCell.self
    public var documentCell: LMFeedPostDocumentCell.Type = LMFeedPostDocumentCell.self
    public var footerView: LMFeedPostFooterView.Type = LMFeedPostFooterView.self
    public var headerView: LMFeedPostHeaderView.Type = LMFeedPostHeaderView.self
    public var linkCell: LMFeedPostLinkCell.Type = LMFeedPostLinkCell.self
    public var postCell: LMFeedPostMediaCell.Type = LMFeedPostMediaCell.self
    public var pollCell: LMFeedPostPollCell.Type = LMFeedPostPollCell.self
    
    // MARK: Comment Components
    public var replyView: LMFeedReplyView.Type = LMFeedReplyView.self
    public var commentView: LMFeedCommentView.Type = LMFeedCommentView.self
    public var loadMoreReplies: LMFeedMoreRepliesView.Type = LMFeedMoreRepliesView.self
    
    // MARK: Post Detail Components
    public var postDetailDocumentCell: LMFeedPostDetailDocumentCell.Type = LMFeedPostDetailDocumentCell.self
    public var postDetailLinkCell: LMFeedPostDetailLinkCell.Type = LMFeedPostDetailLinkCell.self
    public var postDetailMediaCell: LMFeedPostDetailMediaCell.Type = LMFeedPostDetailMediaCell.self
    public var postDetailPollCell: LMFeedPostDetailPollCell.Type = LMFeedPostDetailPollCell.self
    public var postDetailHeaderView: LMFeedPostDetailHeaderView.Type = LMFeedPostDetailHeaderView.self
    public var postDetailFooterView: LMFeedPostDetailFooterView.Type = LMFeedPostDetailFooterView.self
    
    // MARK: Topic Feed Components
    public var topicFeedView: LMFeedTopicView.Type = LMFeedTopicView.self
    public var topicFeedDisplayView: LMFeedTopicViewCell.Type = LMFeedTopicViewCell.self
    public var topicFeedEditView: LMFeedTopicEditViewCell.Type = LMFeedTopicEditViewCell.self
    public var topicFeedEditIconView: LMFeedTopicEditIcon.Type = LMFeedTopicEditIcon.self
    public var topicSelectIconView: LMFeedSelectTopicViewCell.Type = LMFeedSelectTopicViewCell.self
    
    // MARK: Tagging View
    public var taggingUserItem: LMFeedTaggingUserItem.Type = LMFeedTaggingUserItem.self
    
    // MARK: Create Post Components
    public var addMediaView: LMFeedAddMediaView.Type = LMFeedAddMediaView.self
    public var createPostHeaderView: LMFeedCreatePostHeaderView.Type = LMFeedCreatePostHeaderView.self
    public var createPollDisplayView: LMFeedCreateDisplayPollView.Type = LMFeedCreateDisplayPollView.self
    public var createPollDisplayWidget: LMFeedDisplayCreatePollWidget.Type = LMFeedDisplayCreatePollWidget.self
    public var createPollHeaderView: LMFeedCreatePollHeader.Type = LMFeedCreatePollHeader.self
    public var createPollQuestionView: LMFeedCreatePollOptionsView.Type = LMFeedCreatePollOptionsView.self
    public var createPollDateView: LMFeedCreatePollDateView.Type = LMFeedCreatePollDateView.self
    public var createPollMetaView: LMFeedCreatePollMetaView.Type = LMFeedCreatePollMetaView.self
    public var createPollOptionCell: LMFeedCreatePollOptionWidget.Type = LMFeedCreatePollOptionWidget.self
    
    // MARK: Like Count Screen Components
    public var memberItem: LMFeedMemberItem.Type = LMFeedMemberItem.self
    
    // MARK: Notification Screen Components
    public var notificationItem: LMFeedNotificationItem.Type = LMFeedNotificationItem.self
    
    // MARK: Report Screen Components
    public var reportItem: LMFeedReportItem.Type = LMFeedReportItem.self
    
    // MARK: Display Poll Components
    public var pollDisplayView: LMFeedDisplayPollView.Type = LMFeedDisplayPollView.self
    public var pollDisplayWidget: LMFeedDisplayPollOptionWidget.Type = LMFeedDisplayPollOptionWidget.self
    
    
    // MARK: QA Theme
    public var qnaPostCell: LMFeedPostQnAMediaCell.Type = LMFeedPostQnAMediaCell.self
    public var qnaLinkCell: LMFeedPostQnALinkCell.Type = LMFeedPostQnALinkCell.self
    public var qnaDocumentCell: LMFeedPostQnADocumentCell.Type = LMFeedPostQnADocumentCell.self
    public var qnaPollCell: LMFeedPostQnAPollCell.Type = LMFeedPostQnAPollCell.self
    public var qnaFooterView: LMFeedPostQnAFooterView.Type = LMFeedPostQnAFooterView.self
    public var qnaFooterDetailView: LMFeedQnADetailFooterView.Type = LMFeedQnADetailFooterView.self
}
