//
//  LMFeedPostQnADocumentCell.swift
//  LikeMindsFeedUI
//
//  Created by Devansh Mohata on 23/07/24.
//

import UIKit

open class LMFeedPostQnADocumentCell: LMFeedBaseDocumentCell {
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
        
        [topicFeed, questionTitle, postText, seeMoreButton, documentContainerStack].forEach { subView in
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
        postText.addConstraint(leading: (contentStack.leadingAnchor, 16), trailing: (contentStack.trailingAnchor, -16))
        documentContainerStack.addConstraint(leading: (contentStack.leadingAnchor, 16), trailing: (contentStack.trailingAnchor, -16))
    }
    
    
    // MARK: setupAppearance
    open override func setupAppearance() {
        super.setupAppearance()
        
        postText.font = Appearance.shared.fonts.textFont2
        postText.textColor = Appearance.shared.colors.gray102
    }
    
    // MARK: configure
    open override func configure(for indexPath: IndexPath, with data: LMFeedPostContentModel, delegate: (any LMFeedPostDocumentCellProtocol)?) {
        super.configure(for: indexPath, with: data, delegate: delegate)
        questionTitle.text = data.postQuestion
    }
}
