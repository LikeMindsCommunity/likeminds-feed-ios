//
//  LMFeedCommentContentModel.swift
//  LMFramework
//
//  Created by Devansh Mohata on 18/12/23.
//


// MARK: LMFeedPostCommentProtocol
public protocol LMFeedPostCommentProtocol: AnyObject {
    func didTapUserName(for uuid: String)
    func didTapCommentMenuButton(for commentId: String)
    func didTapLikeButton(for commentId: String, indexPath: IndexPath)
    func didTapLikeCountButton(for commentId: String)
    func didTapReplyButton(for commentId: String)
    func didTapReplyCountButton(for commentId: String)
    func didTapURL(url: URL)
}

// MARK: LMFeedCommentViewModel
public struct LMFeedCommentContentModel: Hashable {
    public let author: LMFeedUserModel
    public let commentId: String?
    public let tempCommentId: String?
    public let comment: String
    public let commentTime: String
    public let isEdited: Bool
    public var isLiked: Bool
    public var likeCount: Int
    public let totalReplyCount: Int
    public var replies: [LMFeedCommentContentModel]
    public var isShowMore: Bool
    public var likeKeyword: String
    
    public var authorName: String { author.userName }
    
    public var repliesCount: Int { replies.count }
    
    public var commentTimeFormatted: String {
        var time = ""
        if isEdited {
            time.append("Edited • ")
        }
        time.append(commentTime)
        return time
    }
    
    public var likeText: String {
        "\(likeCount) \(likeKeyword.pluralize(count: likeCount))"
    }
    
    public var commentText: String {
        "• \(totalReplyCount) \(totalReplyCount > 1 ? LMFeedConstants.shared.strings.replies : LMFeedConstants.shared.strings.reply)"
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(commentId)
        hasher.combine(comment)
        hasher.combine(replies)
    }
    
    public static func == (lhs: LMFeedCommentContentModel, rhs: LMFeedCommentContentModel) -> Bool {
        lhs.commentId == rhs.commentId
    }
    
    public init(
        author: LMFeedUserModel,
        commentId: String?,
        tempCommentId: String?,
        comment: String,
        commentTime: String,
        likeCount: Int,
        totalReplyCount: Int,
        replies: [LMFeedCommentContentModel],
        isEdited: Bool,
        isLiked: Bool,
        isShowMore: Bool = true,
        likeKeyword: String
    ) {
        self.author = author
        self.commentId = commentId
        self.tempCommentId = tempCommentId
        self.comment = comment
        self.commentTime = commentTime
        self.isEdited = isEdited
        self.isLiked = isLiked
        self.likeCount = likeCount
        self.totalReplyCount = totalReplyCount
        self.replies = replies
        self.isShowMore = isShowMore
        self.likeKeyword = likeKeyword
    }
}
