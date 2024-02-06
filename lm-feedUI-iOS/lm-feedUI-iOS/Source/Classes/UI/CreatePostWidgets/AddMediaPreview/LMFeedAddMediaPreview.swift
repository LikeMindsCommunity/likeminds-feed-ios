//
//  LMFeedAddMediaPreview.swift
//  lm-feedUI-iOS
//
//  Created by Devansh Mohata on 06/02/24.
//

import UIKit

@IBDesignable
open class LMFeedAddMediaPreview: LMView {
    // MARK: UI Elements
    open private(set) lazy var containerView: LMView = {
        let view = LMView().translatesAutoresizingMaskIntoConstraints()
        return view
    }()
    
    open private(set) lazy var contentImageView: LMImageView = {
        let image = LMImageView().translatesAutoresizingMaskIntoConstraints()
        return image
    }()
    
    open private(set) lazy var titleLabel: LMLabel = {
        let label = LMLabel().translatesAutoresizingMaskIntoConstraints()
        label.text = "Posting"
        label.font = Appearance.shared.fonts.textFont2
        label.textColor = Appearance.shared.colors.gray51
        return label
    }()
    
    open private(set) lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.tintColor = Appearance.shared.colors.gray102
        return indicator
    }()
    
    
    // MARK: setupViews
    open override func setupViews() {
        super.setupViews()
        
        addSubview(containerView)
        containerView.addSubview(contentImageView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(activityIndicator)
    }
    
    
    // MARK: setupLayouts
    open override func setupLayouts() {
        super.setupLayouts()
        
        pinSubView(subView: containerView)
        
        contentImageView.addConstraint(top: (containerView.topAnchor, 8),
                                       bottom: (containerView.bottomAnchor, -8),
                                       leading: (containerView.leadingAnchor, 16))
        
        titleLabel.addConstraint(leading: (contentImageView.trailingAnchor, 16),
                                 centerY: (contentImageView.centerYAnchor, 0))
        
        activityIndicator.addConstraint(trailing: (containerView.trailingAnchor, -16),
                                        centerY: (titleLabel.centerYAnchor, 0))
        
        activityIndicator.leadingAnchor.constraint(greaterThanOrEqualTo: titleLabel.trailingAnchor, constant: 16).isActive = true
        
        contentImageView.setWidthConstraint(with: contentImageView.heightAnchor)
    }
    
    
    // MARK: setupAppearance
    open override func setupAppearance() {
        super.setupAppearance()
        containerView.backgroundColor = Appearance.shared.colors.white
    }
    
    open func configure(with image: String?) {
        contentImageView.kf.setImage(with: URL(string: image ?? ""), placeholder: Constants.shared.images.placeholderImage)
        activityIndicator.startAnimating()
    }
    
    open func stopAnimating() {
        activityIndicator.stopAnimating()
    }
}
