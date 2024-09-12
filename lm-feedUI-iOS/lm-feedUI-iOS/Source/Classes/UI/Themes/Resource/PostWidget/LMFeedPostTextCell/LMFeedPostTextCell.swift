//
//  LMFeedPostTextCell.swift
//  LikeMindsFeedUI
//
//  Created by Anurag Tyagi on 12/09/24.
//

import Foundation

@IBDesignable
open class LMFeedPostTextCell: LMFeedPostBaseTextCell {
    // MARK: setupViews
    open override func setupViews() {
        super.setupViews()
        
        contentView.addSubview(containerView)
        
        containerView.addSubview(contentStack)
        
        contentStack.addArrangedSubview(topicFeed)
        contentStack.addArrangedSubview(postText)
        contentStack.addArrangedSubview(seeMoreButton)
    }
    
    
    // MARK: setupLayouts
    open override func setupLayouts() {
        super.setupLayouts()
        
        contentView.pinSubView(subView: containerView)
        containerView.pinSubView(subView: contentStack)
        
        topicFeed.addConstraint(leading: (contentStack.leadingAnchor, 16), trailing: (contentStack.trailingAnchor, -16))
        postText.addConstraint(leading: (contentStack.leadingAnchor, 16), trailing: (contentStack.trailingAnchor, -16))
    }
}
