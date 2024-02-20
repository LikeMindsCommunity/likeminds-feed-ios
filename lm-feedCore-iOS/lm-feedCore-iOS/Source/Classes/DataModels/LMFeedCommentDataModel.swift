//
//  LMFeedCommentDataModel.swift
//  likeminds-feed-iOS
//
//  Created by Devansh Mohata on 03/01/24.
//

import LikeMindsFeedUI
import LikeMindsFeed

public struct LMFeedCommentDataModel {
    public let commentID: String?
    public let userDetail: LMFeedUserDataModel
    public var temporaryCommentID: String?
    public var createdAt: Int
    public var isLiked: Bool
    public var likeCount: Int
    public var isEdited: Bool
    public var commentText: String
    public let menuItems: [LMFeedMenuDataModel]
    public var totalRepliesCount: Int
    public var replies: [LMFeedCommentDataModel] = []
    
    public var createdAtFormatted: String {
        DateUtility.timeIntervalPostWidget(timeIntervalInMilliSeconds: createdAt)
    }
}

public extension LMFeedCommentDataModel {
    init?(comment: LikeMindsFeed.Comment, user: LikeMindsFeed.User) {
        guard let commentID = comment.id,
              let userUUID = user.sdkClientInfo?.uuid,
              let userName = user.name,
              let commentText = comment.text?.trimmingCharacters(in: .whitespacesAndNewlines),
        !commentText.isEmpty else { return nil }
        
        self.commentID = commentID
        self.userDetail = .init(userName: userName, userUUID: userUUID, userProfileImage: user.imageUrl, customTitle: user.customTitle)
        self.temporaryCommentID = comment.tempId
        self.createdAt = comment.createdAt ?? 0
        self.isLiked = comment.isLiked ?? false
        self.likeCount = comment.likesCount ?? .zero
        self.isEdited = comment.isEdited ?? false
        self.commentText = commentText
        self.totalRepliesCount = comment.commentsCount ?? 0
        self.menuItems = comment.menuItems?.compactMap { menu in
            guard let state = LMFeedMenuDataModel.State(rawValue: menu.id),
                let name = menu.title,
                  !name.isEmpty else { return nil }
            return .init(id: state, name: name)
        } ?? []
    }
}
