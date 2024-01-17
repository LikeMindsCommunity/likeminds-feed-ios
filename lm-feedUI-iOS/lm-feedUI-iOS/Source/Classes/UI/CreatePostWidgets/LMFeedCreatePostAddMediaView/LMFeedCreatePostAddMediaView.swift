//
//  LMFeedCreatePostAddMediaView.swift
//  lm-feedUI-iOS
//
//  Created by Devansh Mohata on 17/01/24.
//

import UIKit

@IBDesignable
open class LMFeedCreatePostAddMediaView: LMView {
    // MARK: UI Elements
    open private(set) lazy var containerView: LMView = {
        let view = LMView().translatesAutoresizingMaskIntoConstraints()
        view.backgroundColor = .clear
        return view
    }()
    
    open private(set) lazy var imageView: LMImageView = {
        let image = LMImageView().translatesAutoresizingMaskIntoConstraints()
        return image
    }()
    
    open private(set) lazy var titleLabel: LMLabel = {
        let label = LMLabel().translatesAutoresizingMaskIntoConstraints()
        label.font = Appearance.shared.fonts.buttonFont1
        label.textColor = Appearance.shared.colors.gray1
        return label
    }()
    
    open private(set) lazy var sepratorView: LMView = {
        let view = LMView().translatesAutoresizingMaskIntoConstraints()
        view.backgroundColor = Appearance.shared.colors.gray4
        return view
    }()
    
    
    // MARK: Data Variables
    public var imageHeight: CGFloat = 24
    
    
    // MARK: setupViews
    open override func setupViews() {
        super.setupViews()
        
        addSubview(containerView)
        containerView.addSubview(imageView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(sepratorView)
    }
    
    
    // MARK: setupLayouts
    open override func setupLayouts() {
        super.setupLayouts()
        
        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.bottomAnchor.constraint(greaterThanOrEqualTo: bottomAnchor),
            
            imageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            imageView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 8),
            imageView.bottomAnchor.constraint(equalTo: sepratorView.topAnchor, constant: -8),
            imageView.heightAnchor.constraint(equalToConstant: imageHeight),
            imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor),
            
            
            titleLabel.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(greaterThanOrEqualTo: containerView.trailingAnchor, constant: 16),
            titleLabel.centerYAnchor.constraint(equalTo: imageView.centerYAnchor),
            
            sepratorView.heightAnchor.constraint(equalToConstant: 1),
            sepratorView.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: -8),
            sepratorView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            sepratorView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            sepratorView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
        ])
    }
    
    
    // MARK: configure
    open func configure(with title: String, image: UIImage, hideSeprator: Bool = false) {
        imageView.image = image
        titleLabel.text = title
        sepratorView.isHidden = hideSeprator
    }
}
