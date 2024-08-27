//
//  LMFeedPostDetailFooterView.swift
//  lm-feedUI-iOS
//
//  Created by Devansh Mohata on 17/02/24.
//

import UIKit

@IBDesignable
open class LMFeedPostDetailFooterView: LMFeedPostFooterView { 
    open private(set) lazy var commentStackView: LMStackView = {
        let stack = LMStackView().translatesAutoresizingMaskIntoConstraints()
        stack.axis = .vertical
        stack.alignment = .fill
        stack.distribution = .fill
        stack.spacing = 0
        return stack
    }()
        
    open private(set) lazy var commentContainerView: LMView = {
        let view = LMView().translatesAutoresizingMaskIntoConstraints()
        return view
    }()
    
    open private(set) lazy var totalCommentLabel: LMLabel = {
        let label = LMLabel().translatesAutoresizingMaskIntoConstraints()
        label.font = LMFeedAppearance.shared.fonts.headingFont3
        label.textColor = LMFeedAppearance.shared.colors.gray1
        return label
    }()
    
    open private(set) lazy var noCommentContainerView: LMView = {
        let view = LMView().translatesAutoresizingMaskIntoConstraints()
        return view
    }()
    
    open private(set) lazy var noCommenTitleLabel: LMLabel = {
        let label =  LMLabel().translatesAutoresizingMaskIntoConstraints()
        label.text = ""
        label.textColor = LMFeedAppearance.shared.colors.gray51
        return label
    }()
    
    open private(set) lazy var noCommentSubtitleLabel: LMLabel = {
        let label = LMLabel().translatesAutoresizingMaskIntoConstraints()
        label.text = ""
        label.textColor = LMFeedAppearance.shared.colors.gray102
        return label
    }()
    
    
    open override func setupViews() {
        super.setupViews()
        contentView.addSubview(commentStackView)
        
        noCommentContainerView.addSubview(noCommenTitleLabel)
        noCommentContainerView.addSubview(noCommentSubtitleLabel)
        commentStackView.addArrangedSubview(noCommentContainerView)
        
        commentContainerView.addSubview(totalCommentLabel)
        commentStackView.addArrangedSubview(commentContainerView)
    }
    
    
    open override func setupLayouts() {
        containerView.addConstraint(top: (contentView.topAnchor, 0),
                                    leading: (contentView.leadingAnchor, 0),
                                    trailing: (contentView.trailingAnchor, 0))
        
        containerView.pinSubView(subView: actionStackView, padding: .init(top: 8, left: 16, bottom: -8, right: -16))
        
        commentStackView.addConstraint(top: (containerView.bottomAnchor, 16),
                                           bottom: (contentView.bottomAnchor, 0),
                                           leading: (contentView.leadingAnchor, 0),
                                           trailing: (contentView.trailingAnchor, 0))
        
        noCommenTitleLabel.addConstraint(top: (noCommentContainerView.topAnchor, 16),
                                 centerX: (noCommentContainerView.centerXAnchor, 0))
        
        noCommentSubtitleLabel.addConstraint(top: (noCommenTitleLabel.bottomAnchor, 4),
                                    bottom: (noCommentContainerView.bottomAnchor, -16),
                                    centerX: (noCommenTitleLabel.centerXAnchor, 0))
        
        totalCommentLabel.addConstraint(top: (commentContainerView.topAnchor, 16),
                                        bottom: (commentContainerView.bottomAnchor, -8),
                                        leading: (commentContainerView.leadingAnchor, 16))
        totalCommentLabel.trailingAnchor.constraint(lessThanOrEqualTo: commentContainerView.trailingAnchor, constant: -16).isActive = true
    }
    
    
    open override func setupAppearance() {
        super.setupAppearance()
        commentContainerView.backgroundColor = LMFeedAppearance.shared.colors.white
    }
    
    open func configure(with data: LMFeedPostFooterView.ContentModel, postID: String, delegate: LMFeedPostFooterViewProtocol, commentCount: Int) {
        super.configure(with: data, postID: postID, delegate: delegate)
        updateCommentCount(with: commentCount)
    }
    
    open func updateCommentCount(with commentCount: Int) {
        updateCommentText(for: commentCount)
        
        noCommentContainerView.isHidden = commentCount != 0
        commentContainerView.isHidden = commentCount == 0
        
        if commentCount == 0 {
            noCommenTitleLabel.text = "No \(commentText.pluralize()) Found"
            noCommentSubtitleLabel.text = "Be the first one to create a \(commentText)"
        }
        
        totalCommentLabel.text = "\(commentCount) \(commentText.pluralize(count: commentCount))"
    }
}
