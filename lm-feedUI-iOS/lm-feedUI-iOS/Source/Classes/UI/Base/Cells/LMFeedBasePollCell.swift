//
//  LMFeedBasePollCell.swift
//  LikeMindsFeedUI
//
//  Created by Devansh Mohata on 27/07/24.
//

import UIKit

open class LMFeedBasePollCell: LMPostWidgetTableViewCell {
    
    // MARK: UI Elements
    open private(set) lazy var pollPreview: LMFeedDisplayPollView = {
        let poll = LMUIComponents.shared.pollDisplayView.init()
        poll.translatesAutoresizingMaskIntoConstraints = false
        return poll
    }()
    
    
    // MARK: configure
    open func configure(with data: LMFeedPostContentModel, delegate: LMFeedPostPollCellProtocol?) {
        actionDelegate = delegate
        
        if let pollData = data.pollWidget {
            pollPreview.configure(with: pollData, delegate: delegate)
            contentStack.addArrangedSubview(pollPreview)
            
            NSLayoutConstraint.activate([
                pollPreview.leadingAnchor.constraint(equalTo: contentStack.leadingAnchor, constant: 8),
                pollPreview.trailingAnchor.constraint(equalTo: contentStack.trailingAnchor, constant: -8)
            ])
        }
    }
}
