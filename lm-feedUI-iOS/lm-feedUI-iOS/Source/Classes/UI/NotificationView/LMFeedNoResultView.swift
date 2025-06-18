//
//  LMFeedNoResultView.swift
//  lm-feedUI-iOS
//
//  Created by Devansh Mohata on 29/01/24.
//

import UIKit

@IBDesignable
open class LMFeedNoResultView: LMFeedView {
    open private(set) lazy var containerView: LMFeedView = {
        let view = LMFeedView().translatesAutoresizingMaskIntoConstraints()
        return view
    }()
    
    open private(set) lazy var emptyImageView: LMFeedImageView = {
        let image = LMFeedImageView().translatesAutoresizingMaskIntoConstraints()
        return image
    }()
    
    open private(set) lazy var textLabel: LMFeedLabel = {
        let label = LMFeedLabel().translatesAutoresizingMaskIntoConstraints()
        label.text = LMFeedConstants.shared.strings.noResultsFound
        label.textColor = LMFeedAppearance.shared.colors.gray51
        label.font = LMFeedAppearance.shared.fonts.headingFont3
        label.textAlignment = .center
        return label
    }()
    
    open override func setupViews() {
        super.setupViews()
        
        addSubview(containerView)
        containerView.addSubview(emptyImageView)
        containerView.addSubview(textLabel)
    }
    
    open override func setupLayouts() {
        super.setupLayouts()
        
        pinSubView(subView: containerView)
        emptyImageView.addConstraint(centerX: (containerView.centerXAnchor, 0),
                                     centerY: (containerView.centerYAnchor, -60))
        emptyImageView.setHeightConstraint(with: 100)
        emptyImageView.widthAnchor.constraint(equalTo: emptyImageView.heightAnchor, multiplier: 1).isActive = true
        
        textLabel.addConstraint(top: (emptyImageView.bottomAnchor, 16), leading: (containerView.leadingAnchor, 16), trailing: (containerView.trailingAnchor, -16))
    }
    
    open override func setupAppearance() {
        super.setupAppearance()
        
        emptyImageView.image = LMFeedConstants.shared.images.emptyViewIcon
    }
    
    open func configure(with error: String) {
        textLabel.text = error
    }
}
