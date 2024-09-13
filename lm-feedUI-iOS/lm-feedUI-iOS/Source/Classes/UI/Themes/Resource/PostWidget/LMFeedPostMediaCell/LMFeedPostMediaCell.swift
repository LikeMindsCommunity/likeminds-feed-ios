//
//  LMFeedPostMediaCell.swift
//  LMFramework
//
//  Created by Devansh Mohata on 29/11/23.
//

import AVKit
import UIKit

@IBDesignable
open class LMFeedPostMediaCell: LMFeedBaseMediaCell {
    // MARK: setupViews
    open override func setupViews() {
        super.setupViews()
        
        contentView.addSubview(containerView)
        
        containerView.addSubview(contentStack)
        
        contentStack.addArrangedSubview(topicFeed)
        contentStack.addArrangedSubview(postText.postText)
        contentStack.addArrangedSubview(postText.seeMoreButton)
        contentStack.addArrangedSubview(mediaCollectionView)
        contentStack.addArrangedSubview(pageControl)
    }
    
    
    // MARK: setupLayouts
    open override func setupLayouts() {
        super.setupLayouts()
        
        contentView.pinSubView(subView: containerView)
        containerView.pinSubView(subView: contentStack)
        
        topicFeed.addConstraint(leading: (contentStack.leadingAnchor, 16), trailing: (contentStack.trailingAnchor, -16))
        postText.postText.addConstraint(leading: (contentStack.leadingAnchor, 16), trailing: (contentStack.trailingAnchor, -16))
        postText.seeMoreButton.addConstraint(leading: (contentStack.leadingAnchor, 16), trailing: (contentStack.trailingAnchor, -16))
        
        pageControl.addConstraint(leading: (contentStack.leadingAnchor, 0), trailing: (contentStack.trailingAnchor, 0))
    }
}
