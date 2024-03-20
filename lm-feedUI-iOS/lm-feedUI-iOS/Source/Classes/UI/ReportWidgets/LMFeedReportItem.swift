//
//  LMFeedReportItem.swift
//  lm-feedUI-iOS
//
//  Created by Devansh Mohata on 31/01/24.
//

import UIKit

@IBDesignable
open class LMFeedReportItem: LMCollectionViewCell {
    // MARK: UI Elements
    open private(set) lazy var textLabel: LMLabel = {
        let label = LMLabel().translatesAutoresizingMaskIntoConstraints()
        label.font = Appearance.shared.fonts.textFont1
        label.textColor = Appearance.shared.colors.gray102
        label.text = "Tag"
        return label
    }()
    
    
    // MARK: Data Variables
    public var onTapCallback: (() -> Void)?
    public var isCellSelected: Bool = false
    
    // MARK: setupViews
    open override func setupViews() {
        super.setupViews()
        
        contentView.addSubview(containerView)
        containerView.addSubview(textLabel)
    }
    
    
    // MARK: setupLayouts
    open override func setupLayouts() {
        super.setupLayouts()
        
        contentView.pinSubView(subView: containerView)
        textLabel.addConstraint(top: (containerView.topAnchor, 8),
                                bottom: (containerView.bottomAnchor, -8),
                                leading: (containerView.leadingAnchor, 16),
                                trailing: (containerView.trailingAnchor, -16))
    }
    
    
    // MARK: setupActions
    open override func setupActions() {
        super.setupActions()
        containerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapView)))
    }
    
    @objc
    open func didTapView() {
        onTapCallback?()
    }
    
    // MARK: setupAppearance
    open override func setupAppearance() {
        super.setupAppearance()
        
        containerView.clipsToBounds = true
        containerView.layer.cornerRadius = contentView.bounds.height / 2
        containerView.layer.borderColor = isCellSelected ? Appearance.shared.colors.appTintColor.cgColor : Appearance.shared.colors.gray155.cgColor
        containerView.layer.borderWidth = 1
        
        textLabel.textColor = isCellSelected ? Appearance.shared.colors.appTintColor : Appearance.shared.colors.gray102
    }
    
    // MARK: configure
    open func configure(with tag: String, isSelected: Bool, onTapCallback: (() -> Void)?) {
        self.onTapCallback = onTapCallback
        textLabel.text = tag
        
        self.isCellSelected = isSelected
    }
}
