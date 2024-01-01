//
//  LMFeedPostLinkCellView.swift
//  LMFramework
//
//  Created by Devansh Mohata on 13/12/23.
//

import Kingfisher
import UIKit

@IBDesignable
open class LMFeedPostLinkCellView: LMView {
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
    open private(set) lazy var outerContaineView: LMView = {
        let view = LMView().translatesAutoresizingMaskIntoConstraints()
        view.backgroundColor = Appearance.shared.colors.clear
        view.clipsToBounds = true
        return view
    }()
    
    open private(set) lazy var stackContainerView: LMView = {
        let view = LMView().translatesAutoresizingMaskIntoConstraints()
        return view
    }()
    
    open private(set) lazy var stackView: LMStackView = {
        let stack = LMStackView().translatesAutoresizingMaskIntoConstraints()
        stack.axis = .vertical
        stack.alignment = .fill
        stack.distribution = .fill
        stack.spacing = 2
        return stack
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
        
        addSubview(outerContaineView)
        
        outerContaineView.addSubview(imageView)
        outerContaineView.addSubview(stackContainerView)
        
        stackContainerView.addSubview(sepratorView)
        stackContainerView.addSubview(stackView)
        
        [titleLabel, descriptionLabel, urlLabel].forEach { subView in
            stackView.addArrangedSubview(subView)
        }
    }
    
    
    // MARK: setupLayouts
    open override func setupLayouts() {
        super.setupLayouts()
        
        NSLayoutConstraint.activate([
            outerContaineView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            outerContaineView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            outerContaineView.topAnchor.constraint(equalTo: topAnchor),
            outerContaineView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            imageView.leadingAnchor.constraint(equalTo: outerContaineView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: outerContaineView.trailingAnchor),
            imageView.topAnchor.constraint(equalTo: outerContaineView.topAnchor),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: 2/3),
            
            stackContainerView.leadingAnchor.constraint(equalTo: outerContaineView.leadingAnchor),
            stackContainerView.trailingAnchor.constraint(equalTo: outerContaineView.trailingAnchor),
            stackContainerView.topAnchor.constraint(equalTo: imageView.bottomAnchor),
            stackContainerView.bottomAnchor.constraint(equalTo: outerContaineView.bottomAnchor),
            
            sepratorView.leadingAnchor.constraint(equalTo: stackContainerView.leadingAnchor),
            sepratorView.trailingAnchor.constraint(equalTo: stackContainerView.trailingAnchor),
            sepratorView.topAnchor.constraint(equalTo: stackContainerView.topAnchor),
            sepratorView.heightAnchor.constraint(equalToConstant: 1),
            
            stackView.leadingAnchor.constraint(equalTo: stackContainerView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: stackContainerView.trailingAnchor, constant: -16),
            stackView.topAnchor.constraint(equalTo: sepratorView.bottomAnchor, constant: 8),
            stackView.bottomAnchor.constraint(equalTo: stackContainerView.bottomAnchor, constant: -8)
        ])
    }
    
    
    // MARK: setupAppearance
    open override func setupAppearance() {
        super.setupAppearance()
        
        outerContaineView.layer.cornerRadius = 8
        outerContaineView.layer.borderWidth = 1
        outerContaineView.layer.borderColor = Appearance.shared.colors.gray3.cgColor
        
        imageView.image = Constants.shared.images.pdfIcon
    }
    
    
    // MARK: configure
    open func configure(with data: ViewModel) {
        imageView.kf.setImage(with: URL(string: data.linkPreview ?? ""), placeholder: Constants.shared.images.brokenLink)
        titleLabel.text = data.title
        titleLabel.isHidden = data.title?.isEmpty != false
        
        descriptionLabel.text = data.description
        descriptionLabel.isHidden = data.description?.isEmpty != false
        
        urlLabel.text = data.url
    }
}
