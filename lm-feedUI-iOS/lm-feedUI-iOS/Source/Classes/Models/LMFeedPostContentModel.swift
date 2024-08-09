//
//  LMFeedPostContentModel.swift
//  LikeMindsFeedUI
//
//  Created by Devansh Mohata on 20/07/24.
//


// MARK: LMFeedPostTableCellProtocol
public enum LMFeedPostType {
    case text,
         link,
         media,
         documents,
         poll,
         other
}

// MARK: LMFeedPostTableCellProtocol
public protocol LMFeedPostTableCellProtocol: Hashable {
    var postType: LMFeedPostType { get }
    var postID: String { get }
    var userUUID: String { get }
    var headerData: LMFeedPostHeaderView.ContentModel { get set }
    var postText: String { get }
    var isShowMore: Bool { get set }
    var topics: LMFeedTopicView.ContentModel { get }
    var footerData: LMFeedPostFooterView.ContentModel { get set }
    var totalCommentCount: Int { get set }
}


// MARK: LMFeedPostTableCellProtocol
public struct LMFeedPostContentModel: LMFeedPostTableCellProtocol {
    public var postType: LMFeedPostType
    public var postID: String
    public var userUUID: String
    public var headerData: LMFeedPostHeaderView.ContentModel
    public var postQuestion: String
    public var postText: String
    public var isShowMore: Bool
    public var topics: LMFeedTopicView.ContentModel
    public var footerData: LMFeedBasePostFooterView.ContentModel
    public var totalCommentCount: Int
    public var documents: [LMFeedDocumentPreview.ContentModel]
    public var isShowMoreDocuments: Bool
    public var linkPreview: LMFeedLinkPreview.ContentModel?
    public var mediaData: [LMFeedMediaProtocol]
    public var pollWidget: LMFeedDisplayPollView.ContentModel?
    public let topResponse: LMFeedCommentContentModel?
    
    public static func == (lhs: LMFeedPostContentModel, rhs: LMFeedPostContentModel) -> Bool {
        lhs.postID == rhs.postID
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(postID)
        hasher.combine(postQuestion)
        hasher.combine(postText)
        hasher.combine(totalCommentCount)
    }
    
    public init(
        postType: LMFeedPostType,
        postID: String,
        userUUID: String,
        headerData: LMFeedPostHeaderView.ContentModel,
        postQuestion: String,
        postText: String,
        topics: LMFeedTopicView.ContentModel,
        footerData: LMFeedBasePostFooterView.ContentModel,
        totalCommentCount: Int,
        documents: [LMFeedDocumentPreview.ContentModel],
        linkPreview: LMFeedLinkPreview.ContentModel?,
        mediaData: [LMFeedMediaProtocol],
        pollWidget: LMFeedDisplayPollView.ContentModel?,
        isShowMore: Bool = true,
        isShowMoreDocuments: Bool = false,
        topResponse: LMFeedCommentContentModel?
    ) {
        self.postType = postType
        self.postID = postID
        self.userUUID = userUUID
        self.headerData = headerData
        self.postQuestion = postQuestion
        self.postText = postText
        self.isShowMore = isShowMore
        self.topics = topics
        self.footerData = footerData
        self.totalCommentCount = totalCommentCount
        self.documents = documents
        self.isShowMoreDocuments = isShowMoreDocuments
        self.linkPreview = linkPreview
        self.mediaData = mediaData
        self.pollWidget = pollWidget
        self.topResponse = topResponse
    }
}
