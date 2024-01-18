//
//  LMFeedCreatePostLinkPreview.swift
//  lm-feedUI-iOS
//
//  Created by Devansh Mohata on 17/01/24.
//

import Kingfisher
import UIKit

@IBDesignable
open class LMFeedLinkPreview: LMView {
    public struct ViewModel: LMFeedMediaProtocol {
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
        view.backgroundColor = Appearance.shared.colors.clear
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
        button.setImage(Constants.shared.images.crossIcon, for: .normal)
        button.tintColor = Appearance.shared.colors.gray51
        button.backgroundColor = Appearance.shared.colors.white
        return button
    }()
    
    open private(set) lazy var imageView: LMImageView = {
        let image = LMImageView().translatesAutoresizingMaskIntoConstraints()
        image.contentMode = .scaleToFill
        image.clipsToBounds = true
        image.layer.masksToBounds = true
        return image
    }()
    
    open private(set) lazy var sepratorView: LMView = {
        let view = LMView().translatesAutoresizingMaskIntoConstraints()
        view.backgroundColor = Appearance.shared.colors.gray3
        return view
    }()
    
    open private(set) lazy var metaDataContainerView: LMView = {
        let view = LMView().translatesAutoresizingMaskIntoConstraints()
        view.backgroundColor = Appearance.shared.colors.clear
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
        label.font = Appearance.shared.fonts.headingFont1
        label.textColor = Appearance.shared.colors.gray102
        return label
    }()
    
    open private(set) lazy var descriptionLabel: LMLabel = {
        let label = LMLabel().translatesAutoresizingMaskIntoConstraints()
        label.text = "Trial Description"
        label.numberOfLines = 2
        label.font = Appearance.shared.fonts.subHeadingFont2
        label.textColor = Appearance.shared.colors.gray102
        return label
    }()
    
    open private(set) lazy var urlLabel: LMLabel = {
        let label = LMLabel().translatesAutoresizingMaskIntoConstraints()
        label.text = "Trial URL"
        label.font = Appearance.shared.fonts.subHeadingFont1
        label.textColor = Appearance.shared.colors.gray102
        return label
    }()
    
    
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
        
        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.bottomAnchor.constraint(greaterThanOrEqualTo: bottomAnchor),
            
            crossButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            crossButton.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            crossButton.heightAnchor.constraint(equalToConstant: 24),
            crossButton.widthAnchor.constraint(equalTo: crossButton.heightAnchor),
            
            containerStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            containerStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            containerStackView.topAnchor.constraint(equalTo: containerView.topAnchor),
            containerStackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            
            imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor, multiplier: 3/2),
            
            sepratorView.leadingAnchor.constraint(equalTo: metaDataContainerView.leadingAnchor),
            sepratorView.trailingAnchor.constraint(equalTo: metaDataContainerView.trailingAnchor),
            sepratorView.topAnchor.constraint(equalTo: metaDataContainerView.topAnchor),
            sepratorView.heightAnchor.constraint(equalToConstant: 1),
            
            metaDataStackView.leadingAnchor.constraint(equalTo: metaDataContainerView.leadingAnchor, constant: 16),
            metaDataStackView.trailingAnchor.constraint(equalTo: metaDataContainerView.trailingAnchor, constant: -16),
            metaDataStackView.bottomAnchor.constraint(equalTo: metaDataContainerView.bottomAnchor, constant: -8),
            metaDataStackView.topAnchor.constraint(equalTo: sepratorView.bottomAnchor, constant: 8),
        ])
    }
    
    
    // MARK: setupAppearance
    open override func setupAppearance() {
        super.setupAppearance()
        containerView.layer.cornerRadius = 16
        containerView.layer.borderWidth = 1
        containerView.layer.borderColor = Appearance.shared.colors.gray102.cgColor
        sepratorView.backgroundColor = Appearance.shared.colors.gray102
    }
    
    
    // MARK: configure
    open func configure(with data: ViewModel, crossButtonAction: (() -> Void)? = nil) {
        crossButton.isHidden = crossButtonAction == nil
        self.crossButtonAction = crossButtonAction
        
        imageView.kf.indicatorType = .activity
        imageView.kf.setImage(with: URL(string: data.linkPreview ?? "")) { [weak self] result in
            switch result {
            case .success(_):
                break
            case .failure(_):
                self?.imageView.isHidden = true
            }
        }
        
        titleLabel.text = data.title
        titleLabel.isHidden = data.title?.isEmpty != false
        
        descriptionLabel.text = data.description
        descriptionLabel.isHidden = data.description?.isEmpty != false
        
        urlLabel.text = data.url
    }
}
