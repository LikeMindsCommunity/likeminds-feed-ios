//
//  LMFeedNoResultView.swift
//  lm-feedUI-iOS
//
//  Created by Devansh Mohata on 29/01/24.
//

import UIKit

@IBDesignable
open class LMFeedNoResultView: LMView {
    open private(set) lazy var containerView: LMView = {
        let view = LMView().translatesAutoresizingMaskIntoConstraints()
        return view
    }()
    
    open private(set) lazy var emptyImageView: LMImageView = {
        let image = LMImageView().translatesAutoresizingMaskIntoConstraints()
        return image
    }()
    
    open private(set) lazy var textLabel: LMLabel = {
        let label = LMLabel().translatesAutoresizingMaskIntoConstraints()
        label.text = "No Results Found!"
        label.textColor = Appearance.shared.colors.gray51
        label.font = Appearance.shared.fonts.headingFont3
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
        
        emptyImageView.image = Constants.shared.images.emptyViewIcon
    }
    
    open func configure(with error: String) {
        textLabel.text = error
    }
}
