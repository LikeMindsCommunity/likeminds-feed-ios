//
//  LMFeedPostHeaderView.swift
//  LMFramework
//
//  Created by Devansh Mohata on 28/11/23.
//

import Kingfisher
import UIKit

public protocol LMFeedPostHeaderViewProtocol: AnyObject {
    func didTapProfilePicture(having uuid: String)
    func didTapMenuButton(for postID: String)
    func didTapPost(postID: String)
}

@IBDesignable
open class LMFeedPostHeaderView: LMTableViewHeaderFooterView {
    public struct ViewModel {
        let profileImage: String?
        let authorName: String
        let authorTag: String?
        let subtitle: String?
        let isPinned: Bool
        let showMenu: Bool
        
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
        view.backgroundColor = Appearance.shared.colors.clear
        return view
    }()

    open private(set) lazy var imageView: UIImageView = {
        let imageView = UIImageView(frame: .zero)
        imageView.clipsToBounds = true
        imageView.isUserInteractionEnabled = true
        imageView.layer.masksToBounds = true
        imageView.image = UIImage(systemName: "person")
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    open private(set) lazy var outerStackView: LMStackView = {
        let stackView = LMStackView().translatesAutoresizingMaskIntoConstraints()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.backgroundColor = Appearance.shared.colors.clear
        stackView.spacing = 8
        return stackView
    }()

    open private(set) lazy var innerStackView: LMStackView = {
        let stackView = LMStackView().translatesAutoresizingMaskIntoConstraints()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.backgroundColor = Appearance.shared.colors.clear
        return stackView
    }()

    open private(set) lazy var pinButton: LMButton = {
        let button = LMButton().translatesAutoresizingMaskIntoConstraints()
        button.contentMode = .scaleToFill
        button.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        button.contentHorizontalAlignment = .center
        button.contentVerticalAlignment = .center
        button.tintColor = Appearance.shared.colors.gray2
        button.setImage(UIImage(systemName: "pin.circle"), for: .normal)
        return button
    }()

    open private(set) lazy var menuButton: LMButton = {
        let button = LMButton().translatesAutoresizingMaskIntoConstraints()
        button.contentMode = .scaleToFill
        button.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        button.contentHorizontalAlignment = .center
        button.contentVerticalAlignment = .center
        button.tintColor = Appearance.shared.colors.gray2
        button.setImage(UIImage(systemName: "ellipsis"), for: .normal)
        return button
    }()

    open private(set) lazy var authorStackView: LMStackView = {
        let stackView = LMStackView().translatesAutoresizingMaskIntoConstraints()
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 4
        stackView.backgroundColor = Appearance.shared.colors.clear
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
        label.font = Appearance.shared.fonts.subHeadingFont1
        label.textColor = Appearance.shared.colors.gray3
        return label
    }()

    open private(set) lazy var authorNameLabel: LMLabel = {
        let label = LMLabel().translatesAutoresizingMaskIntoConstraints()
        label.contentMode = .left
        label.text = "Theresa Webb"
        label.textAlignment = .natural
        label.lineBreakMode = .byTruncatingTail
        label.font = Appearance.shared.fonts.headingFont1
        label.textColor = Appearance.shared.colors.gray1
        label.isUserInteractionEnabled = true
        return label
    }()

    open private(set) lazy var authorTagLabel: LMLabel = {
        let label = LMLabel().translatesAutoresizingMaskIntoConstraints()
        label.contentMode = .left
        label.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        label.text = "Admin"
        label.clipsToBounds = true
        label.textColor = Appearance.shared.colors.white
        label.adjustsFontSizeToFitWidth = true
        label.setPadding(with: .init(top: 2, left: 8, bottom: 2, right: 8))
        label.layer.cornerRadius = 2
        label.textAlignment = .natural
        label.lineBreakMode = .byTruncatingTail
        label.adjustsFontSizeToFitWidth = true
        label.font = Appearance.shared.fonts.headingFont2
        label.backgroundColor = Appearance.shared.colors.appTintColor
        return label
    }()
    
    open private(set) lazy var spacerView: LMView = {
        let view = LMView().translatesAutoresizingMaskIntoConstraints()
        view.backgroundColor = Appearance.shared.colors.clear
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
        
        authorNameLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        authorTagLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        
        authorTagLabel.setWidthConstraint(with: 0, priority: .defaultLow)
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
        
        backgroundColor = .clear
        contentContainerView.backgroundColor = .white
        imageView.layer.cornerRadius = 48 / 2
    }
    
    open func configure(with data: ViewModel, postID: String, userUUID: String, delegate: LMFeedPostHeaderViewProtocol?) {
        self.postID = postID
        self.userUUID = userUUID
        self.delegate = delegate
        
        imageView.kf.setImage(with: URL(string: data.profileImage ?? ""), placeholder: LMImageView.generateLetterImage(name: data.authorName))
        
        authorNameLabel.text = data.authorName
        authorTagLabel.text = data.authorTag
        authorTagLabel.isHidden = data.authorTag?.isEmpty != false
        
        subTitleLabel.text = data.subtitle
        subTitleLabel.isHidden = data.subtitle?.isEmpty != false
        
        pinButton.isHidden = !data.isPinned
        menuButton.isHidden = !data.showMenu
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
        delegate?.didTapMenuButton(for: postID)
    }
    
    open func didTapPost() {
        guard let postID else { return }
        delegate?.didTapPost(postID: postID)
    }
}
