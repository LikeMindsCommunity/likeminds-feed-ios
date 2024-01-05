//
//  LMFeedMenuDataModel.swift
//  likeminds-feed-iOS
//
//  Created by Devansh Mohata on 03/01/24.
//

import UIKit

public struct LMFeedMenuDataModel {
    public enum State: Int {
        case deletePost = 1
        case pinPost
        case unpinPost
        case reportPost
        case editPost
        case deleteComment
        case reportComment
        case editComment
    }
    
    public let id: State
    public let name: String
    
    public init(id: State, name: String) {
        self.id = id
        self.name = name
    }
}
