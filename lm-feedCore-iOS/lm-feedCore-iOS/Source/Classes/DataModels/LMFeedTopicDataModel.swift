//
//  LMFeedTopicDataModel.swift
//  lm-feedCore-iOS
//
//  Created by Devansh Mohata on 17/02/24.
//

import Foundation

public struct LMFeedTopicDataModel {
    public let topicName: String
    public let topicID: String
    public let isEnabled: Bool
    
    public init(topicName: String, topicID: String, isEnabled: Bool) {
        self.topicName = topicName
        self.topicID = topicID
        self.isEnabled = isEnabled
    }
}
