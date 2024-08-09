//
//  LMFeedCreatePostHeaderView.swift
//  lm-feedUI-iOS
//
//  Created by Devansh Mohata on 17/01/24.
//

import Kingfisher
import UIKit

@IBDesignable
open class LMFeedCreatePostHeaderView: LMView {
    public struct ContentModel {
        let profileImage: String?
        let username: String
        
        public init(profileImage: String?, username: String) {
            self.profileImage = profileImage
            self.username = username
        }
    }
    
    open private(set) lazy var containerView: LMView = {
        let view = LMView().translatesAutoresizingMaskIntoConstraints()
        view.backgroundColor = .clear
        return view
    }()
    
    open private(set) lazy var stackView: LMStackView = {
        let stack = LMStackView().translatesAutoresizingMaskIntoConstraints()
        stack.axis = .horizontal
        stack.alignment = .center
        stack.distribution = .fill
        stack.spacing = 8
        return stack
    }()
    
    open private(set) lazy var imageContainerView: LMView = {
        let view = LMView().translatesAutoresizingMaskIntoConstraints()
        view.clipsToBounds = true
        view.backgroundColor = .clear
        return view
    }()
    
    open private(set) lazy var userProfileImage: LMImageView = {
        let image = LMImageView().translatesAutoresizingMaskIntoConstraints()
        image.image = UIImage(systemName: "person.circle.fill")
        image.clipsToBounds = true
        return image
    }()
    
    open private(set) lazy var userNameLabel: LMLabel = {
        let label = LMLabel().translatesAutoresizingMaskIntoConstraints()
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
        imageContainerView.layer.cornerRadius = 24
    }
    
  
    // MARK: configure
    open func configure(with data: ContentModel) {
        userProfileImage.kf.setImage(with: URL(string: data.profileImage ?? ""), placeholder: LMImageView.generateLetterImage(name: data.username))
        userNameLabel.text = data.username
    }
}
