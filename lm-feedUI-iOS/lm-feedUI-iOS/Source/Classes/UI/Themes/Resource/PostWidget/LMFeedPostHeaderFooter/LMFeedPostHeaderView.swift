//
//  LMFeedPostHeaderView.swift
//  LMFramework
//
//  Created by Devansh Mohata on 28/11/23.
//

import UIKit

public protocol LMFeedPostHeaderViewProtocol: AnyObject {
    func didTapProfilePicture(having uuid: String)
    func didTapPostMenuButton(for postID: String)
    func didTapPost(postID: String)
}

@IBDesignable
open class LMFeedPostHeaderView: LMTableViewHeaderFooterView {
    public struct ContentModel {
        public let profileImage: String?
        public let authorName: String
        public let authorTag: String?
        public let subtitle: String?
        public var isPinned: Bool
        public let showMenu: Bool
        
        public init(profileImage: String?, authorName: String, authorTag: String?, subtitle: String?, isPinned: Bool, showMenu: Bool) {
            self.profileImage = profileImage
            self.authorName = authorName
            self.authorTag = authorTag
            self.subtitle = subtitle
            self.isPinned = isPinned
            self.showMenu = showMenu
        }
    }
    
    // MARK: UI Elements
    open private(set) lazy var contentContainerView: LMView = {
        let view = LMView()
        view.contentMode = .scaleToFill
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = LMFeedAppearance.shared.colors.clear
        return view
    }()

    open private(set) lazy var imageView: LMFeedProfileImageView = {
        let imageView = LMFeedProfileImageView(frame: .zero)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    open private(set) lazy var outerStackView: LMStackView = {
        let stackView = LMStackView().translatesAutoresizingMaskIntoConstraints()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.backgroundColor = LMFeedAppearance.shared.colors.clear
        stackView.spacing = 8
        return stackView
    }()

    open private(set) lazy var innerStackView: LMStackView = {
        let stackView = LMStackView().translatesAutoresizingMaskIntoConstraints()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.backgroundColor = LMFeedAppearance.shared.colors.clear
        return stackView
    }()

    open private(set) lazy var pinButton: LMButton = {
        let button = LMButton().translatesAutoresizingMaskIntoConstraints()
        button.contentMode = .scaleToFill
        button.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        button.contentHorizontalAlignment = .center
        button.contentVerticalAlignment = .center
        button.tintColor = LMFeedAppearance.shared.colors.gray2
        button.setImage(UIImage(systemName: "pin.circle"), for: .normal)
        return button
    }()

    open private(set) lazy var menuButton: LMButton = {
        let button = LMButton().translatesAutoresizingMaskIntoConstraints()
        button.contentMode = .scaleToFill
        button.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        button.contentHorizontalAlignment = .center
        button.contentVerticalAlignment = .center
        button.tintColor = LMFeedAppearance.shared.colors.gray2
        button.setImage(UIImage(systemName: "ellipsis"), for: .normal)
        return button
    }()

    open private(set) lazy var authorStackView: LMStackView = {
        let stackView = LMStackView().translatesAutoresizingMaskIntoConstraints()
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 4
        stackView.backgroundColor = LMFeedAppearance.shared.colors.clear
        return stackView
    }()

    open private(set) lazy var subTitleLabel: LMLabel = {
        let label = LMLabel().translatesAutoresizingMaskIntoConstraints()
        label.contentMode = .left
        label.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        label.text = "2d • Edited"
        label.textAlignment = .natural
        label.lineBreakMode = .byTruncatingTail
        label.baselineAdjustment = .alignBaselines
        label.adjustsFontSizeToFitWidth = false
        label.font = LMFeedAppearance.shared.fonts.subHeadingFont1
        label.textColor = LMFeedAppearance.shared.colors.gray3
        return label
    }()

    open private(set) lazy var authorNameLabel: LMLabel = {
        let label = LMLabel().translatesAutoresizingMaskIntoConstraints()
        label.contentMode = .left
        label.text = "Theresa Webb"
        label.textAlignment = .natural
        label.lineBreakMode = .byTruncatingTail
        label.font = LMFeedAppearance.shared.fonts.headingFont1
        label.textColor = LMFeedAppearance.shared.colors.gray1
        label.isUserInteractionEnabled = true
        return label
    }()

    open private(set) lazy var authorTagLabel: LMLabel = {
        let label = LMLabel().translatesAutoresizingMaskIntoConstraints()
        label.contentMode = .left
        label.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        label.text = "Admin"
        label.clipsToBounds = true
        label.textColor = LMFeedAppearance.shared.colors.white
        label.adjustsFontSizeToFitWidth = true
        label.setPadding(with: .init(top: 2, left: 8, bottom: 2, right: 8))
        label.layer.cornerRadius = 2
        label.textAlignment = .natural
        label.lineBreakMode = .byTruncatingTail
        label.adjustsFontSizeToFitWidth = true
        label.font = LMFeedAppearance.shared.fonts.headingFont1
        label.backgroundColor = LMFeedAppearance.shared.colors.appTintColor
        return label
    }()
    
    open private(set) lazy var spacerView: LMView = {
        let view = LMView().translatesAutoresizingMaskIntoConstraints()
        view.backgroundColor = LMFeedAppearance.shared.colors.clear
        return view
    }()

    // MARK: Data Variables
    public weak var delegate: LMFeedPostHeaderViewProtocol?
    public var userUUID: String?
    public var postID: String?
    
    // MARK: View Hierachy
    open override func setupViews() {
        super.setupViews()
        
        addSubview(contentContainerView)
        
        contentContainerView.addSubview(imageView)
        contentContainerView.addSubview(outerStackView)
        
        [innerStackView, spacerView, pinButton, menuButton].forEach { subView in
            outerStackView.addArrangedSubview(subView)
        }
        
        innerStackView.addArrangedSubview(authorStackView)
        innerStackView.addArrangedSubview(subTitleLabel)
        
        authorStackView.addArrangedSubview(authorNameLabel)
        authorStackView.addArrangedSubview(authorTagLabel)
    }

    // MARK: -  Constraints
    open override func setupLayouts() {
        super.setupLayouts()
        
        pinSubView(subView: contentContainerView, padding: .init(top: 4, left: 0, bottom: 0, right: 0))
        
        imageView.addConstraint(top: (contentContainerView.topAnchor, 8),
                                bottom: (contentContainerView.bottomAnchor, -8),
                                leading: (contentContainerView.leadingAnchor, 16),
                                centerY: (outerStackView.centerYAnchor, 0))
        
        imageView.setWidthConstraint(with: imageView.heightAnchor)
        
        outerStackView.addConstraint(top: (imageView.topAnchor, 0),
                                     bottom: (imageView.bottomAnchor, 0),
                                     leading: (imageView.trailingAnchor, 16),
                                     trailing: (contentContainerView.trailingAnchor, -16))
        
        innerStackView.topAnchor.constraint(greaterThanOrEqualTo: outerStackView.topAnchor).isActive = true
        innerStackView.bottomAnchor.constraint(lessThanOrEqualTo: outerStackView.bottomAnchor).isActive = true
        
        menuButton.setWidthConstraint(with: 24)
        menuButton.addConstraint(top: (outerStackView.topAnchor, 0),
                                     bottom: (outerStackView.bottomAnchor, 0))
        
        pinButton.setWidthConstraint(with: 24)
        pinButton.addConstraint(top: (outerStackView.topAnchor, 0),
                                     bottom: (outerStackView.bottomAnchor, 0))
        
        pinButton.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        menuButton.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        
        authorTagLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        authorTagLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        
        authorNameLabel.setWidthConstraint(with: 0, priority: .defaultLow)
    }
    
    // MARK: Actions
    open override func setupActions() {
        super.setupActions()
        
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapProfilePicture)))
        authorNameLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapProfilePicture)))
        menuButton.addTarget(self, action: #selector(didTapMenuButton), for: .touchUpInside)
        contentContainerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapPost)))
    }
    
    // MARK: Appearance
    open override func setupAppearance() {
        super.setupAppearance()
        
        backgroundView = nil
        contentContainerView.backgroundColor = .white
        imageView.roundCorners(with: 48/2)
    }
    
    open func configure(with data: ContentModel, postID: String, userUUID: String, delegate: LMFeedPostHeaderViewProtocol?) {
        self.postID = postID
        self.userUUID = userUUID
        self.delegate = delegate
        
        imageView.configure(with: data.profileImage, userName: data.authorName)
        
        authorNameLabel.text = data.authorName
        authorTagLabel.text = data.authorTag
        authorTagLabel.isHidden = data.authorTag?.isEmpty != false
        
        subTitleLabel.text = data.subtitle
        subTitleLabel.isHidden = data.subtitle?.isEmpty != false
        
        pinButton.isHidden = !data.isPinned
        menuButton.isHidden = !data.showMenu
    }
    
    open func togglePinStatus(isPinned: Bool) {
        pinButton.isHidden = !isPinned
    }
}

// MARK: Actions
@objc
extension LMFeedPostHeaderView {
    open func didTapProfilePicture() {
        guard let userUUID else { return }
        delegate?.didTapProfilePicture(having: userUUID)
    }
    
    open func didTapMenuButton() { 
        guard let postID else { return }
        delegate?.didTapPostMenuButton(for: postID)
    }
    
    open func didTapPost() {
        guard let postID else { return }
        delegate?.didTapPost(postID: postID)
    }
}
