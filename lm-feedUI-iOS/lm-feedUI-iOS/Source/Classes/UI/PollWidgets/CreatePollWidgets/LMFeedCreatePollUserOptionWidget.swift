//
//  LMFeedCreatePollUserOptionWidget.swift
//  LikeMindsFeedUI
//
//  Created by Devansh Mohata on 08/06/24.
//

import UIKit

open class LMFeedCreatePollUserOptionWidget: LMView {
    open private(set) lazy var containerView: LMView = {
        let view = LMView().translatesAutoresizingMaskIntoConstraints()
        return view
    }()
    
    open private(set) lazy var titleLabel: LMLabel = {
        let label = LMLabel().translatesAutoresizingMaskIntoConstraints()
        label.textColor = Appearance.shared.colors.black
        label.font = Appearance.shared.fonts.buttonFont2
        label.text = "Demon Back"
        return label
    }()
    
    open private(set) lazy var downArrow: LMImageView = {
        let image = Constants.shared.images.downArrowFilled.withConfiguration(UIImage.SymbolConfiguration(font: Appearance.shared.fonts.buttonFont2))
        let imageView = LMImageView(image: image)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.tintColor = Appearance.shared.colors.black
        return imageView
    }()
    
    open private(set) lazy var sepratorView: LMView = {
        let view = LMView().translatesAutoresizingMaskIntoConstraints()
        view.backgroundColor = Appearance.shared.colors.gray4
        return view
    }()
    
    
    // MARK: setupViews
    open override func setupViews() {
        super.setupViews()
        
        addSubview(containerView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(downArrow)
        containerView.addSubview(sepratorView)
    }
    
    
    // MARK: setupLayouts
    open override func setupLayouts() {
        super.setupLayouts()
        
        pinSubView(subView: containerView)
        
        titleLabel.addConstraint(top: (containerView.topAnchor, 4),
                                 bottom: (containerView.bottomAnchor, -4),
                                 leading: (containerView.leadingAnchor, 0))
        
        downArrow.addConstraint(leading: (titleLabel.trailingAnchor, 8),
                                trailing: (containerView.trailingAnchor, 0),
                                centerY: (titleLabel.centerYAnchor, 0))
        
        sepratorView.addConstraint(bottom: (containerView.bottomAnchor, 0),
                                   leading: (titleLabel.leadingAnchor, 0),
                                   trailing: (downArrow.trailingAnchor, 0))
        sepratorView.setHeightConstraint(with: 1)
        
        titleLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        titleLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
    }
    
    
    // MARK: configure
    open func configure(with title: String) {
        titleLabel.text = title
    }
}
