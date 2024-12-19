//
//  LMFeedPollDataModel.swift
//  LikeMindsFeedCore
//
//  Created by Devansh Mohata on 10/06/24.
//

import LikeMindsFeed

public struct LMFeedPollDataModel {
    public struct Option {
        public let id: String
        public let option: String
        public var isSelected: Bool
        public let voteCount: Int
        public let percentage: Double
        public let addedBy: LMFeedUserDataModel

        public init(
            id: String, option: String, isSelected: Bool, voteCount: Int,
            percentage: Double, addedBy: LMFeedUserDataModel
        ) {
            self.id = id
            self.option = option
            self.isSelected = isSelected
            self.voteCount = voteCount
            self.percentage = percentage
            self.addedBy = addedBy
        }
    }

    public let id: String
    public let postID: String
    public let question: String
    public var options: [Option]
    public let pollDisplayText: String
    public let pollSelectType: LMFeedPollSelectState
    public let pollSelectCount: Int
    public let expiryTime: Int
    public let isAnonymous: Bool
    public let allowAddOptions: Bool
    public let showResults: Bool
    public let isInstantPoll: Bool
    public let voteCount: Int
    public var userSelectedOptions: [String]

    public init(
        id: String,
        postID: String,
        question: String,
        options: [Option],
        pollDisplayText: String,
        pollSelectType: LMFeedPollSelectState,
        pollSelectCount: Int,
        expiryTime: Int,
        isAnonymous: Bool,
        allowAddOptions: Bool,
        showResults: Bool,
        isInstantPoll: Bool,
        voteCount: Int
    ) {
        self.id = id
        self.postID = postID
        self.question = question
        self.options = options
        self.pollDisplayText = pollDisplayText
        self.pollSelectType = pollSelectType
        self.pollSelectCount = pollSelectCount
        self.expiryTime = expiryTime
        self.isAnonymous = isAnonymous
        self.allowAddOptions = allowAddOptions
        self.showResults = showResults
        self.isInstantPoll = isInstantPoll
        self.voteCount = voteCount
        self.userSelectedOptions = []
    }
}

extension LMFeedPollDataModel {
    public init?(postID: String, users: [String: User], widget: Widget?) {
        guard let widget = widget,
            let id = widget.id,
            let question = widget.metadata?["title"] as? String,
            let pollDisplayText = widget.lmMeta?.pollAnswerText
        else { return nil }

        let selectType: String =
            (widget.metadata?["multiple_select_state"] as? String) ?? "exactly"
        let selectNumber: Int =
            (widget.metadata?["multiple_select_number"] as? Int) ?? 1
        let expiryTime: Int = (widget.metadata?["expiry_time"] as? Int) ?? .zero
        let isAnonymous: Bool =
            (widget.metadata?["is_anonymous"] as? Bool) ?? false
        let allowAddOptions: Bool =
            (widget.metadata?["allow_add_option"] as? Bool) ?? false
        let pollType: String =
            (widget.metadata?["poll_type"] as? String) ?? "instant"

        self.id = id
        self.postID = postID
        self.question = question
        self.options =
            (widget.lmMeta?.options)?.compactMap({
                Option.init(users: users, option: $0)
            }) ?? []
        self.pollDisplayText = pollDisplayText
        self.pollSelectType = .init(key: selectType) ?? .exactly
        self.pollSelectCount = selectNumber
        self.expiryTime = expiryTime
        self.isAnonymous = isAnonymous
        self.allowAddOptions = allowAddOptions
        self.showResults = widget.lmMeta?.isShowResult ?? false
        self.isInstantPoll = pollType == "instant"
        self.voteCount = widget.lmMeta?.voteCount ?? 0
        self.userSelectedOptions = []
    }
}

extension LMFeedPollDataModel.Option {
    public init?(users: [String: User], option: PollOption) {
        guard let uuid = option.uuid,
            let user = users[uuid],
            let id = option.id,
            let text = option.text
        else { return nil }

        self.id = id
        self.option = text
        self.isSelected = option.isSelected
        self.voteCount = option.voteCount
        self.percentage = option.percentage
        self.addedBy = .init(
            userName: user.name ?? "User",
            userUUID: uuid,
            userProfileImage: user.imageUrl,
            customTitle: user.customTitle
        )
    }
}
