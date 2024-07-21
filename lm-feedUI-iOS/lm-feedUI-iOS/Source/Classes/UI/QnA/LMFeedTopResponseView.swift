//
//  LMFeedTopResponseView.swift
//  LikeMindsFeedUI
//
//  Created by Devansh Mohata on 21/07/24.
//

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
        label.font = Appearance.shared.fonts.textFont2
        label.textColor = Appearance.shared.colors.gray51
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
        label.font = Appearance.shared.fonts.headingFont3
        label.textColor = Appearance.shared.colors.gray51
        label.text = "Author"
        return label
    }()
    
    open private(set) lazy var timeStampLabel: LMLabel = {
        let label = LMLabel().translatesAutoresizingMaskIntoConstraints()
        label.font = Appearance.shared.fonts.textFont2
        label.textColor = Appearance.shared.colors.gray155
        label.text = "Timestamp"
        return label
    }()
    
    open private(set) lazy var contentLabel: LMLabel = {
        let label = LMLabel().translatesAutoresizingMaskIntoConstraints()
        label.font = Appearance.shared.fonts.textFont2
        label.textColor = Appearance.shared.colors.gray51
        label.text = "Dummy Comment"
        return label
    }()
    
    
    open var profilePictureHeight: CGFloat { 40 }
    
    
    // MARK: setupViews
    open override func setupViews() {
        super.setupViews()
        
        addSubview(containerView)
        
        containerView.addSubview(titleLabel)
        containerView.addSubview(containerStackView)
        
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
        
        titleLabel.addConstraint(top: (containerView.topAnchor, 16),
                                 leading: (containerView.leadingAnchor, 16),
                                 trailing: (containerView.trailingAnchor, -16))
        
        containerStackView.addConstraint(top: (titleLabel.bottomAnchor, 16),
                                         bottom: (containerView.bottomAnchor, -16),
                                         leading: (titleLabel.leadingAnchor, 0),
                                         trailing: (titleLabel.trailingAnchor, 0))
        
        profilePicture.setWidthConstraint(with: profilePictureHeight)
        profilePicture.setHeightConstraint(with: profilePicture.widthAnchor)
        
        contentContainerView.pinSubView(subView: contentStackView, padding: .init(top: 16, left: 16, bottom: -16, right: -16))
    }
    
    
    // MARK: setupAppearance
    open override func setupAppearance() {
        super.setupAppearance()
        
        contentContainerView.backgroundColor = Appearance.shared.colors.backgroundColor
        contentContainerView.layer.cornerRadius = 8
        
        contentStackView.clipsToBounds = true
        contentStackView.layer.masksToBounds = true
    }
    
    
    // MARK: configure
    open func configure(with data: LMFeedCommentContentModel) {
        
    }
}
