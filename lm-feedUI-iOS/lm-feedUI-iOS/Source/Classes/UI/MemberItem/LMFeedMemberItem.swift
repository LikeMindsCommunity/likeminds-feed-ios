//
//  LMFeedMemberItem.swift
//  lm-feedUI-iOS
//
//  Created by Devansh Mohata on 21/01/24.
//

import Kingfisher
import UIKit

@IBDesignable
open class LMFeedMemberItem: LMTableViewCell {
    public struct ContentModel {
        public let username: String
        public let uuid: String
        public let customTitle: String?
        public let profileImage: String?
        
        public init(username: String, uuid: String, customTitle: String?, profileImage: String?) {
            self.username = username
            self.uuid = uuid
            self.customTitle = customTitle
            self.profileImage = profileImage
        }
    }
    
    // MARK: UI Elements
    open private(set) lazy var userImage: LMImageView = {
        let image = LMImageView().translatesAutoresizingMaskIntoConstraints()
        image.clipsToBounds = true
        return image
    }()
    
    open private(set) lazy var userTitleLabel: LMLabel = {
        let label = LMLabel().translatesAutoresizingMaskIntoConstraints()
        label.font = Appearance.shared.fonts.buttonFont1
        return label
    }()
    
    // MARK: Data Variables
    public var onTapCallback: (() -> Void)?
    
    
    // MARK: setupViews
    open override func setupViews() {
        super.setupViews()
        
        contentView.addSubview(containerView)
        containerView.addSubview(userImage)
        containerView.addSubview(userTitleLabel)
    }
    
    
    // MARK: setupLayouts
    open override func setupLayouts() {
        super.setupLayouts()
        
        contentView.pinSubView(subView: containerView)
        
        userImage.addConstraint(top: (containerView.topAnchor, 16),
                                bottom: (containerView.bottomAnchor, 0),
                                leading: (containerView.leadingAnchor, 16),
                                trailing: (userTitleLabel.leadingAnchor, -16))
        userImage.widthAnchor.constraint(equalTo: userImage.heightAnchor, multiplier: 1).isActive = true
        
        userTitleLabel.trailingAnchor.constraint(lessThanOrEqualTo: containerView.trailingAnchor, constant: -16).isActive = true
        userTitleLabel.centerYAnchor.constraint(equalTo: userImage.centerYAnchor).isActive = true
    }
    
    
    // MARK: setupActions
    open override func setupActions() {
        containerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapMemberItem)))
    }
    
    @objc
    open func didTapMemberItem() {
        onTapCallback?()
    }
    
    open override func setupAppearance() {
        super.setupAppearance()
        userImage.layer.cornerRadius = userImage.frame.height / 2
    }
    
    
    // MARK: configure
    open func configure(with data: ContentModel, onTapCallback: (() -> Void)?) {
        self.onTapCallback = onTapCallback
        userTitleLabel.attributedText = setUsername(with: data.username, customTitle: data.customTitle)
        userImage.kf.setImage(with: URL(string: data.profileImage ?? ""), placeholder: LMImageView.generateLetterImage(name: data.username))
    }
    
    public func setUsername(with username: String, customTitle: String?) -> NSMutableAttributedString {
        let attrString = NSMutableAttributedString(string: username, attributes: [.font: Appearance.shared.fonts.headingFont1,
                                                                                  .foregroundColor: Appearance.shared.colors.black])
        
        if let customTitle,
           !customTitle.isEmpty {
            attrString.append(NSAttributedString(string: " • \(customTitle)", attributes: [.font: Appearance.shared.fonts.subHeadingFont2,
                                                                                   .foregroundColor: Appearance.shared.colors.appTintColor]))
        }
        
        return attrString
    }
}
