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
    
    open private(set) lazy var profileView: LMFeedProfileImageView = {
        let image = LMFeedProfileImageView().translatesAutoresizingMaskIntoConstraints()
        image.imageView.backgroundColor = .black
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
        contentView.addSubview(containerView)
        
        setupActionStackViews()
        
        containerView.addSubview(footerContainerView)
        
        footerContainerView.addArrangedSubview(actionStackView)
        footerContainerView.addArrangedSubview(addCommentView)
        
        
        addCommentView.addSubview(sepratorView)
        addCommentView.addSubview(profileView)
        addCommentView.addSubview(placeholderLabel)
    }
    
    open func setupActionStackViews() {
        likeContainerView.addSubview(likeContainerStack)
        likeContainerStack.addArrangedSubview(likeButton)
        likeContainerStack.addArrangedSubview(likeCountButton)
        likeContainerStack.addArrangedSubview(likeTextButton)
        
        [likeContainerView, spacer, commentButton, saveButton, shareButton].forEach { actionStackView.addArrangedSubview($0) }
        
        likeButton.setImage(LMFeedConstants.shared.images.upvoteIcon, for: .normal)
        likeButton.setImage(LMFeedConstants.shared.images.upvoteFilledIcon, for: .selected)
    }
    
    open func setupActionStackLayout() {
        [likeContainerView, commentButton, saveButton, shareButton].forEach { btn in
            btn.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        }
        
        likeContainerView.pinSubView(subView: likeContainerStack, padding: .init(top: 0, left: 8, bottom: 0, right: -8))
        likeButton.setWidthConstraint(with: 24)
        likeButton.setHeightConstraint(with: 24)
    }
    
    
    // MARK: setupLayouts
    open override func setupLayouts() {
        containerView.addConstraint(top: (contentView.topAnchor, 0),
                                    leading: (contentView.leadingAnchor, 0),
                                    trailing: (contentView.trailingAnchor, 0))
        
        containerView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -8).isActive = true
        
        containerView.pinSubView(subView: footerContainerView, padding: .init(top: 8, left: 16, bottom: -8, right: -16))
        
        setupActionStackLayout()
        
        sepratorView.addConstraint(top: (addCommentView.topAnchor, 0),
                                   leading: (addCommentView.leadingAnchor, 0),
                                   trailing: (addCommentView.trailingAnchor, 0))
        sepratorView.setHeightConstraint(with: 1)
        
        profileView.addConstraint(top: (addCommentView.topAnchor, 16),
                                  bottom: (addCommentView.bottomAnchor, -8),
                                  leading: (addCommentView.leadingAnchor, 0))
        
        profileView.setWidthConstraint(with: profileView.heightAnchor)
        
        placeholderLabel.addConstraint(leading: (profileView.trailingAnchor, 8),
            trailing: (addCommentView.trailingAnchor, -8),
                                       centerY: (profileView.centerYAnchor, 0))
        
        addCommentView.setHeightConstraint(with: 54, priority: .required)
    }
    
    
    // MARK: setupActions
    open override func setupActions() {
        super.setupActions()
        
        likeText = "Upvote"
        likeCountButton.addTarget(self, action: #selector(didTapLikeButton), for: .touchUpInside)
        
        addCommentView.isUserInteractionEnabled = true
        addCommentView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapCommentButton)))
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
        likeTextButton.setTitleColor(LMFeedAppearance.shared.colors.gray102, for: .normal)
        
        profileView.clipsToBounds = true
        profileView.roundCorners(with: 15)
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
    
    open override func configure(with data: LMFeedBasePostFooterView.ContentModel, postID: String, delegate: any LMFeedPostFooterViewProtocol) {
        super.configure(with: data, postID: postID, delegate: delegate)
        
        likeCountButton.setTitle(likeText, for: .normal)
        
        profileView.configure(with: data.user?.userProfileImage, userName: data.user?.userName)
    }
}
