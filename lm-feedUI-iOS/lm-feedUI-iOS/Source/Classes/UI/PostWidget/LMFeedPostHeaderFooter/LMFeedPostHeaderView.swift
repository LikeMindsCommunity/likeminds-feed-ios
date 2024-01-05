//
//  LMFeedPostHeaderView.swift
//  LMFramework
//
//  Created by Devansh Mohata on 28/11/23.
//

import Kingfisher
import UIKit

public protocol LMFeedPostHeaderViewProtocol: AnyObject {
    func didTapProfilePicture()
    func didTapMenuButton()
}

@IBDesignable
open class LMFeedPostHeaderView: LMView {
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
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentContainerView.topAnchor, constant: 8),
            imageView.bottomAnchor.constraint(equalTo: contentContainerView.bottomAnchor, constant: -8),
            imageView.leadingAnchor.constraint(equalTo: contentContainerView.leadingAnchor, constant: 16),
            imageView.centerYAnchor.constraint(equalTo: outerStackView.centerYAnchor),
            imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor, multiplier: 1),
            imageView.heightAnchor.constraint(equalToConstant: Constants.shared.number.imageSize),
            
            outerStackView.bottomAnchor.constraint(greaterThanOrEqualTo: imageView.bottomAnchor),
            outerStackView.topAnchor.constraint(greaterThanOrEqualTo: imageView.topAnchor),
            outerStackView.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 16),
            outerStackView.trailingAnchor.constraint(equalTo: contentContainerView.trailingAnchor, constant: -16),
            
            innerStackView.topAnchor.constraint(greaterThanOrEqualTo: outerStackView.topAnchor),
            innerStackView.bottomAnchor.constraint(greaterThanOrEqualTo: outerStackView.bottomAnchor),
            
            menuButton.widthAnchor.constraint(equalToConstant: 24),
            menuButton.topAnchor.constraint(equalTo: outerStackView.topAnchor),
            menuButton.bottomAnchor.constraint(equalTo: outerStackView.bottomAnchor),
            
            pinButton.widthAnchor.constraint(equalToConstant: 24),
            pinButton.topAnchor.constraint(equalTo: outerStackView.topAnchor),
            pinButton.bottomAnchor.constraint(equalTo: outerStackView.bottomAnchor),
            
            contentContainerView.topAnchor.constraint(equalTo: topAnchor),
            contentContainerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentContainerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            contentContainerView.bottomAnchor.constraint(greaterThanOrEqualTo: bottomAnchor)
        ])
        
        pinButton.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        menuButton.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        
        authorNameLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        authorTagLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        
        let tagLabelWidthConstraint = NSLayoutConstraint(item: authorTagLabel, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 0)
        tagLabelWidthConstraint.priority = .defaultLow
        tagLabelWidthConstraint.isActive = true
    }
    
    // MARK: Actions
    open override func setupActions() {
        super.setupActions()
        
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapProfilePicture)))
        menuButton.addTarget(self, action: #selector(didTapMenuButton), for: .touchUpInside)
    }
    
    // MARK: Appearance
    open override func setupAppearance() {
        super.setupAppearance()
        
        backgroundColor = .clear
        contentContainerView.backgroundColor = .white
        imageView.layer.cornerRadius = Constants.shared.number.imageSize / 2
    }
    
    open func configure(with data: ViewModel) {
        imageView.kf.setImage(with: URL(string: data.profileImage ?? ""), placeholder: Constants.shared.images.placeholderProfileImage)
        
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
        delegate?.didTapProfilePicture()
    }
    
    open func didTapMenuButton() { 
        delegate?.didTapMenuButton()
    }
}
