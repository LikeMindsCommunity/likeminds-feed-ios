//
//  LMFeedNotificationView.swift
//  lm-feedUI-iOS
//
//  Created by Devansh Mohata on 21/01/24.
//

import UIKit

@IBDesignable
open class LMFeedNotificationView: LMTableViewCell {
    public struct ContentModel {
        public let notificationID: String
        public let notification: String
        public let user: LMFeedUserDataModel
        public let time: String
        public let isRead: Bool
        public let mediaImage: String?
        public let route: String
        
        public init(notificationID: String, notification: String, user: LMFeedUserDataModel, time: String, isRead: Bool, mediaImage: String?, route: String) {
            self.notificationID = notificationID
            self.notification = notification
            self.user = user
            self.time = time
            self.isRead = isRead
            self.mediaImage = mediaImage
            self.route = route
        }
    }
    
    // MARK: UI Elements    
    open private(set) lazy var userImage: LMImageView = {
        let image = LMImageView().translatesAutoresizingMaskIntoConstraints()
        image.clipsToBounds = true
        return image
    }()
    
    open private(set) lazy var mediaContainerView: LMView = {
        let view = LMView().translatesAutoresizingMaskIntoConstraints()
        view.backgroundColor = Appearance.shared.colors.appTintColor
        return view
    }()
    
    open private(set) lazy var mediaImage: LMImageView = {
        let image = LMImageView().translatesAutoresizingMaskIntoConstraints()
        image.clipsToBounds = true
        image.tintColor = Appearance.shared.colors.white
        image.contentMode = .scaleAspectFit
        return image
    }()
    
    open private(set) lazy var contentStack: LMStackView = {
        let stack = LMStackView().translatesAutoresizingMaskIntoConstraints()
        stack.axis = .vertical
        stack.alignment = .fill
        stack.distribution = .fill
        stack.spacing = 8
        return stack
    }()
    
    open private(set) lazy var titleLabel: LMLabel = {
        let label = LMLabel().translatesAutoresizingMaskIntoConstraints()
        label.font = Appearance.shared.fonts.headingFont3
        label.textColor = Appearance.shared.colors.black
        label.numberOfLines = 4
        return label
    }()
    
    open private(set) lazy var timeLabel: LMLabel = {
        let label = LMLabel().translatesAutoresizingMaskIntoConstraints()
        label.font = Appearance.shared.fonts.subHeadingFont2
        label.textColor = Appearance.shared.colors.gray155
        return label
    }()
    
    
    // MARK: Data Variables
    public var userImageHeight: CGFloat = 48
    public var mediaImageHeight: CGFloat = 26
    public var onTapCallback: (() -> Void)?
    
    // MARK: setupViews
    open override func setupViews() {
        super.setupViews()
        
        contentView.addSubview(containerView)
        
        [userImage, mediaContainerView, contentStack].forEach { subview in
            containerView.addSubview(subview)
        }
        
        mediaContainerView.addSubview(mediaImage)
        
        contentStack.addArrangedSubview(titleLabel)
        contentStack.addArrangedSubview(timeLabel)
    }
    
    
    // MARK: setupLayouts
    open override func setupLayouts() {
        super.setupLayouts()
        
        containerView.addConstraint(top: (contentView.topAnchor, 0),
                                    leading: (contentView.leadingAnchor, 0),
                                    trailing: (contentView.trailingAnchor, 0))
        
        containerView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor).isActive = true
        
        userImage.addConstraint(top: (containerView.topAnchor, 16),
                                leading: (containerView.leadingAnchor, 16),
                                trailing: (contentStack.leadingAnchor, -16))
        userImage.setHeightConstraint(with: userImageHeight)
        userImage.widthAnchor.constraint(equalTo: userImage.heightAnchor, multiplier: 1).isActive = true
        
        mediaContainerView.addConstraint(trailing: (userImage.trailingAnchor, 0),
                                 centerY: (userImage.bottomAnchor, 0))
        mediaContainerView.setHeightConstraint(with: mediaImageHeight)
        mediaContainerView.setWidthConstraint(with: mediaImageHeight)
        mediaContainerView.bottomAnchor.constraint(lessThanOrEqualTo: containerView.bottomAnchor, constant: -16).isActive = true
        
        mediaContainerView.pinSubView(subView: mediaImage, padding: .init(top: 6, left: 6, bottom: -6, right: -6))
        
        contentStack.topAnchor.constraint(equalTo: userImage.topAnchor).isActive = true
        contentStack.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16).isActive = true
        
        let bottomConstraint = contentStack.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16)
        bottomConstraint.priority = .defaultLow
        bottomConstraint.isActive = true
        
        let heightConstraint = contentStack.heightAnchor.constraint(equalToConstant: 16)
        heightConstraint.priority = .defaultLow
        heightConstraint.isActive = true
        
        titleLabel.setContentHuggingPriority(.defaultLow, for: .vertical)
    }
    
    
    // MARK: setupActions
    open override func setupActions() {
        super.setupActions()
        containerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapNotificationView)))
    }
    
    @objc
    open func didTapNotificationView() {
        onTapCallback?()
    }
    
    // MARK: setupAppearance
    open override func setupAppearance() {
        super.setupAppearance()
        
        userImage.layer.cornerRadius = userImageHeight / 2
        mediaContainerView.layer.cornerRadius = mediaImageHeight / 2
    }
    
    // MARK: configure
    open func configure(with data: ContentModel, onTapCallback: (() -> Void)?) {
        self.onTapCallback = onTapCallback
        
        titleLabel.attributedText = GetAttributedTextWithRoutes.getAttributedText(from: data.notification)
        timeLabel.text = data.time
        userImage.kf.setImage(with: URL(string: data.user.userProfileImage ?? ""), placeholder: LMImageView.generateLetterImage(name: data.user.userName))
        mediaImage.image = Constants.Images.loadSystemImage(with: data.mediaImage ?? "")
        mediaContainerView.isHidden = data.mediaImage?.isEmpty != false
        
        containerView.backgroundColor = data.isRead ? Appearance.shared.colors.white : Appearance.shared.colors.notificationBackgroundColor
    }
}
