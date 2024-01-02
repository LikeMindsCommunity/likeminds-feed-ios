//
//  LMUniversalFeedDataModel.swift
//  likeminds-feed-iOS
//
//  Created by Devansh Mohata on 28/12/23.
//

import LikeMindsFeed

public struct LMUniversalFeedDataModel {
    public let postId: String
    public let postContent: String
    public var likeCount: Int
    public var isLiked: Bool
    public var isPinned: Bool
    public var isSaved: Bool
    public let commentCount: Int
    public let createTime: String
    public let isEdited: Bool
    public let postMenu: [MenuItem]
    public let userName: String
    public let userUUID: String
    public let userImage: String?
    public let userCustomTitle: String?
    public let topics: [TopicModel]
    public var imageVideoAttachment: [ImageVideoAttachment] = []
    public var documentAttachment: [DocumentAttachment] = []
    public var linkAttachment: LinkAttachment? = .none
    public var isShowFullText: Bool
    public var isShowAllDocuments: Bool
    
    public init(
        postId: String,
        postContent: String,
        likeCount: Int,
        isLiked: Bool,
        isPinned: Bool,
        isSaved: Bool,
        commentCount: Int,
        createTime: String,
        isEdited: Bool,
        postMenu: [LMUniversalFeedDataModel.MenuItem],
        userName: String,
        userUUID: String,
        userImage: String? = nil,
        userCustomTitle: String? = nil,
        topics: [LMUniversalFeedDataModel.TopicModel],
        imageVideoAttachment: [LMUniversalFeedDataModel.ImageVideoAttachment] = [],
        documentAttachment: [LMUniversalFeedDataModel.DocumentAttachment] = [],
        linkAttachment: LMUniversalFeedDataModel.LinkAttachment? = .none, 
        isShowFullText: Bool = false,
        isShowAllDocuments: Bool = false
    ) {
        self.postId = postId
        self.postContent = postContent
        self.likeCount = likeCount
        self.isLiked = isLiked
        self.isPinned = isPinned
        self.isSaved = isSaved
        self.commentCount = commentCount
        self.createTime = createTime
        self.isEdited = isEdited
        self.postMenu = postMenu
        self.userName = userName
        self.userUUID = userUUID
        self.userImage = userImage
        self.userCustomTitle = userCustomTitle
        self.topics = topics
        self.imageVideoAttachment = imageVideoAttachment
        self.documentAttachment = documentAttachment
        self.linkAttachment = linkAttachment
        self.isShowFullText = isShowFullText
        self.isShowAllDocuments = isShowAllDocuments
    }
}


// MARK: LMUniversalFeedDataModel+MenuItem
public extension LMUniversalFeedDataModel {
    struct MenuItem {
        public enum State: Int {
            case deletePost = 1
            case pinPost
            case unpinPost
            case reportPost
            case editPost
            case deleteComment
            case reportComment
            case editComment
        }
        
        public let id: State
        public let name: String
        
        public init(id: LMUniversalFeedDataModel.MenuItem.State, name: String) {
            self.id = id
            self.name = name
        }
    }
}


// MARK: LMUniversalFeedDataModel+ImageVideoAttachment
public extension LMUniversalFeedDataModel {
    struct ImageVideoAttachment {
        public let name: String
        public let url: String
        public let isVideo: Bool
        
        public init(name: String, url: String, isVideo: Bool) {
            self.name = name
            self.url = url
            self.isVideo = isVideo
        }
    }
}


// MARK: LMUniversalFeedDataModel+DocumentAttachment
public extension LMUniversalFeedDataModel {
    struct DocumentAttachment {
        public let url: String
        public let name: String
        public let format: String?
        public let size: Int?
        public let pageCount: Int?
        
        public init(url: String, name: String, format: String? = nil, size: Int? = nil, pageCount: Int? = nil) {
            self.url = url
            self.name = name
            self.format = format
            self.size = size
            self.pageCount = pageCount
        }
    }
}


// MARK: LMUniversalFeedDataModel+LinkAttachment
public extension LMUniversalFeedDataModel {
    struct LinkAttachment {
        public let url: String
        public let title: String?
        public let description: String?
        public let previewImage: String?
        
        public init(url: String, title: String? = nil, description: String? = nil, previewImage: String? = nil) {
            self.url = url
            self.title = title
            self.description = description
            self.previewImage = previewImage
        }
    }
}


// MARK: LMUniversalFeedDataModel+TopicModel
public extension LMUniversalFeedDataModel {
    struct TopicModel {
        public let topicId: String
        public let topic: String
        
        public init(topicId: String, topic: String) {
            self.topicId = topicId
            self.topic = topic
        }
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
