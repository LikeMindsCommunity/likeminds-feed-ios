//
//  LMFeedBaseTopicCell.swift
//  LikeMindsFeedUI
//
//  Created by Anurag Tyagi on 19/09/24.
//

import Foundation

open class LMFeedPostBaseTopicCell: LMPostWidgetTableViewCell {
    open private(set) lazy var topicFeed: LMFeedTopicView = {
        let view = LMFeedTopicView().translatesAutoresizingMaskIntoConstraints()
        return view
    }()
    
    deinit { }
    
    // MARK: setupLayouts
    open override func setupLayouts() {
        super.setupLayouts()
        
        topicFeed.setContentHuggingPriority(.defaultLow, for: .vertical)
        topicFeed.setHeightConstraint(with: 0, priority: .defaultLow)
    }
    
    open override func prepareForReuse() {
        super.prepareForReuse()
        print(#function)
    }
    
    open func configure(data: LMFeedPostContentModel) {
        topicFeed.configure(with: data.topics)
        topicFeed.isHidden = data.topics.topics.isEmpty
    }
}
