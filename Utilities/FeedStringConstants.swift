//
//  FeedStringConstants.swift
//  LikeMindsFeedCore
//
//  Created by Devansh Mohata on 10/07/24.
//

import Foundation

public struct FeedStringConstants {
    enum WordAction: Int {
        case firstLetterCapitalSingular
        case allCapitalSingular
        case allSmallSingular
        case firstLetterCapitalPlural
        case allCapitalPlural
        case allSmallPlural
    }

    func pluralizeOrCapitalize(to value: String, withAction action: WordAction) -> String {
        switch action {
        case .firstLetterCapitalSingular:
            return value.capitalized
        case .allCapitalSingular:
            return value.uppercased()
        case .allSmallSingular:
            return value.lowercased()
        case .firstLetterCapitalPlural:
            return value.pluralize().capitalized
        case .allCapitalPlural:
            return value.pluralize().uppercased()
        case .allSmallPlural:
            return value.pluralize().lowercased()
        }
    }

    
    public var postVariable: String {
        LocalPreferences.communityConfiguration?.configs.first(where: { $0.type == "feed_metadata" })?.value?.post ?? "resource"
    }
    
    
}
