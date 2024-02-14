//
//  LMFeedSelectTopicViewCell.swift
//  lm-feedUI-iOS
//
//  Created by Devansh Mohata on 23/01/24.
//

import UIKit

@IBDesignable
open class LMFeedSelectTopicViewCell: LMCollectionViewCell {
    // MARK: UI Elements
    open private(set) lazy var selectTopicIcon: LMButton = {
        let button = LMButton().translatesAutoresizingMaskIntoConstraints()
        button.setTitle("Select Topics", for: .normal)
        button.setTitleColor(Appearance.shared.colors.appTintColor, for: .normal)
        button.setFont(Appearance.shared.fonts.buttonFont1)
        button.setImage(Constants.shared.images.plusIcon, for: .normal)
        button.setPreferredSymbolConfiguration(.init(font: Appearance.shared.fonts.buttonFont1), forImageIn: .normal)
        button.tintColor = Appearance.shared.colors.appTintColor
        return button
    }()
    
    
    // MARK: Data Variables
    var selectCallback: (() -> Void)?
    
    
    // MARK: setupViews
    open override func setupViews() {
        super.setupViews()
        contentView.addSubview(containerView)
        containerView.addSubview(selectTopicIcon)
    }
    
    
    // MARK: setupLayouts
    open override func setupLayouts() {
        contentView.pinSubView(subView: containerView)
        selectTopicIcon.addConstraint(top: (containerView.topAnchor, 4),
                               bottom: (containerView.bottomAnchor, -4),
                               leading: (containerView.leadingAnchor, 8),
                               trailing: (containerView.trailingAnchor, -8))
    }
    
    
    // MARK: setupActions
    open override func setupActions() {
        super.setupActions()
        selectTopicIcon.addTarget(self, action: #selector(didTapSelectTopics), for: .touchUpInside)
    }
    
    open override func setupAppearance() {
        super.setupAppearance()
        
        containerView.backgroundColor = Appearance.shared.colors.appTintColor.withAlphaComponent(0.1)
        containerView.layer.cornerRadius = 4
    }
    
    @objc
    open func didTapSelectTopics() {
        selectCallback?()
    }
    
    
    open func configure(with selectCallback: (() -> Void)?) {
        self.selectCallback = selectCallback
    }
}
