//
//  LMUniversalFeedDataModel.swift
//  likeminds-feed-iOS
//
//  Created by Devansh Mohata on 28/12/23.
//

import LikeMindsFeed

public struct LMUniversalFeedDataModel {
    let postId: String
    let postContent: String
    var likeCount: Int
    var isLiked: Bool
    let isPinned: Bool
    let isSaved: Bool
    let commentCount: Int
    let createTime: String
    let isEdited: Bool
    let postMenu: [MenuItem]
    let userName: String
    let userUUID: String
    let userImage: String?
    let userCustomTitle: String?
    let topics: [TopicModel]
    var imageVideoAttachment: [ImageVideoAttachment] = []
    var documentAttachment: [DocumentAttachment] = []
    var linkAttachment: LinkAttachment? = .none
    var isShowFullText: Bool
    var isShowAllDocuments: Bool
    
    struct MenuItem {
        enum State: Int {
            case deletePost = 1
            case pinPost
            case unpinPost
            case reportPost
            case editPost
            case deleteComment
            case reportComment
            case editComment
        }
        
        let id: State
        let name: String
    }
    
    struct ImageVideoAttachment {
        let name: String
        let url: String
        let isVideo: Bool
    }
    
    struct DocumentAttachment {
        let url: String
        let name: String
        let format: String?
        let size: Int?
        let pageCount: Int?
    }
    
    struct LinkAttachment {
        let url: String
        let title: String?
        let description: String?
        let previewImage: String?
    }
    
    struct TopicModel {
        let topicId: String
        let topic: String
    }
}

extension LMUniversalFeedDataModel {
    init?(post: Post, user: User, allTopics: [TopicFeedResponse.TopicResponse]) {
        guard let username = user.name,
              let userID = user.uuid,
              post.isDeleted != true else { return nil }
        
        self.postId = post.id
        self.postContent = post.text ?? ""
        self.likeCount = post.likesCount ?? .zero
        self.isLiked = post.isLiked ?? false
        self.isPinned = post.isPinned ?? false
        self.isSaved = post.isSaved ?? false
        self.commentCount = post.commentsCount ?? .zero
        self.createTime = DateUtility.timeIntervalPostWidget(timeIntervalInMilliSeconds: post.createdAt ?? .zero)
        self.isEdited = post.isEdited ?? false
        self.userName = username
        self.userUUID = userID
        self.userImage = user.imageUrl
        self.userCustomTitle = user.customTitle
        self.isShowFullText = false
        self.isShowAllDocuments = false
        
        self.postMenu = post.menuItems?.compactMap {
            guard let state = MenuItem.State(rawValue: $0.id),
                  let title = $0.title,
                  !title.isEmpty else { return nil }
            return .init(id: state, name: title)
        } ?? []
        
        self.topics = post.topics?.compactMap { topicID in
            guard let topic = allTopics.first(where: { $0.id == topicID }),
                  let name = topic.name else { return nil }
            return .init(topicId: topicID, topic: name)
        } ?? []
        
        let attachments = handleAttachments(with: post.attachments ?? [])
        self.imageVideoAttachment = attachments.images
        self.documentAttachment = attachments.docs
        self.linkAttachment = attachments.link
    }
    
    func handleAttachments(with attachments: [Attachment]) -> (images: [ImageVideoAttachment], docs: [DocumentAttachment], link: LinkAttachment?) {
        var tempImageVideoAttachment: [ImageVideoAttachment] = []
        var tempDocumentAttachment: [DocumentAttachment] = []
        var tempLinkAttachment: LinkAttachment?
        
        attachments.forEach { attachment in
            if let type = attachment.attachmentType {
                switch type {
                case .image, .video:
                    if let url = attachment.attachmentMeta?.attachmentUrl {
                        tempImageVideoAttachment.append(.init(name: attachment.attachmentMeta?.name ?? "", url: url, isVideo: type == .video))
                    }
                case .doc:
                    if let url = attachment.attachmentMeta?.attachmentUrl {
                        let name = attachment.attachmentMeta?.name ?? "Unnamed Document"
                        tempDocumentAttachment.append(.init(url: url, name: name, format: attachment.attachmentMeta?.format, size: attachment.attachmentMeta?.size, pageCount: attachment.attachmentMeta?.pageCount))
                    }
                case .link:
                    if let url = attachment.attachmentMeta?.ogTags?.url {
                        tempLinkAttachment = .init(url: url, title: attachment.attachmentMeta?.ogTags?.title, description: attachment.attachmentMeta?.ogTags?.description, previewImage: attachment.attachmentMeta?.ogTags?.image)
                    }
                default:
                    break
                }
            }
        }
        
        return (tempImageVideoAttachment, tempDocumentAttachment, tempLinkAttachment)
    }
}
