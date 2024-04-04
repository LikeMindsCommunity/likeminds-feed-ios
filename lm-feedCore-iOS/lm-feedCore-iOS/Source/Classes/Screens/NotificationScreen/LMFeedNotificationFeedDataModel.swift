//
//  LMFeedNotificationFeedDataModel.swift
//  lm-feedCore-iOS
//
//  Created by Devansh Mohata on 21/01/24.
//

import LikeMindsFeedUI

public struct LMFeedNotificationFeedDataModel {
    public enum AttachmentType {
        case image,
             video,
             document,
             none
        
        public var imageIcon: String? {
            switch self {
            case .image, .video:
                return "photo"
            case .document:
                return "doc.fill"
            case .none:
                return nil
            }
        }
    }
    
    public let id: String
    public let activityText: String
    public let cta: String
    public let createdAt: Int
    public let attachmentType: AttachmentType
    public var isRead: Bool
    public let user: LMFeedUserDataModel
    
    public init(id: String, activityText: String, cta: String, createdAt: Int, attachmentType: AttachmentType, isRead: Bool, user: LMFeedUserDataModel) {
        self.id = id
        self.activityText = activityText
        self.cta = cta
        self.createdAt = createdAt
        self.attachmentType = attachmentType
        self.isRead = isRead
        self.user = user
    }
}
