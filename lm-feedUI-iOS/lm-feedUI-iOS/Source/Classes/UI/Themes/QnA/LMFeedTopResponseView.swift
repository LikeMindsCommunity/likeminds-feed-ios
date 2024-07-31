//
//  LMFeedTopResponseView.swift
//  LikeMindsFeedUI
//
//  Created by Devansh Mohata on 21/07/24.
//

import Kingfisher
import UIKit

open class LMFeedTopResponseView: LMView {
    // MARK: UI Elements
    open private(set) lazy var containerView: LMView = {
        let view = LMView().translatesAutoresizingMaskIntoConstraints()
        return view
    }()
    
    open private(set) lazy var titleLabel: LMLabel = {
        let label = LMLabel().translatesAutoresizingMaskIntoConstraints()
        label.text = "Top Response"
        label.font = LMFeedAppearance.shared.fonts.textFont2
        label.textColor = LMFeedAppearance.shared.colors.gray51
        label.textAlignment = .left
        return label
    }()
    
    open private(set) lazy var containerStackView: LMStackView = {
        let stack = LMStackView().translatesAutoresizingMaskIntoConstraints()
        stack.axis = .horizontal
        stack.alignment = .top
        stack.distribution = .fill
        stack.spacing = 8
        return stack
    }()
    
    open private(set) lazy var profilePicture: LMImageView = {
        let imageView = LMImageView().translatesAutoresizingMaskIntoConstraints()
        return imageView
    }()
    
    open private(set) lazy var contentContainerView: LMView = {
        let view = LMView().translatesAutoresizingMaskIntoConstraints()
        return view
    }()
    
    open private(set) lazy var contentStackView: LMStackView = {
        let stack = LMStackView().translatesAutoresizingMaskIntoConstraints()
        stack.axis = .vertical
        stack.alignment = .fill
        stack.distribution = .fill
        stack.spacing = 8
        return stack
    }()
    
    open private(set) lazy var usernameLabel: LMLabel = {
        let label = LMLabel().translatesAutoresizingMaskIntoConstraints()
        label.font = LMFeedAppearance.shared.fonts.headingFont3
        label.textColor = LMFeedAppearance.shared.colors.gray51
        label.text = "Author"
        return label
    }()
    
    open private(set) lazy var timeStampLabel: LMLabel = {
        let label = LMLabel().translatesAutoresizingMaskIntoConstraints()
        label.font = LMFeedAppearance.shared.fonts.textFont2
        label.textColor = LMFeedAppearance.shared.colors.gray155
        label.text = "Timestamp"
        return label
    }()
    
    open private(set) lazy var contentLabel: LMLabel = {
        let label = LMLabel().translatesAutoresizingMaskIntoConstraints()
        label.font = LMFeedAppearance.shared.fonts.textFont2
        label.textColor = LMFeedAppearance.shared.colors.gray51
        label.text = "Dummy Comment"
        return label
    }()
    
    open private(set) lazy var sepratorView: LMView = {
        let view = LMView().translatesAutoresizingMaskIntoConstraints()
        view.backgroundColor = LMFeedAppearance.shared.colors.sepratorColor
        return view
    }()
    
    
    open var profilePictureHeight: CGFloat { 40 }
    
    
    // MARK: setupViews
    open override func setupViews() {
        super.setupViews()
        
        addSubview(containerView)
        
        containerView.addSubview(titleLabel)
        containerView.addSubview(containerStackView)
        containerView.addSubview(sepratorView)
        
        containerStackView.addArrangedSubview(profilePicture)
        containerStackView.addArrangedSubview(contentContainerView)
        
        contentContainerView.addSubview(contentStackView)
        
        contentStackView.addArrangedSubview(usernameLabel)
        contentStackView.addArrangedSubview(timeStampLabel)
        contentStackView.addArrangedSubview(contentLabel)
    }
    
    
    // MARK: setupLayouts
    open override func setupLayouts() {
        super.setupLayouts()
        
        pinSubView(subView: containerView)
        
        titleLabel.addConstraint(top: (containerView.topAnchor, 8),
                                 leading: (containerView.leadingAnchor, 8),
                                 trailing: (containerView.trailingAnchor, -8))
        
        containerStackView.addConstraint(top: (titleLabel.bottomAnchor, 16),
                                         bottom: (containerView.bottomAnchor, -8),
                                         leading: (titleLabel.leadingAnchor, 0),
                                         trailing: (titleLabel.trailingAnchor, 0))
        
        profilePicture.setWidthConstraint(with: profilePictureHeight)
        profilePicture.setHeightConstraint(with: profilePicture.widthAnchor)
        
        contentContainerView.pinSubView(subView: contentStackView, padding: .init(top: 8, left: 8, bottom: -8, right: -8))
        
        sepratorView.setHeightConstraint(with: 1)
        sepratorView.addConstraint(bottom: (containerView.bottomAnchor, 0),
                                   leading: (containerView.leadingAnchor, 0),
                                   trailing: (containerView.trailingAnchor, 0))
    }
    
    
    // MARK: setupAppearance
    open override func setupAppearance() {
        super.setupAppearance()
        
        contentContainerView.backgroundColor = LMFeedAppearance.shared.colors.backgroundColor
        contentContainerView.layer.cornerRadius = 8
        
        contentStackView.clipsToBounds = true
        contentStackView.layer.masksToBounds = true
        
        profilePicture.layer.cornerRadius = profilePictureHeight / 2
    }
    
    
    // MARK: configure
    open func configure(with data: LMFeedCommentContentModel) {
        profilePicture.kf.setImage(with: URL(string: data.author.userProfileImage ?? ""), placeholder: LMImageView.generateLetterImage(name: data.authorName))
        
        usernameLabel.text = data.authorName
        timeStampLabel.text = data.commentTime
        contentLabel.text = data.comment
    }
}
