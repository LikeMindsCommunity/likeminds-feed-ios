//
//  LMFeedAddMediaPreview.swift
//  lm-feedUI-iOS
//
//  Created by Devansh Mohata on 06/02/24.
//

import AVFoundation
import PDFKit
import UIKit

@IBDesignable
open class LMFeedAddMediaPreview: LMFeedView {
    // MARK: UI Elements
    open private(set) lazy var containerView: LMFeedView = {
        let view = LMFeedView().translatesAutoresizingMaskIntoConstraints()
        return view
    }()
    
    open private(set) lazy var stackView: LMFeedStackView = {
        let stack = LMFeedStackView().translatesAutoresizingMaskIntoConstraints()
        stack.axis = .horizontal
        stack.alignment = .fill
        stack.distribution = .fill
        stack.spacing = 8
        return stack
    }()
    
    open private(set) lazy var contentImageView: LMFeedImageView = {
        let image = LMFeedImageView().translatesAutoresizingMaskIntoConstraints()
        return image
    }()
    
    open private(set) lazy var titleLabel: LMFeedLabel = {
        let label = LMFeedLabel().translatesAutoresizingMaskIntoConstraints()
        label.text = "Posting"
        label.font = LMFeedAppearance.shared.fonts.textFont2
        label.textColor = LMFeedAppearance.shared.colors.gray51
        return label
    }()
    
    open private(set) lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.tintColor = LMFeedAppearance.shared.colors.gray51
        return indicator
    }()
    
    
    // MARK: setupViews
    open override func setupViews() {
        super.setupViews()
        
        addSubview(containerView)
        containerView.addSubview(stackView)
        stackView.addArrangedSubview(contentImageView)
        stackView.addArrangedSubview(titleLabel)
        containerView.addSubview(activityIndicator)
    }
    
    
    // MARK: setupLayouts
    open override func setupLayouts() {
        super.setupLayouts()
        
        pinSubView(subView: containerView)
        
        stackView.addConstraint(top: (containerView.topAnchor, 8),
                                       bottom: (containerView.bottomAnchor, -8),
                                       leading: (containerView.leadingAnchor, 16))
        
        activityIndicator.addConstraint(trailing: (containerView.trailingAnchor, -16),
                                        centerY: (stackView.centerYAnchor, 0))
        
        activityIndicator.leadingAnchor.constraint(greaterThanOrEqualTo: stackView.trailingAnchor, constant: 16).isActive = true
        contentImageView.setWidthConstraint(with: contentImageView.heightAnchor)
    }
    
    
    // MARK: setupAppearance
    open override func setupAppearance() {
        super.setupAppearance()
        containerView.backgroundColor = LMFeedAppearance.shared.colors.white
    }
    
    open func configure(with image: UIImage?) {
        contentImageView.image = image
        contentImageView.isHidden = image == nil
        activityIndicator.startAnimating()
    }
    
    open func stopAnimating() {
        activityIndicator.stopAnimating()
    }
}
