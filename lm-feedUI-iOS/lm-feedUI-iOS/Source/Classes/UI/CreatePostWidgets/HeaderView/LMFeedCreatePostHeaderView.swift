//
//  LMFeedCreatePostHeaderView.swift
//  lm-feedUI-iOS
//
//  Created by Devansh Mohata on 17/01/24.
//

import UIKit

@IBDesignable
open class LMFeedCreatePostHeaderView: LMFeedView {
    public struct ContentModel {
        let profileImage: String?
        let username: String
        
        public init(profileImage: String?, username: String) {
            self.profileImage = profileImage
            self.username = username
        }
    }
    
    open private(set) lazy var containerView: LMFeedView = {
        let view = LMFeedView().translatesAutoresizingMaskIntoConstraints()
        view.backgroundColor = .clear
        return view
    }()
    
    open private(set) lazy var stackView: LMFeedStackView = {
        let stack = LMFeedStackView().translatesAutoresizingMaskIntoConstraints()
        stack.axis = .horizontal
        stack.alignment = .center
        stack.distribution = .fill
        stack.spacing = 8
        return stack
    }()
    
    open private(set) lazy var imageContainerView: LMFeedView = {
        let view = LMFeedView().translatesAutoresizingMaskIntoConstraints()
        view.clipsToBounds = true
        view.backgroundColor = .clear
        return view
    }()
    
    open private(set) lazy var userProfileImage: LMFeedProfileImageView = {
        let image = LMFeedProfileImageView().translatesAutoresizingMaskIntoConstraints()
        image.clipsToBounds = true
        return image
    }()
    
    open private(set) lazy var userNameLabel: LMFeedLabel = {
        let label = LMFeedLabel().translatesAutoresizingMaskIntoConstraints()
        label.font = LMFeedAppearance.shared.fonts.headingFont1
        label.textColor = LMFeedAppearance.shared.colors.gray1
        label.text = "Devansh Mohata"
        return label
    }()
    
    
    // MARK: setupViews
    open override func setupViews() {
        super.setupViews()
        addSubview(containerView)
        containerView.addSubview(stackView)
        [imageContainerView, userNameLabel].forEach { subView in
            stackView.addArrangedSubview(subView)
        }
        
        imageContainerView.addSubview(userProfileImage)
    }
    
    
    // MARK: setupLayouts
    open override func setupLayouts() {
        super.setupLayouts()
        
        pinSubView(subView: containerView)
        containerView.pinSubView(subView: stackView)
        imageContainerView.addConstraint(top: (stackView.topAnchor, 8), bottom: (stackView.bottomAnchor, -8))
        imageContainerView.pinSubView(subView: userProfileImage)
        imageContainerView.widthAnchor.constraint(equalTo: imageContainerView.heightAnchor).isActive = true
    }
    
    
    // MARK: setupAppearance
    open override func setupAppearance() {
        super.setupAppearance()
        imageContainerView.roundCorners(with: 24)
    }
    
  
    // MARK: configure
    open func configure(with data: ContentModel) {
        userProfileImage.configure(with: data.profileImage, userName: data.username)
        userNameLabel.text = data.username
    }
}
