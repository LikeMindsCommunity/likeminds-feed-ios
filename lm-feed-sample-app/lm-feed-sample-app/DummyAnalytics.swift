//
//  DummyAnalytics.swift
//  lm-feed-sample-app
//
//  Created by Devansh Mohata on 13/02/24.
//

import lm_feedCore_iOS

final class DummyAnalytics: LMFeedAnalyticsProtocol {
    public func trackEvent(for eventName: LMFeedAnalyticsEventName, eventProperties: [String : AnyHashable]) {
        let track = """
            ========Event Tracker========
        Event Name: \(eventName.description)
        Event Properties: \(eventProperties)
            =============================
        """
        print(track)
    }
}
