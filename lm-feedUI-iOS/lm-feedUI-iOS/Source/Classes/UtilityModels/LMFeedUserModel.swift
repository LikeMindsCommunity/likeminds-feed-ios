//
//  LMFeedUserModel.swift
//  LMFramework
//
//  Created by Devansh Mohata on 05/01/24.
//

import Foundation

public struct LMFeedUserModel {
    public let userName: String
    public let userUUID: String
    public let userProfileImage: String?
    public let customTitle: String?
    
    public init(userName: String, userUUID: String, userProfileImage: String? = nil, customTitle: String? = nil) {
        self.userName = userName
        self.userUUID = userUUID
        self.userProfileImage = userProfileImage
        self.customTitle = customTitle
    }
}
