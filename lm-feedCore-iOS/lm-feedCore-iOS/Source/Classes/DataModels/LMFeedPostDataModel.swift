//
//  LMFeedPostDataModel.swift
//  likeminds-feed-iOS
//
//  Created by Devansh Mohata on 28/12/23.
//

import LikeMindsFeedUI
import LikeMindsFeed

public struct LMFeedPostDataModel {
    public let postId: String
    public let postQuestion: String
    public let postContent: String
    public var likeCount: Int
    public var isLiked: Bool
    public var isPinned: Bool
    public var isSaved: Bool
    public var commentCount: Int
    public let createTime: String
    public var isEdited: Bool
    public var postMenu: [LMFeedMenuDataModel]
    public let userDetails: LMFeedUserModel
    public let topics: [LMFeedTopicDataModel]
    public var imageVideoAttachment: [ImageVideoAttachment] = []
    public var documentAttachment: [DocumentAttachment] = []
    public var linkAttachment: LinkAttachment?
    public var pollAttachment: LMFeedPollDataModel?
    public var isShowFullText: Bool
    public var isShowAllDocuments: Bool
    public let topResponse: LMFeedCommentDataModel?
    public let aspectRatio: Double
    public let mediaHaveSameAspectRatio: Bool
    
    public init(
        postId: String,
        postQuestion: String,
        postContent: String,
        likeCount: Int,
        isLiked: Bool,
        isPinned: Bool,
        isSaved: Bool,
        commentCount: Int,
        createTime: String,
        isEdited: Bool,
        postMenu: [LMFeedMenuDataModel],
        userDetails: LMFeedUserModel,
        topics: [LMFeedTopicDataModel],
        imageVideoAttachment: [LMFeedPostDataModel.ImageVideoAttachment] = [],
        documentAttachment: [LMFeedPostDataModel.DocumentAttachment] = [],
        linkAttachment: LMFeedPostDataModel.LinkAttachment? = .none,
        pollAttachment: LMFeedPollDataModel? = .none,
        isShowFullText: Bool = false,
        isShowAllDocuments: Bool = false,
        topResponse: LMFeedCommentDataModel?,
        aspectRatio: Double = 1.0,
        mediaHaveSameAspectRatio: Bool = false
    ) {
        self.postId = postId
        self.postQuestion = postQuestion
        self.postContent = postContent
        self.likeCount = likeCount
        self.isLiked = isLiked
        self.isPinned = isPinned
        self.isSaved = isSaved
        self.commentCount = commentCount
        self.createTime = createTime
        self.isEdited = isEdited
        self.postMenu = postMenu
        self.userDetails = userDetails
        self.topics = topics
        self.imageVideoAttachment = imageVideoAttachment
        self.documentAttachment = documentAttachment
        self.linkAttachment = linkAttachment
        self.pollAttachment = pollAttachment
        self.isShowFullText = isShowFullText
        self.isShowAllDocuments = isShowAllDocuments
        self.topResponse = topResponse
        self.mediaHaveSameAspectRatio = mediaHaveSameAspectRatio
        self.aspectRatio = aspectRatio
    }
}

extension LMFeedPostDataModel {
    init?(post: Post, users: [String: User], allTopics: [TopicFeedResponse.TopicResponse], widgets: [Widget], filteredComments: [String: Comment] = [:]) {
        guard let user = users[post.uuid ?? ""],
              let username = user.name,
              let userID = user.sdkClientInfo?.uuid,
              post.isDeleted != true else { return nil }
        
        self.postId = post.id
        self.postContent = post.text ?? ""
        self.postQuestion = post.heading ?? ""
        self.likeCount = post.likesCount ?? .zero
        self.isLiked = post.isLiked ?? false
        self.isPinned = post.isPinned ?? false
        self.isSaved = post.isSaved ?? false
        self.commentCount = post.commentsCount ?? .zero
        self.createTime = DateUtility.timeIntervalPostWidget(timeIntervalInMilliSeconds: post.createdAt ?? .zero)
        self.isEdited = post.isEdited ?? false
        self.userDetails = .init(userName: username, userUUID: userID, userProfileImage: user.imageUrl, customTitle: user.customTitle)
        self.isShowFullText = false
        self.isShowAllDocuments = false
        
        self.postMenu = post.menuItems?.compactMap {
            guard let state = LMFeedMenuDataModel.State(rawValue: $0.id),
                  let title = $0.title,
                  !title.isEmpty else { return nil }
            return .init(id: state, name: title)
        } ?? []
        
        self.topics = post.topics?.compactMap { topicID in
            guard let topic = allTopics.first(where: { $0.id == topicID }),
                  let name = topic.name else { return nil }
            return .init(topicName: name, topicID: topicID, isEnabled: topic.isEnabled ?? false)
        } ?? []
        
        self.topResponse = Self.fetchTopResponse(for: post, users: users, filteredComments: filteredComments)
        
        let aspectAttachment = post.attachments ?? []
        
        if aspectAttachment.isEmpty {
            self.mediaHaveSameAspectRatio = false
            self.aspectRatio = 1.0 // No attachments or empty array, default to aspect ratio 1
        }else{
            
            var commonAspectRatio: Double? = nil
            var allSameAspectRatio = true
            
            for attachment in aspectAttachment {
                // Get width and height, use 1 as the default value if nil
                let width = Double(attachment.attachmentMeta?.width ?? 1)
                let height = Double(attachment.attachmentMeta?.height ?? 1)
                
                // Calculate the aspect ratio
                let aspectRatio = width / height
                
                if let commonRatio = commonAspectRatio {
                    if aspectRatio != commonRatio {
                        allSameAspectRatio = false
                        commonAspectRatio = nil
                        break
                    }
                } else {
                    commonAspectRatio = aspectRatio
                }
            }
            
            self.mediaHaveSameAspectRatio = allSameAspectRatio
            self.aspectRatio = commonAspectRatio ?? 1
        }

        let attachments = handleAttachments(for: postId, attachments: post.attachments ?? [], widgets: widgets, users: users)
        self.imageVideoAttachment = attachments.images
        self.documentAttachment = attachments.docs
        self.linkAttachment = attachments.link
        self.pollAttachment = attachments.poll
        
    }
    
    public func checkAspectRatios(attachments: [Attachment]) -> (allSameAspectRatio: Bool, aspectRatio: Double) {
            guard !attachments.isEmpty else {
                return (false, 1.0) // No attachments or empty array, default to aspect ratio 1
            }
            
            var commonAspectRatio: Double? = nil
            var allSameAspectRatio = true
            
            for attachment in attachments {
                // Get width and height, use 1 as the default value if nil
                let width = Double(attachment.attachmentMeta?.width ?? 1)
                let height = Double(attachment.attachmentMeta?.height ?? 1)
                
                // Calculate the aspect ratio
                let aspectRatio = width / height
                
                if let commonRatio = commonAspectRatio {
                    if aspectRatio != commonRatio {
                        allSameAspectRatio = false
                        break
                    }
                } else {
                    commonAspectRatio = aspectRatio
                }
            }
            
            return (allSameAspectRatio, commonAspectRatio ?? 1.0)
        }
    
    func handleAttachments(for postID: String, attachments: [Attachment], widgets: [Widget], users: [String: User]) -> (images: [ImageVideoAttachment], docs: [DocumentAttachment], link: LinkAttachment?, poll: LMFeedPollDataModel?) {
        var tempImageVideoAttachment: [ImageVideoAttachment] = []
        var tempDocumentAttachment: [DocumentAttachment] = []
        var tempLinkAttachment: LinkAttachment?
        var poll: LMFeedPollDataModel?
        
        attachments.forEach { attachment in
            if let type = attachment.attachmentType {
                switch type {
                case .image, .video:
                    if let url = attachment.attachmentMeta?.attachmentUrl {
                        tempImageVideoAttachment.append(.init(
                            name: attachment.attachmentMeta?.name ?? "",
                            url: url,
                            isVideo: type == .video,
                            size: attachment.attachmentMeta?.size ?? 0,
                            duration: attachment.attachmentMeta?.duration,height: attachment.attachmentMeta?.height, width: attachment.attachmentMeta?.width
                        ))
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
                case .poll:
                    poll = .init(postID: postID, users: users, widgets: widgets)
                default:
                    break
                }
            }
        }
        
        return (tempImageVideoAttachment, tempDocumentAttachment, tempLinkAttachment, poll)
    }
    
    static func fetchTopResponse(for post: Post, users: [String: User], filteredComments: [String: Comment]) -> LMFeedCommentDataModel? {
        guard let commentID = post.filteredComments?.first,
              let filteredComment = filteredComments[commentID],
              let user = users[filteredComment.uuid ?? ""] else { return nil }
        
        return LMFeedCommentDataModel.init(comment: filteredComment, user: user)
    }
}


// MARK: LMFeedPostDataModel+ImageVideoAttachment
public extension LMFeedPostDataModel {
    struct ImageVideoAttachment {
        public let name: String
        public let url: String
        public let isVideo: Bool
        public let size: Int
        public let duration: Int?
        public let width: Int?
        public let height: Int?
        
        public init(name: String, url: String, isVideo: Bool, size: Int, duration: Int?, height: Int?, width: Int?) {
            self.name = name
            self.url = url
            self.isVideo = isVideo
            self.size = size
            self.duration = duration
            self.height = height
            self.width = width
        }
    }
}


// MARK: LMFeedPostDataModel+DocumentAttachment
public extension LMFeedPostDataModel {
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


// MARK: LMFeedPostDataModel+LinkAttachment
public extension LMFeedPostDataModel {
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


public extension LMFeedPostDataModel {
    func getPostType() -> String {
        if self.linkAttachment != nil {
            return "link"
        } else if !self.documentAttachment.isEmpty {
            return "document"
        } else if self.imageVideoAttachment.isEmpty {
            return "text"
        }
        
        return self.imageVideoAttachment.first?.isVideo == true ? "video" : "image"
    }
}
