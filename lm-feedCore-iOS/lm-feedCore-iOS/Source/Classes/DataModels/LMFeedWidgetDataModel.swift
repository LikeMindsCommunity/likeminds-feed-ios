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
    public let lmMeta: [String: Any]?

    public init(
        id: String?,
        parentEntityID: String?,
        parentEntityType: String?,
        metadata: [String: Any]?,
        createdAt: Double?,
        updatedAt: Double?,
        lmMeta: [String: Any]?
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
            lmMeta: widget.lmMeta
        )
    }
}
