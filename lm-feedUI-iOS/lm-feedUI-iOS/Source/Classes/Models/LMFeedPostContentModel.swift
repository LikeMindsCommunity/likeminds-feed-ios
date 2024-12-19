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
         widget,
         topic,
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
    public var widgets: [LMFeedWidgetContentModel]
    public var isShowMoreDocuments: Bool
    public var linkPreview: LMFeedLinkPreview.ContentModel?
    public var mediaData: [LMFeedMediaProtocol]
    public var pollWidget: LMFeedDisplayPollView.ContentModel?
    public let topResponse: LMFeedCommentContentModel?
    public let aspectRatio: Double
    public let mediaHaveSameAspectRatio: Bool
    public let createdAt: String
    
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
        widgets: [LMFeedWidgetContentModel],
        linkPreview: LMFeedLinkPreview.ContentModel?,
        mediaData: [LMFeedMediaProtocol],
        pollWidget: LMFeedDisplayPollView.ContentModel?,
        isShowMore: Bool = true,
        isShowMoreDocuments: Bool = false,
        topResponse: LMFeedCommentContentModel?,
        mediaHaveSameAspectRatio: Bool,
        aspectRatio: Double,
        createdAt: String
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
        self.mediaHaveSameAspectRatio = mediaHaveSameAspectRatio
        self.aspectRatio = aspectRatio
        self.createdAt = createdAt
        self.widgets = widgets
    }
}


public class LMFeedWidgetContentModel{
    public let id: String?
    public let parentEntityID: String?
    public let parentEntityType: String?
    public let metadata: [String: Any]?
    public let createdAt: Double?
    public let updatedAt: Double?
    public let lmMeta: LMFeedLMMetaContentModel?

    public init(
        id: String?,
        parentEntityID: String?,
        parentEntityType: String?,
        metadata: [String: Any]?,
        createdAt: Double?,
        updatedAt: Double?,
        lmMeta: LMFeedLMMetaContentModel?
    ) {
        self.id = id
        self.parentEntityID = parentEntityID
        self.parentEntityType = parentEntityType
        self.metadata = metadata
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.lmMeta = lmMeta
    }
}

public class LMFeedLMMetaContentModel{
    public let options: [LMFeedPollOptionContentModel]
    public let pollAnswerText: String?
    public let isShowResult: Bool?
    public let voteCount: Int?
    
    public enum CodingKeys: String, CodingKey {
        case options
        case pollAnswerText = "poll_answer_text"
        case isShowResult = "to_show_results"
        case voteCount = "voters_count"
    }
    
    public init(options: [LMFeedPollOptionContentModel], pollAnswerText: String?, isShowResult: Bool?, voteCount: Int?) {
        self.options = options
        self.pollAnswerText = pollAnswerText
        self.isShowResult = isShowResult
        self.voteCount = voteCount
    }
}


public class LMFeedPollOptionContentModel{
    public let id: String?
    public let text: String?
    public let isSelected: Bool
    public let percentage: Double
    public let uuid: String?
    public let voteCount: Int
    
    public init(id: String?, text: String?, isSelected: Bool, percentage: Double, uuid: String?, voteCount: Int) {
        self.id = id
        self.text = text
        self.isSelected = isSelected
        self.percentage = percentage
        self.uuid = uuid
        self.voteCount = voteCount
    }
}
