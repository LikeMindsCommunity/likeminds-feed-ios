//
//  LMFeedConvertToFeedPost.swift
//  likeminds-feed-iOS
//
//  Created by Devansh Mohata on 03/01/24.
//

import LikeMindsFeed

public struct LMFeedConvertToFeedPost {
    public static func convertToViewModel(for post: LMFeedPostDataModel) -> LMFeedPostTableCellProtocol {
        if let link = post.linkAttachment {
            return convertToLinkViewData(from: post, link: link)
        } else if !post.documentAttachment.isEmpty {
            return convertToDocumentCells(from: post)
        } else {
            return convertToImageVideoCells(from: post)
        }
    }
    
    private static func convertToTopicViewData(from topics: [LMFeedPostDataModel.TopicModel]) -> LMFeedTopicView.ViewModel {
        let mappedTopics: [LMFeedTopicCollectionCellDataModel] = topics.map {
            .init(topic: $0.topic, topicID: $0.topicId)
        }
        
        return .init(topics: mappedTopics)
    }
    
    private static func convertToHeaderViewData(from data: LMFeedPostDataModel) -> LMFeedPostHeaderView.ViewModel {
        .init(
            profileImage: data.userDetails.userProfileImage,
            authorName: data.userDetails.userName,
            authorTag: data.userDetails.customTitle,
            subtitle: "\(data.createTime)\(data.isEdited ? " • Edited" : "")",
            isPinned: data.isPinned,
            showMenu: !data.postMenu.isEmpty
        )
    }
    
    private static func convertToFooterViewData(from data: LMFeedPostDataModel) -> LMFeedPostFooterView.ViewModel {
        .init(likeCount: data.likeCount, commentCount: data.commentCount, isSaved: data.isSaved, isLiked: data.isLiked)
    }
    
    private static func convertToLinkViewData(from data: LMFeedPostDataModel, link: LMFeedPostDataModel.LinkAttachment) -> LMFeedPostLinkCell.ViewModel {
        .init(
            postID: data.postId,
            userUUID: data.userDetails.userUUID,
            headerData: convertToHeaderViewData(from: data),
            postText: data.postContent,
            topics: convertToTopicViewData(from: data.topics),
            mediaData: .init(linkPreview: link.previewImage, title: link.title, description: link.description, url: link.url),
            footerData: convertToFooterViewData(from: data)
        )
    }
    
    private static func convertToDocumentCells(from data: LMFeedPostDataModel) -> LMFeedPostDocumentCell.ViewModel {
        func convertToDocument(from data: [LMFeedPostDataModel.DocumentAttachment]) -> [LMFeedPostDocumentCellView.ViewModel] {
            data.map { datum in
                    .init(title: datum.name, documentURL: datum.url, size: datum.size, pageCount: datum.pageCount, docType: datum.format)
            }
        }
        
        return .init(
            postID: data.postId,
            userUUID: data.userDetails.userUUID,
            headerData: convertToHeaderViewData(from: data),
            topics: convertToTopicViewData(from: data.topics),
            postText: data.postContent,
            documents: convertToDocument(from: data.documentAttachment),
            footerData: convertToFooterViewData(from: data)
        )
    }
    
    private static func convertToImageVideoCells(from data: LMFeedPostDataModel) -> LMFeedPostMediaCell.ViewModel {
        func convertToMediaProtocol(from data: [LMFeedPostDataModel.ImageVideoAttachment]) -> [LMFeedMediaProtocol] {
            data.map { datum in
                if datum.isVideo {
                    return LMFeedPostVideoCollectionCell.ViewModel(videoURL: datum.url)
                } else {
                    return LMFeedPostImageCollectionCell.ViewModel(image: datum.url)
                }
            }
        }
        
        return .init(
            postID: data.postId,
            userUUID: data.userDetails.userUUID,
            headerData: convertToHeaderViewData(from: data),
            postText: data.postContent,
            topics: convertToTopicViewData(from: data.topics),
            mediaData: convertToMediaProtocol(from: data.imageVideoAttachment),
            footerData: convertToFooterViewData(from: data)
        )
    }
}
