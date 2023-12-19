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
    func didTapLikeButton(for commentId: String)
    func didTapLikeCountButton(for commentId: String)
    func didTapReplyButton(for commentId: String)
    func didTapReplyCountButton(for commentId: String)
}

// MARK: LMFeedPostDetailCommentCellViewModel
public struct LMFeedPostDetailCommentCellViewModel: LMFeedPostTableCellProtocol {
    let author: UserProfile
    let postId: String
    let commentId: String?
    let tempCommentId: String?
    let comment: String
    let commentTime: String
    let isEdited: Bool
    let isLiked: Bool
    let likeCount: Int
    let totalReplyCount: Int
    let replies: [LMFeedPostDetailCommentCellViewModel]
    
    var authorName: String { author.name }
    
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
    
    var loadMoreComments: LMFeedPostMoreRepliesCell.ViewModel? {
        if repliesCount < totalReplyCount {
            return .init(parentCommentId: commentId, commentCount: repliesCount, totalComments: totalReplyCount)
        }
        return nil
    }
    
    public init(author: UserProfile, postId: String, commentId: String?, tempCommentId: String?, comment: String, commentTime: String, likeCount: Int, totalReplyCount: Int, replies: [LMFeedPostDetailCommentCellViewModel], isEdited: Bool = false, isLiked: Bool = false) {
        self.author = author
        self.postId = postId
        self.commentId = commentId
        self.tempCommentId = tempCommentId
        self.comment = comment
        self.commentTime = commentTime
        self.isEdited = isEdited
        self.isLiked = isLiked
        self.likeCount = likeCount
        self.totalReplyCount = totalReplyCount
        self.replies = replies
    }
    
    // MARK: UserProfile
    public struct UserProfile {
        let name: String
        let avatarURL: String
        let uuid: String
        
        public init(name: String, avatarURL: String, uuid: String) {
            self.name = name
            self.avatarURL = avatarURL
            self.uuid = uuid
        }
    }
}
