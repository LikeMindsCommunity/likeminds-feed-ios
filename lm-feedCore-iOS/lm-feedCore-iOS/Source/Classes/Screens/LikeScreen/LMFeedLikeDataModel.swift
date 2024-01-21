//
//  LMFeedLikeDataModel.swift
//  lm-feedCore-iOS
//
//  Created by Devansh Mohata on 21/01/24.
//


public struct LMFeedLikeDataModel {
    public let username: String
    public let uuid: String
    public let customTitle: String?
    public let userImage: String?
    
    public init(username: String, uuid: String, customTitle: String?, userImage: String?) {
        self.username = username
        self.uuid = uuid
        self.customTitle = customTitle
        self.userImage = userImage
    }
}
