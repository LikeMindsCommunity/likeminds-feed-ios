//
//  CustomCreatePoll.swift
//  lm-feed-sample-app
//
//  Created by Devansh Mohata on 24/06/24.
//

import LikeMindsFeedCore

final class CustomCreatePoll: LMFeedCreatePollScreen {
    override func setupAppearance() {
        super.setupAppearance()
        
        containerView.backgroundColor = .yellow
    }
}
