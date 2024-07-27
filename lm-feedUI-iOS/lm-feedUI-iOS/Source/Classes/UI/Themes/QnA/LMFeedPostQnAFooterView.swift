//
//  LMFeedPostQnAFooterView.swift
//  LikeMindsFeedUI
//
//  Created by Devansh Mohata on 21/07/24.
//

import UIKit

open class LMFeedPostQnAFooterView: LMFeedBasePostFooterView {
    // MARK: UI Elements
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
    
    open private(set) lazy var containerStackView: LMStackView = {
        let stack = LMStackView().translatesAutoresizingMaskIntoConstraints()
        stack.axis = .vertical
        stack.alignment = .fill
        stack.distribution = .fill
        stack.spacing = 8
        return stack
    }()
    
    open private(set) lazy var likeContainerView: LMView = {
        let view = LMView().translatesAutoresizingMaskIntoConstraints()
        return view
    }()
    
    open override var likeText: String {
        get { 
            super.likeText
        } set {
            super.likeText = newValue
        }
    }
    
    // MARK: View Hierachy
    open override func setupViews() {
        super.setupViews()
        
        contentView.addSubview(containerView)
        containerView.addSubview(actionStackView)
        
        likeContainerView.addSubview(likeContainerStack)
        likeContainerStack.addArrangedSubview(likeButton)
        likeContainerStack.addArrangedSubview(likeCountButton)
        likeContainerStack.addArrangedSubview(likeTextButton)
        
        [likeContainerView, spacer, commentButton, saveButton, shareButton].forEach { actionStackView.addArrangedSubview($0) }
        
        likeButton.setImage(LMFeedConstants.shared.images.upvoteIcon, for: .normal)
        likeButton.setImage(LMFeedConstants.shared.images.upvoteFilledIcon, for: .selected)
    }
    
    
    // MARK: -  Constraints
    open override func setupLayouts() {
        super.setupLayouts()
        
        contentView.pinSubView(subView: containerView, padding: .init(top: 0, left: 0, bottom: -8, right: 0))
        containerView.pinSubView(subView: actionStackView, padding: .init(top: 8, left: 16, bottom: -8, right: -16))
        
        [likeContainerView, commentButton, saveButton, shareButton].forEach { btn in
            btn.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        }
        
        likeContainerView.pinSubView(subView: likeContainerStack, padding: .init(top: 0, left: 8, bottom: 0, right: -8))
        likeButton.setWidthConstraint(with: 24)
        likeButton.setHeightConstraint(with: 24)
    }
    
    
    // MARK: Actions
    open override func setupActions() {
        super.setupActions()
        
        likeText = "Upvote"
        likeCountButton.setTitle(likeText, for: .normal)
        likeCountButton.addTarget(self, action: #selector(didTapLikeButton), for: .touchUpInside)
    }
    
    // MARK: Appearance
    open override func setupAppearance() {
        super.setupAppearance()
        containerView.backgroundColor = LMFeedAppearance.shared.colors.white
        
        
        likeContainerView.clipsToBounds = true
        
        likeContainerView.backgroundColor = LMFeedAppearance.shared.colors.backgroundColor
        likeContainerView.layer.cornerRadius = 16
        likeContainerView.layer.borderColor = LMFeedAppearance.shared.colors.gray155.cgColor
        likeContainerView.layer.borderWidth = 1
        
        actionStackView.spacing = 16
    }
    
    
    open override func updateLikeText(for likeCount: Int) {
        likeTextButton.isHidden = likeCount == .zero
        likeTextButton.setTitle(formattedText(for: likeCount), for: .normal)
    }
    
    open override func updateCommentText(for commentCount: Int) {
        commentButton.isHidden = commentCount == .zero
        commentButton.setTitle(formattedText(for: commentCount), for: .normal)
    }
}
