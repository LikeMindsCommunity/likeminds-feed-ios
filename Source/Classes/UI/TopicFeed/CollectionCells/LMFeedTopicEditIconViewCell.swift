//
//  LMFeedTopicEditIconViewCell.swift
//  likeminds-feed-iOS
//
//  Created by Devansh Mohata on 20/12/23.
//

import UIKit

@IBDesignable
open class LMFeedTopicEditIconViewCell: LMCollectionViewCell {
    // MARK: UI Elements
    open private(set) lazy var editIcon: LMButton = {
        let button = LMButton()
        button.setTitle(nil, for: .normal)
        button.setImage(Constants.shared.images.pencilIcon, for: .normal)
        button.setPreferredSymbolConfiguration(.init(scale: .medium), forImageIn: .normal)
        button.tintColor = Appearance.shared.colors.appTintColor
        return button
    }()
    
    
    // MARK: Variables
    var editCallback: (() -> Void)?
    
    
    // MARK: setupViews
    open override func setupViews() {
        super.setupViews()
        
        contentView.addSubview(containerView)
        containerView.addSubview(editIcon)
    }
    
    
    // MARK: setupLayouts
    open override func setupLayouts() {
        super.setupLayouts()
        
        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            editIcon.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8),
            editIcon.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8),
            editIcon.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 4),
            editIcon.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -4)
        ])
    }
    
    
    // MARK: setupAppearance
    open override func setupAppearance() {
        super.setupAppearance()
        
        containerView.clipsToBounds = true
        containerView.layer.cornerRadius = 4
        containerView.backgroundColor = Appearance.shared.colors.appTintColor.withAlphaComponent(0.1)
    }
    
    
    // MARK: setupActions
    open override func setupActions() {
        super.setupActions()
        
        editIcon.addTarget(self, action: #selector(didTapEditIcon), for: .touchUpInside)
    }
    
    @objc
    open func didTapEditIcon() {
        editCallback?()
    }
    
    
    // MARK: configure
    open func configure(editCallback: (() -> Void)?) {
        self.editCallback = editCallback
    }
}
