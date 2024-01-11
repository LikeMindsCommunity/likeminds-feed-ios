//
//  LMFeedTagListDataModel.swift
//  lm-feedCore-iOS
//
//  Created by Devansh Mohata on 11/01/24.
//

import LikeMindsFeed

public struct LMFeedTagListDataModel {
    public let userImage: String?
    public let username: String
    public let uuid: String
    public let route: String
    
    public init(userImage: String?, username: String, uuid: String, route: String) {
        self.userImage = userImage
        self.username = username
        self.uuid = uuid
        self.route = route
    }
}

public extension LMFeedTagListDataModel {
    init?(from user: User) {
        guard let username = user.name,
                let uuid = user.sdkClientInfo?.uuid,
                let route = user.route else { return nil }
        
        self.username = username
        self.uuid = uuid
        self.route = route
        self.userImage = user.imageUrl
    }
}
