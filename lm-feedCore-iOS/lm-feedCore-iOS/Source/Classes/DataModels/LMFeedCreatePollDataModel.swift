//
//  LMFeedCreatePollDataModel.swift
//  LikeMindsFeedCore
//
//  Created by Devansh Mohata on 08/06/24.
//

import Foundation

public struct LMFeedCreatePollDataModel {
    public enum MetaOptions: Int, CustomStringConvertible, CaseIterable {
        case isAnonymousPoll
        case isInstantPoll
        case allowAddOptions
        
        public var description: String {
            switch self {
            case .isAnonymousPoll:
                return "Anonymous poll"
            case .isInstantPoll:
                return "Don’t show live results"
            case .allowAddOptions:
                return "Allow voters to add options"
            }
        }
    }
    
    public enum OptionState: Int, CustomStringConvertible, CaseIterable {
        case exactly
        case atMax
        case atLeast
        
        public var description: String {
            switch self {
            case .exactly:
                return "Exactly"
            case .atMax:
                return "At max"
            case .atLeast:
                return "At least"
            }
        }
        
        public var apiKey: String {
            switch self {
            case .exactly:
                return "exactly"
            case .atMax:
                return "at_max"
            case .atLeast:
                return "at_least"
            }
        }
    }
    
    let pollQuestion: String
    let expiryTime: Date
    let pollOptions: [String]
    let isInstantPoll: Bool
    let selectState: OptionState
    let selectStateCount: Int
    let isAnonymous: Bool
    let allowAddOptions: Bool

    public init(
        pollQuestion: String,
        expiryTime: Date,
        pollOptions: [String],
        isInstantPoll: Bool,
        selectState: OptionState,
        selectStateCount: Int,
        isAnonymous: Bool,
        allowAddOptions: Bool
    ) {
        self.pollQuestion = pollQuestion
        self.expiryTime = expiryTime
        self.pollOptions = pollOptions
        self.isInstantPoll = isInstantPoll
        self.selectState = selectState
        self.selectStateCount = selectStateCount
        self.isAnonymous = isAnonymous
        self.allowAddOptions = allowAddOptions
    }
}
