//
//  LMFeedAddResponseView.swift
//  LikeMindsFeedUI
//
//  Created by Devansh Mohata on 28/07/24.
//

import UIKit

open class LMFeedAddResponseView: LMFeedView {
    open private(set) lazy var containerView: LMFeedView = {
        let view = LMFeedView().translatesAutoresizingMaskIntoConstraints()
        return view
    }()
    
    open private(set) lazy var sepratorView: LMFeedView = {
        let view = LMFeedView().translatesAutoresizingMaskIntoConstraints()
        view.backgroundColor = LMFeedAppearance.shared.colors.sepratorColor
        return view
    }()
    
    open private(set) lazy var containerStackView: LMFeedStackView = {
        let stack = LMFeedStackView().translatesAutoresizingMaskIntoConstraints()
        stack.axis = .horizontal
        stack.alignment = .fill
        stack.distribution = .fill
        stack.spacing = 8
        return stack
    }()
    
    open private(set) lazy var profileView: LMFeedImageView = {
        let image = LMFeedImageView().translatesAutoresizingMaskIntoConstraints()
        return image
    }()
    
    open private(set) lazy var placeholderLabel: LMFeedLabel = {
        let label = LMFeedLabel().translatesAutoresizingMaskIntoConstraints()
        label.text = "Be the first one to answer"
        label.font = LMFeedAppearance.shared.fonts.subHeadingFont2
        label.textColor = LMFeedAppearance.shared.colors.gray102
        return label
    }()
    

    // MARK: setupViews
    open override func setupViews() {
        super.setupViews()
        
        addSubview(containerView)
        addSubview(sepratorView)
        
        containerView.addSubview(containerStackView)
        
        containerStackView.addArrangedSubview(profileView)
        containerStackView.addArrangedSubview(placeholderLabel)
    }
    
    
    // MARK: setupLayouts()
    open override func setupLayouts() {
        super.setupLayouts()
        
        pinSubView(subView: containerView)
        containerView.pinSubView(subView: containerStackView)
        
        profileView.setWidthConstraint(with: profileView.heightAnchor)
        placeholderLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
    }
    
    open func configure(with userImage: String?, username: String) {
        
    }
}
