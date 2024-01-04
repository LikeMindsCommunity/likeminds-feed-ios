//
//  LMFeedPostDetailCommentCellViewModel.swift
//  LMFramework
//
//  Created by Devansh Mohata on 18/12/23.
//

// MARK: LMChatPostCommentProtocol
public protocol LMChatPostCommentProtocol: AnyObject {
    func didTapUserName(for uuid: String)
    func didTapMenuButton(for commentId: String)
    func didTapLikeButton(for commentId: String, indexPath: IndexPath)
    func didTapLikeCountButton(for commentId: String)
    func didTapReplyButton(for commentId: String)
    func didTapReplyCountButton(for commentId: String)
}

public protocol LMFeedPostCommentCellProtocol { }

// MARK: LMFeedPostDetailCommentCellViewModel
public struct LMFeedPostDetailCommentCellViewModel: LMFeedPostCommentCellProtocol {
    let author: LMFeedUserDataModel
    let commentId: String?
    let tempCommentId: String?
    let comment: String
    let commentTime: String
    let isEdited: Bool
    var isLiked: Bool
    var likeCount: Int
    let totalReplyCount: Int
    var replies: [LMFeedPostDetailCommentCellViewModel]
    var isShowMore: Bool
    
    var authorName: String { author.userName }
    
    var repliesCount: Int { replies.count }
    
    var commentTimeFormatted: String {
        var time = ""
        if isEdited {
            time.append("Edited • ")
        }
        time.append(commentTime)
        return time
    }
    
    var likeText: String {
        likeCount > 1 ? "\(likeCount) \(Constants.shared.strings.likes)" : "\(likeCount) \(Constants.shared.strings.like)"
    }
    
    var commentText: String {
        totalReplyCount > 1 ? "\(totalReplyCount) \(Constants.shared.strings.replies)" : "\(totalReplyCount) \(Constants.shared.strings.reply)"
    }
    
    mutating func updateSelfLike() {
        isLiked.toggle()
        likeCount += isLiked ? 1 : -1
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
        isEdited: Bool = false,
        isLiked: Bool = false,
        isShowMore: Bool = false
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
