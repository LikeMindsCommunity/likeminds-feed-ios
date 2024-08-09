//
//  LMFeedQnADetailFooterView.swift
//  LikeMindsFeedUI
//
//  Created by Devansh Mohata on 31/07/24.
//

import UIKit

open class LMFeedQnADetailFooterView: LMFeedPostQnAFooterView {
    // MARK: UI Elements
    open private(set) lazy var actionStackContainer: LMView = {
        let view = LMView().translatesAutoresizingMaskIntoConstraints()
        return view
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
    
    
    // MARK: setupViews
    open override func setupViews() {
        contentView.addSubview(containerView)
        
        containerView.addSubview(footerContainerView)
        
        footerContainerView.addArrangedSubview(actionStackContainer)
        footerContainerView.addArrangedSubview(addCommentView)
        footerContainerView.addArrangedSubview(commentContainerView)
        
        setupActionStackViews()
        
        actionStackContainer.addSubview(actionStackView)
        
        addCommentView.addSubview(noCommenTitleLabel)
        addCommentView.addSubview(noCommentSubtitleLabel)
        
        commentContainerView.addSubview(totalCommentLabel)
        
        footerContainerView.spacing = 16
    }
    
    
    // MARK: setupLayouts
    open override func setupLayouts() {
        containerView.addConstraint(top: (contentView.topAnchor, 0),
                                    leading: (contentView.leadingAnchor, 0),
                                    trailing: (contentView.trailingAnchor, 0))
        
        containerView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: 0).isActive = true
        
        containerView.pinSubView(subView: footerContainerView, padding: .init(top: 0, left: 0, bottom: 0, right: 0))
        
        actionStackContainer.pinSubView(subView: actionStackView, padding: .init(top: 8, left: 16, bottom: -8, right: -16))
        
        setupActionStackLayout()
        
        noCommenTitleLabel.addConstraint(top: (addCommentView.topAnchor, 8),
                                         centerX: (addCommentView.centerXAnchor, 0))
        
        noCommentSubtitleLabel.addConstraint(top: (noCommenTitleLabel.bottomAnchor, 8),
                                             bottom: (addCommentView.bottomAnchor, -8),
                                             centerX: (addCommentView.centerXAnchor, 0))
        
        
        totalCommentLabel.addConstraint(top: (commentContainerView.topAnchor, 8),
                                        bottom: (commentContainerView.bottomAnchor, -8),
                                        leading: (commentContainerView.leadingAnchor, 16),
                                        trailing: (commentContainerView.trailingAnchor, -16))
        
        noCommenTitleLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        noCommentSubtitleLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        totalCommentLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        
        noCommenTitleLabel.text = "Hello World"
        noCommentSubtitleLabel.text = "WELCOME!!!"
    }
    
    
    open override func setupAppearance() {
        super.setupAppearance()
        
        contentView.backgroundColor = LMFeedAppearance.shared.colors.clear
        containerView.backgroundColor = LMFeedAppearance.shared.colors.clear
        
        actionStackContainer.backgroundColor = LMFeedAppearance.shared.colors.white
        addCommentView.backgroundColor = LMFeedAppearance.shared.colors.clear
        commentContainerView.backgroundColor = LMFeedAppearance.shared.colors.white
    }
    
    open override func updateCommentText(for commentCount: Int) {
        super.updateCommentText(for: commentCount)
        
        totalCommentLabel.text = "\(formattedText(for: commentCount)) \(commentText.pluralize(count: commentCount))"
        commentContainerView.isHidden = commentCount == .zero
    }
    
    open override func configure(with data: LMFeedBasePostFooterView.ContentModel, postID: String, delegate: any LMFeedPostFooterViewProtocol) {
        super.configure(with: data, postID: postID, delegate: delegate)
        
        addCommentView.isHidden = data.commentCount != .zero
        
        noCommenTitleLabel.text = "No \(commentText.lowercased()) found!"
        noCommentSubtitleLabel.text = "Be the first to create a \(commentText.lowercased())"
    }
}
