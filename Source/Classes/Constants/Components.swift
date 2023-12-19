//
//  Components.swift
//  LMFramework
//
//  Created by Devansh Mohata on 28/11/23.
//

import UIKit

public struct Components {
    public static var shared = Self()
    
    public var feedListViewController: LMUniversalFeedViewController.Type = LMUniversalFeedViewController.self
    public var postCell: LMFeedPostMediaCell.Type = LMFeedPostMediaCell.self
    public var documentCell: LMFeedPostDocumentCell.Type = LMFeedPostDocumentCell.self
    public var linkCell: LMFeedPostLinkCell.Type = LMFeedPostLinkCell.self
    public var headerCell: LMFeedPostHeaderView.Type = LMFeedPostHeaderView.self
    public var footerCell: LMFeedPostFooterView.Type = LMFeedPostFooterView.self
    public var imageCollectionCell: LMFeedPostImageCollectionCell.Type = LMFeedPostImageCollectionCell.self
    public var videoCollectionCell: LMFeedPostVideoCollectionCell.Type = LMFeedPostVideoCollectionCell.self
    public var commentHeaderView: LMFeedPostDetailCommentHeaderView.Type = LMFeedPostDetailCommentHeaderView.self
    public var commentCell: LMFeedPostDetailCommentCell.Type = LMFeedPostDetailCommentCell.self
    public var totalCommentCell: LMFeedPostDetailTotalCommentCell.Type = LMFeedPostDetailTotalCommentCell.self
    public var postDetailScreen: LMFeedPostDetailViewController.Type = LMFeedPostDetailViewController.self
    public var loadMoreReplies: LMFeedPostMoreRepliesCell.Type = LMFeedPostMoreRepliesCell.self
}
