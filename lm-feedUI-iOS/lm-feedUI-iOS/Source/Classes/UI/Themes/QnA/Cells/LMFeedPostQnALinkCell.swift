//
//  LMFeedPostQnALinkCell.swift
//  LikeMindsFeedUI
//
//  Created by Devansh Mohata on 23/07/24.
//

import UIKit

open class LMFeedPostQnALinkCell: LMFeedBaseLinkCell {
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
        
        [topicFeed, questionTitle, postText.postText, postText.seeMoreButton, topResponseView].forEach { subView in
            contentStack.addArrangedSubview(subView)
        }
    }
    
    
    // MARK: setupLayouts
    open override func setupLayouts() {
        super.setupLayouts()
        
        contentView.pinSubView(subView: containerView)
        containerView.pinSubView(subView: contentStack)

        topicFeed.addConstraint(leading: (contentStack.leadingAnchor, 16), trailing: (contentStack.trailingAnchor, -16))
        questionTitle.addConstraint(leading: (contentStack.leadingAnchor, 16), trailing: (contentStack.trailingAnchor, -16))
        postText.addConstraint(leading: (contentStack.leadingAnchor, 12), trailing: (contentStack.trailingAnchor, -12))
        topResponseView.addConstraint(leading: (contentStack.leadingAnchor, 16), trailing: (contentStack.trailingAnchor, -16))
        
        linkPreveiw.setHeightConstraint(with: 1000, priority: .defaultLow)
        linkPreveiw.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
    }
    
    
    // MARK: setupAppearance
    open override func setupAppearance() {
        super.setupAppearance()
        
        questionTitle.textColor = LMFeedAppearance.shared.colors.gray51
        questionTitle.font = LMFeedAppearance.shared.fonts.headingFont1
    }
    
    
    // MARK: configure
    open override func configure(with data: LMFeedPostContentModel, delegate: (any LMFeedLinkProtocol)?) {
        super.configure(with: data, delegate: delegate)
        
        questionTitle.text = data.postQuestion
        
        if let topComment = data.topResponse {
            topResponseView.isHidden = false
            topResponseView.configure(with: topComment)
        } else {
            topResponseView.isHidden = true
        }
    }
}
