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
    public struct ViewDataModel {
        let profileImage: String?
        let username: String
        let isEditFlow: Bool
        
        public init(profileImage: String?, username: String, isEditFlow: Bool = false) {
            self.profileImage = profileImage
            self.username = username
            self.isEditFlow = isEditFlow
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
        return stack
    }()
    
    open private(set) lazy var imageContainerView: LMView = {
        let view = LMView().translatesAutoresizingMaskIntoConstraints()
        view.backgroundColor = .clear
        return view
    }()
    
    open private(set) lazy var userProfileImage: LMImageView = {
        let image = LMImageView().translatesAutoresizingMaskIntoConstraints()
        return image
    }()
    
    open private(set) lazy var userNameLabel: LMLabel = {
        let label = LMLabel().translatesAutoresizingMaskIntoConstraints()
        label.font = Appearance.shared.fonts.headingFont1
        label.textColor = Appearance.shared.colors.gray1
        return label
    }()
    
    open private(set) lazy var editAuthorButton: LMButton = {
        let button = LMButton().translatesAutoresizingMaskIntoConstraints()
        button.setTitle(nil, for: .normal)
        button.setImage(Constants.shared.images.pencilIcon, for: .normal)
        return button
    }()
    
    
    // MARK: setupViews
    open override func setupViews() {
        super.setupViews()
        addSubview(containerView)
        containerView.addSubview(stackView)
        [imageContainerView, userNameLabel, editAuthorButton].forEach { subView in
            stackView.addArrangedSubview(subView)
        }
        
        imageContainerView.addSubview(userProfileImage)
    }
    
    
    // MARK: setupLayouts
    open override func setupLayouts() {
        super.setupLayouts()
        
        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            stackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            stackView.trailingAnchor.constraint(greaterThanOrEqualTo: containerView.trailingAnchor),
            stackView.topAnchor.constraint(equalTo: containerView.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            
            imageContainerView.topAnchor.constraint(equalTo: stackView.topAnchor),
            imageContainerView.bottomAnchor.constraint(equalTo: stackView.bottomAnchor),
            
            editAuthorButton.topAnchor.constraint(greaterThanOrEqualTo: stackView.topAnchor),
            editAuthorButton.bottomAnchor.constraint(greaterThanOrEqualTo: stackView.bottomAnchor),
            
            userNameLabel.topAnchor.constraint(equalTo: stackView.topAnchor),
            userNameLabel.bottomAnchor.constraint(equalTo: stackView.bottomAnchor),
            
            userProfileImage.leadingAnchor.constraint(equalTo: imageContainerView.leadingAnchor),
            userProfileImage.trailingAnchor.constraint(equalTo: imageContainerView.trailingAnchor),
            userProfileImage.topAnchor.constraint(equalTo: imageContainerView.topAnchor),
            userProfileImage.bottomAnchor.constraint(equalTo: imageContainerView.bottomAnchor),
            
            imageContainerView.widthAnchor.constraint(equalTo: imageContainerView.heightAnchor),
            editAuthorButton.widthAnchor.constraint(equalTo: editAuthorButton.heightAnchor)
        ])
    }
    
    
    // MARK: setupAppearance
    open override func setupAppearance() {
        super.setupAppearance()
        
        userProfileImage.layer.cornerRadius = userProfileImage.frame.height / 2
    }
    
  
    // MARK: configure
    open func configure(with data: ViewDataModel) {
        userProfileImage.kf.setImage(with: URL(string: data.profileImage ?? ""))
        userNameLabel.text = data.username
        editAuthorButton.isHidden = !data.isEditFlow
    }
}
