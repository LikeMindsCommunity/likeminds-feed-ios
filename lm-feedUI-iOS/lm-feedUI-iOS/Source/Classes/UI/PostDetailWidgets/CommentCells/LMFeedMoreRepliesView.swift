//
//  LMFeedMoreRepliesView.swift
//  LMFramework
//
//  Created by Devansh Mohata on 18/12/23.
//

import UIKit

@IBDesignable
open class LMFeedMoreRepliesView: LMFeedTableViewHeaderFooterView {
    // MARK: UI Elements
    open private(set) lazy var containerView: LMFeedView = {
        let view = LMFeedView().translatesAutoresizingMaskIntoConstraints()
        return view
    }()
    
    open private(set) lazy var staticLabel: LMFeedLabel = {
        let label = LMFeedLabel().translatesAutoresizingMaskIntoConstraints()
        label.font = LMFeedAppearance.shared.fonts.headingFont3
        label.textColor = LMFeedAppearance.shared.colors.blueGray
        label.text = "View more replies"
        return label
    }()
    
    open private(set) lazy var countLabel: LMFeedLabel = {
        let label = LMFeedLabel().translatesAutoresizingMaskIntoConstraints()
        label.font = LMFeedAppearance.shared.fonts.subHeadingFont1
        label.textColor = LMFeedAppearance.shared.colors.gray155
        return label
    }()
    
    open private(set) lazy var sepratorView: LMFeedView = {
        let view = LMFeedView().translatesAutoresizingMaskIntoConstraints()
        view.backgroundColor = LMFeedAppearance.shared.colors.backgroundColor
        return view
    }()
    
    
    // MARK: Data Variables
    public var onClick: (() -> Void)?
    
    
    // MARK: setupViews
    open override func setupViews() {
        super.setupViews()
        
        contentView.addSubview(containerView)
        
        containerView.addSubview(staticLabel)
        containerView.addSubview(countLabel)
        containerView.addSubview(sepratorView)
    }
    
    
    // MARK: setupLayouts
    open override func setupLayouts() {
        super.setupLayouts()
        
        contentView.pinSubView(subView: containerView)
        
        sepratorView.addConstraint(bottom: (containerView.bottomAnchor, 0),
                                   leading: (containerView.leadingAnchor, 0),
                                   trailing: (containerView.trailingAnchor, 0))
        sepratorView.setHeightConstraint(with: 1)
        
        staticLabel.addConstraint(top: (containerView.topAnchor, 16),
                                  bottom: (sepratorView.topAnchor, -16),
                                  leading: (containerView.leadingAnchor, 32))
        
        countLabel.addConstraint(trailing: (containerView.trailingAnchor, -16),
                                 centerY: (staticLabel.centerYAnchor, 0))
        countLabel.leadingAnchor.constraint(greaterThanOrEqualTo: staticLabel.trailingAnchor, constant: 16).isActive = true
    }
    
    
    // MARK: setupActions
    open override func setupActions() {
        super.setupActions()
        containerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapView)))
    }
    
    @objc
    open func didTapView() {
        onClick?()
    }
    
    
    // MARK: setupAppearance
    open override func setupAppearance() {
        super.setupAppearance()
        containerView.backgroundColor = LMFeedAppearance.shared.colors.white
    }
    
    
    // MARK: configure
    open func configure(with totalComments: Int, visibleComments: Int, onClick: (() -> Void)?) {
        countLabel.text = "\(visibleComments) of \(totalComments)"
        self.onClick = onClick
    }
}
