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
        contentStack.addArrangedSubview(questionTitle)
        contentStack.addArrangedSubview(postText)
        contentStack.addArrangedSubview(seeMoreButton)
    }
    
    
    // MARK: setupLayouts
    open override func setupLayouts() {
        super.setupLayouts()
        
        contentView.pinSubView(subView: containerView)
        containerView.pinSubView(subView: contentStack)
        
        questionTitle.addConstraint(leading: (contentStack.leadingAnchor, 16), trailing: (contentStack.trailingAnchor, -16))
        postText.addConstraint(leading: (contentStack.leadingAnchor, 12), trailing: (contentStack.trailingAnchor, -12))
        seeMoreButton.addConstraint(leading: (contentStack.leadingAnchor, 16), trailing: (contentStack.trailingAnchor, -16))
    }
    
    
}
