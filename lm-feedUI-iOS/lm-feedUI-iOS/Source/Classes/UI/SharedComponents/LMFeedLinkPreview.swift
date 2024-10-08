//
//  LMFeedCreatePostLinkPreview.swift
//  lm-feedUI-iOS
//
//  Created by Devansh Mohata on 17/01/24.
//

import UIKit

@IBDesignable
open class LMFeedLinkPreview: LMView {
    public struct ContentModel: LMFeedMediaProtocol {
        let linkPreview: String?
        let title: String?
        let description: String?
        let url: String
        
        public init(linkPreview: String?, title: String?, description: String?, url: String) {
            self.linkPreview = linkPreview
            self.title = title
            self.description = description
            self.url = url
        }
    }
    
    
    // MARK: UI Elements
    open private(set) lazy var containerView: LMView = {
        let view = LMView().translatesAutoresizingMaskIntoConstraints()
        view.backgroundColor = LMFeedAppearance.shared.colors.clear
        view.clipsToBounds = true
        return view
    }()
    
    open private(set) lazy var containerStackView: LMStackView = {
        let stack = LMStackView().translatesAutoresizingMaskIntoConstraints()
        stack.axis = .vertical
        stack.alignment = .fill
        stack.distribution = .fill
        return stack
    }()
        
    open private(set) lazy var crossButton: LMButton = {
        let button = LMButton().translatesAutoresizingMaskIntoConstraints()
        button.setTitle(nil, for: .normal)
        button.setImage(LMFeedConstants.shared.images.xmarkIcon, for: .normal)
        button.backgroundColor = LMFeedAppearance.shared.colors.white
        button.tintColor = LMFeedAppearance.shared.colors.gray51
        button.contentMode = .scaleAspectFit
        return button
    }()
    
    open private(set) lazy var imageView: LMImageView = {
        let image = LMImageView().translatesAutoresizingMaskIntoConstraints()
        image.contentMode = .scaleAspectFill
        image.clipsToBounds = true
        image.layer.masksToBounds = true
        return image
    }()
    
    open private(set) lazy var sepratorView: LMView = {
        let view = LMView().translatesAutoresizingMaskIntoConstraints()
        view.backgroundColor = LMFeedAppearance.shared.colors.gray3
        return view
    }()
    
    open private(set) lazy var metaDataContainerView: LMView = {
        let view = LMView().translatesAutoresizingMaskIntoConstraints()
        view.backgroundColor = LMFeedAppearance.shared.colors.clear
        return view
    }()
    
    open private(set) lazy var metaDataStackView: LMStackView = {
        let stack = LMStackView().translatesAutoresizingMaskIntoConstraints()
        stack.axis = .vertical
        stack.alignment = .fill
        stack.distribution = .fill
        stack.spacing = 4
        return stack
    }()
    
    open private(set) lazy var titleLabel: LMLabel = {
        let label = LMLabel().translatesAutoresizingMaskIntoConstraints()
        label.text = "Trial Text"
        label.numberOfLines = 2
        label.font = LMFeedAppearance.shared.fonts.headingFont1
        label.textColor = LMFeedAppearance.shared.colors.gray102
        return label
    }()
    
    open private(set) lazy var descriptionLabel: LMLabel = {
        let label = LMLabel().translatesAutoresizingMaskIntoConstraints()
        label.text = "Trial Description"
        label.numberOfLines = 2
        label.font = LMFeedAppearance.shared.fonts.subHeadingFont2
        label.textColor = LMFeedAppearance.shared.colors.gray102
        return label
    }()
    
    open private(set) lazy var urlLabel: LMLabel = {
        let label = LMLabel().translatesAutoresizingMaskIntoConstraints()
        label.text = "Trial URL"
        label.font = LMFeedAppearance.shared.fonts.subHeadingFont1
        label.textColor = LMFeedAppearance.shared.colors.gray102
        return label
    }()
    
    
    public var crossButtonSize: CGFloat = 24
    
    // MARK: setupViews
    open override func setupViews() {
        super.setupViews()
        
        addSubview(containerView)
        containerView.addSubview(containerStackView)
        containerView.addSubview(crossButton)
        containerStackView.addArrangedSubview(imageView)
        containerStackView.addArrangedSubview(metaDataContainerView)
        
        metaDataContainerView.addSubview(sepratorView)
        metaDataContainerView.addSubview(metaDataStackView)
        
        [titleLabel, descriptionLabel, urlLabel].forEach { subView in
            metaDataStackView.addArrangedSubview(subView)
        }
    }
    
    
    // MARK: Data Variables
    public var crossButtonAction: (() -> Void)?
    
    // MARK: setupLayouts
    open override func setupLayouts() {
        super.setupLayouts()
        
        pinSubView(subView: containerView)
        containerView.pinSubView(subView: containerStackView)
        metaDataContainerView.pinSubView(subView: metaDataStackView, padding: .init(top: 8, left: 16, bottom: -8, right: -16))
        metaDataStackView.setHeightConstraint(with: 10, priority: .defaultLow)
        sepratorView.setHeightConstraint(with: 1)
        
        crossButton.addConstraint(top: (containerView.topAnchor, 16),
                                  trailing: (containerView.trailingAnchor, -16))
        crossButton.setHeightConstraint(with: crossButtonSize)
        crossButton.setWidthConstraint(with: crossButton.heightAnchor)
        
        imageView.setWidthConstraint(with: imageView.heightAnchor, multiplier: 3/2)
        
        sepratorView.addConstraint(top: (metaDataContainerView.topAnchor, 0),
                                   leading: (metaDataContainerView.leadingAnchor, 0),
                                   trailing: (metaDataContainerView.trailingAnchor, 0))
    }
    
    
    // MARK: setupAppearance
    open override func setupAppearance() {
        super.setupAppearance()
        containerView.layer.cornerRadius = 16
        containerView.layer.borderWidth = 1
        containerView.layer.borderColor = LMFeedAppearance.shared.colors.sepratorColor.cgColor
        sepratorView.backgroundColor = LMFeedAppearance.shared.colors.sepratorColor
        crossButton.layer.cornerRadius = crossButtonSize / 2
        crossButton.layer.borderColor = LMFeedAppearance.shared.colors.gray51.cgColor
        crossButton.layer.borderWidth = 1
    }
    
    
    // MARK: setupActions
    open override func setupActions() {
        super.setupActions()
        crossButton.addTarget(self, action: #selector(didTapCrossButton), for: .touchUpInside)
    }
    
    @objc
    open func didTapCrossButton() {
        crossButtonAction?()
    }
    
    
    // MARK: configure
    open func configure(with data: ContentModel, crossButtonAction: (() -> Void)? = nil) {
        crossButton.isHidden = crossButtonAction == nil
        self.crossButtonAction = crossButtonAction
        
        imageView.loadImage(url: data.linkPreview ?? "") { [weak imageView] result in
            switch result {
            case .success(_):
                imageView?.isHidden = false
            case .failure(_):
                imageView?.isHidden = true
            }
        }

        titleLabel.text = data.title
        titleLabel.isHidden = data.title?.isEmpty != false
        
        descriptionLabel.text = data.description
        descriptionLabel.isHidden = data.description?.isEmpty != false
        
        urlLabel.text = data.url.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }
}
