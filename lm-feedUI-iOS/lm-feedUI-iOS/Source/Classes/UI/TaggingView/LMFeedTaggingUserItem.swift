//
//  LMFeedTaggingUserItem.swift
//  lm-feedUI-iOS
//
//  Created by Devansh Mohata on 08/01/24.
//

import UIKit

@IBDesignable
open class LMFeedTaggingUserItem: LMTableViewCell {
    public struct ContentModel {
        public let userImage: String?
        public let userName: String
        public let route: String
        
        public init(userImage: String?, userName: String, route: String) {
            self.userImage = userImage
            self.userName = userName
            self.route = route
        }
    }
    
    
    // MARK: UI Elements
    open private(set) lazy var userImage: LMFeedProfileImageView = {
        let image = LMFeedProfileImageView().translatesAutoresizingMaskIntoConstraints()
        image.clipsToBounds = true
        return image
    }()
    
    open private(set) lazy var userNameLabel: LMLabel = {
        let label = LMLabel().translatesAutoresizingMaskIntoConstraints()
        return label
    }()
    
    open private(set) lazy var sepratorView: LMView = {
        let view = LMView().translatesAutoresizingMaskIntoConstraints()
        return view
    }()
    
    
    // MARK: setupViews
    open override func setupViews() {
        super.setupViews()
        
        contentView.addSubview(containerView)
        containerView.addSubview(userImage)
        containerView.addSubview(userNameLabel)
        containerView.addSubview(sepratorView)
    }
    
    
    // MARK: setupLayouts
    open override func setupLayouts() {
        super.setupLayouts()
        
//        contentView.pinSubView(subView: containerView)
        containerView.addConstraint(top: (contentView.topAnchor, 0),
                                    leading: (contentView.leadingAnchor, 0),
                                    trailing: (contentView.trailingAnchor, 0))
        containerView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor).isActive = true
        
        userImage.addConstraint(top: (containerView.topAnchor, 8),
                                leading: (containerView.leadingAnchor, 16))
        userImage.setHeightConstraint(with: 36)
        userImage.setWidthConstraint(with: userImage.heightAnchor)
        
        
        userNameLabel.addConstraint(leading: (userImage.trailingAnchor, 8),
                                    trailing: (containerView.trailingAnchor, 8),
                                    centerY: (userImage.centerYAnchor, 0))
        
        sepratorView.addConstraint( top: (userImage.bottomAnchor, 12),
                                    bottom: (containerView.bottomAnchor, 0),
                                    leading: (userNameLabel.leadingAnchor, 0),
                                    trailing: (userNameLabel.trailingAnchor, 0))
        sepratorView.setHeightConstraint(with: 1)
    }
    
    
    // MARK: setupAppearance
    open override func setupAppearance() {
        super.setupAppearance()
        
        sepratorView.backgroundColor = LMFeedAppearance.shared.colors.gray4
        userImage.roundCorners(with: userImage.bounds.height / 2)
        userNameLabel.font = LMFeedAppearance.shared.fonts.textFont1
        userNameLabel.textColor = LMFeedAppearance.shared.colors.textColor
        
        backgroundColor = LMFeedAppearance.shared.colors.clear
        contentView.backgroundColor = LMFeedAppearance.shared.colors.clear
        containerView.backgroundColor = LMFeedAppearance.shared.colors.clear
    }
    
    
    // MARK: configure
    open func configure(with data: ContentModel) {
        userNameLabel.text = data.userName
        userImage.configure(with: data.userImage, userName: data.userName)
    }
}
