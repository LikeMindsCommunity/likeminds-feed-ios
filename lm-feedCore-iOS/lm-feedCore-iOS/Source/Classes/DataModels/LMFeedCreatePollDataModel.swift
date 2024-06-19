//
//  LMFeedCreatePollDataModel.swift
//  LikeMindsFeedCore
//
//  Created by Devansh Mohata on 08/06/24.
//

import Foundation

public enum LMFeedPollSelectState: Int, CustomStringConvertible, CaseIterable {
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
    
    public func checkValidity(with count: Int, allowedCount: Int) -> Bool {
        switch self {
        case .exactly:
            return count == allowedCount
        case .atMax:
            return count <= allowedCount
        case .atLeast:
            return count >= allowedCount
        }
    }
}

extension LMFeedPollSelectState {
    init?(key: String) {
        guard let type = LMFeedPollSelectState.allCases.first(where: { $0.apiKey == key }) else { return nil }
        self = type
    }
}

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
    
    let pollQuestion: String
    let expiryTime: Date
    let pollOptions: [String]
    let isInstantPoll: Bool
    let selectState: LMFeedPollSelectState
    let selectStateCount: Int
    let isAnonymous: Bool
    let allowAddOptions: Bool

    public init(
        pollQuestion: String,
        expiryTime: Date,
        pollOptions: [String],
        isInstantPoll: Bool,
        selectState: LMFeedPollSelectState,
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
