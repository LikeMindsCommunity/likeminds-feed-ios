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
        label.font = LMFeedAppearance.shared.fonts.headingFont1
        label.textColor = LMFeedAppearance.shared.colors.gray51
        label.numberOfLines = 0
        return label
    }()
    
    open private(set) lazy var topResponseView: LMFeedTopResponseView = {
        let view = LMFeedTopResponseView().translatesAutoresizingMaskIntoConstraints()
        return view
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
        contentStack.addArrangedSubview(topResponseView)
    }
    
    
    // MARK: setupLayouts
    open override func setupLayouts() {
        super.setupLayouts()
        
        contentView.pinSubView(subView: containerView)
        containerView.pinSubView(subView: contentStack)
        
        topicFeed.addConstraint(leading: (contentStack.leadingAnchor, 16), trailing: (contentStack.trailingAnchor, -16))
        questionTitle.addConstraint(leading: (contentStack.leadingAnchor, 16), trailing: (contentStack.trailingAnchor, -16))
        postText.addConstraint(leading: (contentStack.leadingAnchor, 16), trailing: (contentStack.trailingAnchor, -16))
        topResponseView.addConstraint(leading: (contentStack.leadingAnchor, 16), trailing: (contentStack.trailingAnchor, -16))
        
        mediaCollectionView.setWidthConstraint(with: contentStack.widthAnchor)
        mediaCollectionView.setHeightConstraint(with: mediaCollectionView.widthAnchor, multiplier: 2/3)
        
        pageControl.addConstraint(leading: (contentStack.leadingAnchor, 0), trailing: (contentStack.trailingAnchor, 0))
    }
    
    
    // MARK: setupAppearance
    open override func setupAppearance() {
        super.setupAppearance()
        
        questionTitle.textColor = LMFeedAppearance.shared.colors.gray51
        questionTitle.font = LMFeedAppearance.shared.fonts.headingFont1
    }
    
    
    // MARK: configure
    open override func configure(with data: LMFeedPostContentModel, delegate: (any LMPostWidgetTableViewCellProtocol)?) {
        super.configure(with: data, delegate: delegate)
        
        questionTitle.text = data.postQuestion
        
        if let topComment = data.topResponse {
            topResponseView.configure(with: topComment)
            topResponseView.isHidden = false
        } else {
            topResponseView.isHidden = true
        }
    }
}
