//
//  LMFeedWidgetDataModel.swift
//  Pods
//
//  Created by Anurag Tyagi on 16/12/24.
//

import Foundation
import LikeMindsFeed

public struct LMFeedWidgetDataModel {
    public let id: String?
    public let parentEntityID: String?
    public let parentEntityType: String?
    public let metadata: [String: Any]?
    public let createdAt: Double?
    public let updatedAt: Double?
    public let lmMeta: LMFeedLMMetaDataModel?

    public init(
        id: String?,
        parentEntityID: String?,
        parentEntityType: String?,
        metadata: [String: Any]?,
        createdAt: Double?,
        updatedAt: Double?,
        lmMeta: LMFeedLMMetaDataModel?
    ) {
        self.id = id
        self.parentEntityID = parentEntityID
        self.parentEntityType = parentEntityType
        self.metadata = metadata
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.lmMeta = lmMeta
    }
}

extension LMFeedWidgetDataModel {
    /// Converts a `Widget` model into an `LMFeedWidgetDataModel`.
    public static func from(widget: Widget) -> LMFeedWidgetDataModel {
        return LMFeedWidgetDataModel(
            id: widget.id,
            parentEntityID: widget.parentEntityID,
            parentEntityType: widget.parentEntityType,
            metadata: widget.metadata,
            createdAt: widget.createdAt,
            updatedAt: widget.updatedAt,
            lmMeta: widget.lmMeta != nil
                ? LMFeedLMMetaDataModel.from(meta: widget.lmMeta!) : nil
        )
    }
}

public struct LMFeedLMMetaDataModel {
    public let options: [LMFeedPollOptionDataModel]
    public let pollAnswerText: String?
    public let isShowResult: Bool?
    public let voteCount: Int?

    public enum CodingKeys: String, CodingKey {
        case options
        case pollAnswerText = "poll_answer_text"
        case isShowResult = "to_show_results"
        case voteCount = "voters_count"
    }

    public init(
        options: [LMFeedPollOptionDataModel], pollAnswerText: String?, isShowResult: Bool?,
        voteCount: Int?
    ) {
        self.options = options
        self.pollAnswerText = pollAnswerText
        self.isShowResult = isShowResult
        self.voteCount = voteCount
    }
}

extension LMFeedLMMetaDataModel {
    /// Converts a `LMMeta` model into `LMFeedLMMetaDataModel`
    public static func from(meta: LMMeta) -> LMFeedLMMetaDataModel {
        return LMFeedLMMetaDataModel(
            options: meta.options.map{
                pollOption in
                LMFeedPollOptionDataModel.from(pollOption: pollOption)
            },
            pollAnswerText: meta.pollAnswerText,
            isShowResult: meta.isShowResult,
            voteCount: meta.voteCount)
    }
}

public struct LMFeedPollOptionDataModel {
    public let id: String?
    public let text: String?
    public let isSelected: Bool
    public let percentage: Double
    public let uuid: String?
    public let voteCount: Int
}

extension LMFeedPollOptionDataModel {
    public static func from(pollOption: PollOption) -> LMFeedPollOptionDataModel
    {
        return LMFeedPollOptionDataModel(
            id: pollOption.id, text: pollOption.text,
            isSelected: pollOption.isSelected,
            percentage: pollOption.percentage, uuid: pollOption.uuid,
            voteCount: pollOption.voteCount)
    }
}
