//
//  LMFeedPostQnAMediaCell.swift
//  LikeMindsFeedUI
//
//  Created by Devansh Mohata on 23/07/24.
//

import UIKit

open class LMFeedPostQnAMediaCell: LMFeedBaseMediaCell {
    open private(set) lazy var questionTitle: LMLabel = {
        let label = LMLabel().translatesAutoresizingMaskIntoConstraints()
        label.font = Appearance.shared.fonts.headingFont1
        label.textColor = Appearance.shared.colors.gray51
        label.numberOfLines = 0
        return label
    }()
    
    
    // MARK: setupViews
    open override func setupViews() {
        super.setupViews()
        
        contentView.addSubview(containerView)
        
        containerView.addSubview(contentStack)
        containerView.addSubview(postText)
        
        contentStack.addArrangedSubview(topicFeed)
        contentStack.addArrangedSubview(questionTitle)
        contentStack.addArrangedSubview(postText)
        contentStack.addArrangedSubview(seeMoreButton)
        contentStack.addArrangedSubview(mediaCollectionView)
        contentStack.addArrangedSubview(pageControl)
    }
    
    
    // MARK: setupLayouts
    open override func setupLayouts() {
        super.setupLayouts()
        
        contentView.pinSubView(subView: containerView)
        containerView.pinSubView(subView: contentStack)
        
        topicFeed.addConstraint(leading: (contentStack.leadingAnchor, 16), trailing: (contentStack.trailingAnchor, -16))
        questionTitle.addConstraint(leading: (contentStack.leadingAnchor, 16), trailing: (contentStack.trailingAnchor, -16))
        postText.addConstraint(leading: (contentStack.leadingAnchor, 16), trailing: (contentStack.trailingAnchor, -16))
        
        mediaCollectionView.setWidthConstraint(with: contentStack.widthAnchor)
        mediaCollectionView.setHeightConstraint(with: mediaCollectionView.widthAnchor, multiplier: 2/3)
        
        pageControl.addConstraint(leading: (contentStack.leadingAnchor, 0), trailing: (contentStack.trailingAnchor, 0))
    }
    
    
    // MARK: setupAppearance
    open override func setupAppearance() {
        super.setupAppearance()
        
        postText.font = Appearance.shared.fonts.textFont2
        postText.textColor = Appearance.shared.colors.gray102
    }
    
    
    // MARK: configure
    open override func configure(with data: LMFeedPostContentModel, delegate: (any LMPostWidgetTableViewCellProtocol)?) {
        super.configure(with: data, delegate: delegate)
        
        questionTitle.text = data.postQuestion
    }
}
