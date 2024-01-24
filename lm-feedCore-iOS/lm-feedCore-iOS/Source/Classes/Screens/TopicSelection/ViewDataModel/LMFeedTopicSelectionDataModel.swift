//
//  LMFeedTopicSelectionDataModel.swift
//  likeminds-feed-iOS
//
//  Created by Devansh Mohata on 02/01/24.
//

public struct LMFeedTopicSelectionDataModel {
    public var topicID: String
    public var topicName: String
    
    public init(topicID: String, topicName: String) {
        self.topicID = topicID
        self.topicName = topicName
    }
}
