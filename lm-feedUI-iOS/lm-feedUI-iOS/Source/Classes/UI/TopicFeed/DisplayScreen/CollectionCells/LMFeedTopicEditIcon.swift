//
//  LMFeedTopicEditIcon.swift
//  likeminds-feed-iOS
//
//  Created by Devansh Mohata on 20/12/23.
//

import UIKit

@IBDesignable
open class LMFeedTopicEditIcon: LMCollectionViewCell {
    // MARK: UI Elements
    open private(set) lazy var editIcon: LMButton = {
        let button = LMButton().translatesAutoresizingMaskIntoConstraints()
        button.setTitle(nil, for: .normal)
        button.setImage(LMFeedConstants.shared.images.pencilIcon, for: .normal)
        button.setPreferredSymbolConfiguration(.init(scale: .large), forImageIn: .normal)
        button.tintColor = LMFeedAppearance.shared.colors.appTintColor
        return button
    }()
    
    
    // MARK: Data Variables
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
        
        contentView.pinSubView(subView: containerView)
        editIcon.addConstraint(top: (containerView.topAnchor, 8),
                               bottom: (containerView.bottomAnchor, -8),
                               leading: (containerView.leadingAnchor, 8),
                               trailing: (containerView.trailingAnchor, -8))
    }
    
    
    // MARK: setupAppearance
    open override func setupAppearance() {
        super.setupAppearance()
        
        containerView.clipsToBounds = true
        containerView.layer.cornerRadius = 4
        containerView.backgroundColor = LMFeedAppearance.shared.colors.appTintColor.withAlphaComponent(0.1)
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
