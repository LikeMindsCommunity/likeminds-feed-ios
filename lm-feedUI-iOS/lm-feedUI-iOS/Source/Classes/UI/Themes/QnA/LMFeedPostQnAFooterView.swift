//
//  LMFeedPostQnAFooterView.swift
//  LikeMindsFeedUI
//
//  Created by Devansh Mohata on 21/07/24.
//

import UIKit

open class LMFeedPostQnAFooterView: LMFeedBasePostFooterView {
    // MARK: UI Elements
    open private(set) lazy var footerContainerView: LMStackView = {
        let stack = LMStackView().translatesAutoresizingMaskIntoConstraints()
        stack.axis = .vertical
        stack.alignment = .fill
        stack.distribution = .fill
        stack.spacing = 8
        return stack
    }()
    
    open private(set) lazy var likeContainerStack: LMStackView = {
        let stack = LMStackView().translatesAutoresizingMaskIntoConstraints()
        stack.axis = .horizontal
        stack.alignment = .center
        stack.distribution = .fill
        stack.spacing = 4
        return stack
    }()
    
    open private(set) lazy var likeCountButton: LMButton = {
        let button = LMButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(LMFeedAppearance.shared.colors.gray102, for: .normal)
        button.setTitle(likeText, for: .normal)
        return button
    }()
    
    open private(set) lazy var likeContainerView: LMView = {
        let view = LMView().translatesAutoresizingMaskIntoConstraints()
        return view
    }()
    
    open private(set) lazy var addCommentView: LMView = {
        let view = LMView().translatesAutoresizingMaskIntoConstraints()
        return view
    }()
    
    open private(set) lazy var sepratorView: LMView = {
        let view = LMView().translatesAutoresizingMaskIntoConstraints()
        view.backgroundColor = LMFeedAppearance.shared.colors.sepratorColor
        return view
    }()
    
    open private(set) lazy var profileView: LMImageView = {
        let image = LMImageView().translatesAutoresizingMaskIntoConstraints()
        image.backgroundColor = .black
        return image
    }()
    
    open private(set) lazy var placeholderLabel: LMLabel = {
        let label = LMLabel().translatesAutoresizingMaskIntoConstraints()
        label.text = "Be the first one to answer"
        label.font = LMFeedAppearance.shared.fonts.subHeadingFont2
        label.textColor = LMFeedAppearance.shared.colors.gray102
        return label
    }()
    
    open override var likeText: String {
        get { 
            super.likeText
        } set {
            super.likeText = newValue
        }
    }
    
    open override var likeButtonTintColor: UIColor {
        LMFeedAppearance.shared.colors.appTintColor
    }
    
    
    // MARK: setupViews
    open override func setupViews() {
        super.setupViews()
        
        contentView.addSubview(containerView)
        
        containerView.addSubview(footerContainerView)
        
        footerContainerView.addArrangedSubview(actionStackView)
        footerContainerView.addArrangedSubview(addCommentView)
        
        likeContainerView.addSubview(likeContainerStack)
        likeContainerStack.addArrangedSubview(likeButton)
        likeContainerStack.addArrangedSubview(likeCountButton)
        likeContainerStack.addArrangedSubview(likeTextButton)
        
        [likeContainerView, spacer, commentButton, saveButton, shareButton].forEach { actionStackView.addArrangedSubview($0) }
        
        likeButton.setImage(LMFeedConstants.shared.images.upvoteIcon, for: .normal)
        likeButton.setImage(LMFeedConstants.shared.images.upvoteFilledIcon, for: .selected)
        
        addCommentView.addSubview(sepratorView)
        addCommentView.addSubview(profileView)
        addCommentView.addSubview(placeholderLabel)
    }
    
    
    // MARK: setupLayouts
    open override func setupLayouts() {
        super.setupLayouts()
        
//        contentView.pinSubView(subView: containerView, padding: .init(top: 0, left: 0, bottom: -8, right: 0))
        
        containerView.addConstraint(top: (contentView.topAnchor, 0),
                                    leading: (contentView.leadingAnchor, 0),
                                    trailing: (contentView.trailingAnchor, 0))
        
        containerView.bottomAnchor.constraint(greaterThanOrEqualTo: contentView.bottomAnchor).isActive = true
        
        containerView.pinSubView(subView: footerContainerView, padding: .init(top: 8, left: 16, bottom: -8, right: -16))
        
        [likeContainerView, commentButton, saveButton, shareButton].forEach { btn in
            btn.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        }
        
        likeContainerView.pinSubView(subView: likeContainerStack, padding: .init(top: 0, left: 8, bottom: 0, right: -8))
        likeButton.setWidthConstraint(with: 24)
        likeButton.setHeightConstraint(with: 24)
        
        sepratorView.addConstraint(top: (addCommentView.topAnchor, 0),
                                   leading: (addCommentView.leadingAnchor, 0),
                                   trailing: (addCommentView.trailingAnchor, 0))
        sepratorView.setHeightConstraint(with: 1)
        
        profileView.addConstraint(top: (addCommentView.topAnchor, 8),
                                  bottom: (addCommentView.bottomAnchor, -8),
            leading: (addCommentView.leadingAnchor, 8),
                                  trailing: (placeholderLabel.leadingAnchor, -8),
                                  centerY: (placeholderLabel.centerYAnchor, 0)
        )
        profileView.setHeightConstraint(with: 30)
        profileView.setWidthConstraint(with: 30)
        
        placeholderLabel.addConstraint(trailing: (addCommentView.trailingAnchor, -8))
        
//        actionStackView.setHeightConstraint(with: 56, priority: .required)
//        addCommentView.setHeightConstraint(with: 56, priority: .required)
    }
    
    
    // MARK: setupActions
    open override func setupActions() {
        super.setupActions()
        
        likeText = "Upvote"
        likeCountButton.setTitle(likeText, for: .normal)
        likeCountButton.addTarget(self, action: #selector(didTapLikeButton), for: .touchUpInside)
    }
    
    // MARK: setupAppearance
    open override func setupAppearance() {
        super.setupAppearance()
        containerView.backgroundColor = LMFeedAppearance.shared.colors.white
        
        
        likeContainerView.clipsToBounds = true
        
        likeContainerView.backgroundColor = LMFeedAppearance.shared.colors.backgroundColor
        likeContainerView.layer.cornerRadius = 18
        likeContainerView.layer.borderColor = LMFeedAppearance.shared.colors.gray155.cgColor
        likeContainerView.layer.borderWidth = 1
        
        actionStackView.spacing = 16
        
        likeButton.tintColor = LMFeedAppearance.shared.colors.appTintColor
    }
    
    
    open override func updateLikeText(for likeCount: Int) {
        likeTextButton.isHidden = likeCount == .zero
        likeTextButton.setTitle(formattedText(for: likeCount), for: .normal)
    }
    
    open override func updateCommentText(for commentCount: Int) {
        commentButton.isHidden = commentCount == .zero
        commentButton.setTitle(formattedText(for: commentCount), for: .normal)
        
        addCommentView.isHidden = commentCount != .zero
    }
}
