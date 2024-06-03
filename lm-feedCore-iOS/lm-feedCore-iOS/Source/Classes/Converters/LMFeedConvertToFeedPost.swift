//
//  LMFeedConvertToFeedPost.swift
//  likeminds-feed-iOS
//
//  Created by Devansh Mohata on 03/01/24.
//

import LikeMindsFeedUI
import LikeMindsFeed

public struct LMFeedConvertToFeedPost {
    public static func convertToViewModel(for post: LMFeedPostDataModel) -> LMFeedPostContentModel {
        
        let documents = convertToDocument(from: post.documentAttachment)
        let media = convertToMediaProtocol(from: post.imageVideoAttachment)
        var linkPreview: LMFeedLinkPreview.ContentModel?
        
        if let link = post.linkAttachment {
            linkPreview = .init(linkPreview: link.previewImage, title: link.title, description: link.description, url: link.url)
        }
        
        var postType = LMFeedPostType.text
        
        if !media.isEmpty {
            postType = .media
        } else if !documents.isEmpty {
            postType = .documents
        } else if linkPreview != nil {
            postType = .link
        } else {
            // Custom Widgets and Poll
        }
        
        return .init(
            postType: postType,
            postID: post.postId,
            userUUID: post.userDetails.userUUID,
            headerData: convertToHeaderViewData(from: post),
            postText: post.postContent,
            topics: convertToTopicViewData(from: post.topics),
            footerData: convertToFooterViewData(from: post),
            totalCommentCount: post.commentCount,
            documents: documents,
            linkPreview: linkPreview,
            mediaData: media
        )
    }
    
    private static func convertToTopicViewData(from topics: [LMFeedTopicDataModel]) -> LMFeedTopicView.ContentModel {
        let mappedTopics: [LMFeedTopicCollectionCellDataModel] = topics.map {
            .init(topic: $0.topicName, topicID: $0.topicID)
        }
        
        return .init(topics: mappedTopics)
    }
    
    public static func convertToHeaderViewData(from data: LMFeedPostDataModel) -> LMFeedPostHeaderView.ContentModel {
        .init(
            profileImage: data.userDetails.userProfileImage,
            authorName: data.userDetails.userName,
            authorTag: data.userDetails.customTitle,
            subtitle: "\(data.createTime)\(data.isEdited ? " • Edited" : "")",
            isPinned: data.isPinned,
            showMenu: !data.postMenu.isEmpty
        )
    }
    
    public static func convertToFooterViewData(from data: LMFeedPostDataModel) -> LMFeedPostFooterView.ContentModel {
        .init(likeCount: data.likeCount, commentCount: data.commentCount, isSaved: data.isSaved, isLiked: data.isLiked)
    }
    
    public static func convertToDocument(from data: [LMFeedPostDataModel.DocumentAttachment]) -> [LMFeedDocumentPreview.ContentModel] {
        data.compactMap { datum in
            guard let url = URL(string: datum.url) else { return nil }
            
            return .init(
                title: datum.name,
                documentURL: url,
                size: datum.size,
                pageCount: datum.pageCount,
                docType: datum.format
            )
        }
    }
    
    public static func convertToMediaProtocol(from data: [LMFeedPostDataModel.ImageVideoAttachment]) -> [LMFeedMediaProtocol] {
        data.map { datum in
            if datum.isVideo {
                return LMFeedVideoCollectionCell.ContentModel(videoURL: datum.url)
            } else {
                return LMFeedImageCollectionCell.ContentModel(image: datum.url)
            }
        }
    }
    
    public static func convertToCommentModel(for comments: [LMFeedCommentDataModel]) -> [LMFeedCommentContentModel] {
        comments.enumerated().map { index, comment in
            return convertToCommentModel(from: comment)
        }
    }
    
    public static func convertToCommentModel(from comment: LMFeedCommentDataModel) -> LMFeedCommentContentModel {
        var replies: [LMFeedCommentContentModel] = []
        
        comment.replies.forEach { reply in
            replies.append(convertToCommentModel(from: reply))
        }
        
        return .init(
            author: convertToUserModel(from: comment.userDetail),
            commentId: comment.commentID,
            tempCommentId: comment.temporaryCommentID,
            comment: comment.commentText,
            commentTime: comment.createdAtFormatted,
            likeCount: comment.likeCount,
            totalReplyCount: comment.totalRepliesCount,
            replies: replies,
            isEdited: comment.isEdited,
            isLiked: comment.isLiked
        )
    }
    
    public static func convertToUserModel(from user: LMFeedUserDataModel) -> LMFeedUserModel {
        .init(userName: user.userName, userUUID: user.userUUID, userProfileImage: user.userProfileImage, customTitle: user.customTitle)
    }
}
