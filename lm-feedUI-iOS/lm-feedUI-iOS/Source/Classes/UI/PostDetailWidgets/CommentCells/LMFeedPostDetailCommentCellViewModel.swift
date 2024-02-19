//
//  LMFeedPostDetailCommentCellViewModel.swift
//  LMFramework
//
//  Created by Devansh Mohata on 18/12/23.
//

// MARK: LMChatPostCommentProtocol
public protocol LMChatPostCommentProtocol: AnyObject {
    func didTapUserName(for uuid: String)
    func didTapCommentMenuButton(for commentId: String)
    func didTapLikeButton(for commentId: String, indexPath: IndexPath)
    func didTapLikeCountButton(for commentId: String)
    func didTapReplyButton(for commentId: String)
    func didTapReplyCountButton(for commentId: String)
    func didTapURL(url: URL)
}

// MARK: LMFeedPostDetailCommentCellViewModel
public struct LMFeedPostDetailCommentCellViewModel {
    public let author: LMFeedUserDataModel
    public let commentId: String?
    public let tempCommentId: String?
    public let comment: String
    public let commentTime: String
    public let isEdited: Bool
    public var isLiked: Bool
    public var likeCount: Int
    public let totalReplyCount: Int
    public var replies: [LMFeedPostDetailCommentCellViewModel]
    public var isShowMore: Bool
    
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
        likeCount > 1 ? "\(likeCount) \(Constants.shared.strings.likes)" : "\(likeCount) \(Constants.shared.strings.like)"
    }
    
    public var commentText: String {
        "• \(totalReplyCount) \(totalReplyCount > 1 ? Constants.shared.strings.replies : Constants.shared.strings.reply)"
    }
    
    
    public init(
        author: LMFeedUserDataModel,
        commentId: String?,
        tempCommentId: String?,
        comment: String,
        commentTime: String,
        likeCount: Int,
        totalReplyCount: Int,
        replies: [LMFeedPostDetailCommentCellViewModel],
        isEdited: Bool,
        isLiked: Bool,
        isShowMore: Bool = true
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
    }
}
