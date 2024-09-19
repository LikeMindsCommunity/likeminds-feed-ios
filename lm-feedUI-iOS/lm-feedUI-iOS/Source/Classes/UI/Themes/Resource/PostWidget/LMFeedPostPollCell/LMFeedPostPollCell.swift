//
//  LMFeedPostPollCell.swift
//  LikeMindsFeedUI
//
//  Created by Devansh Mohata on 14/06/24.
//

import UIKit

open class LMFeedPostPollCell: LMFeedBasePollCell {
    // MARK: setupViews
    open override func setupViews() {
        super.setupViews()
        
        contentView.addSubview(containerView)
        containerView.addSubview(contentStack)
    }
    
    
    // MARK: setupLayouts
    open override func setupLayouts() {
        super.setupLayouts()
        
        contentView.pinSubView(subView: containerView)
        containerView.pinSubView(subView: contentStack)
    }
}
