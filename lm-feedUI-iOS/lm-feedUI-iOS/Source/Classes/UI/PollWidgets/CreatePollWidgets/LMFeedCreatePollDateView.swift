//
//  LMFeedCreatePollDateView.swift
//  LikeMindsFeedUI
//
//  Created by Devansh Mohata on 07/06/24.
//

import UIKit

open class LMFeedCreatePollDateView: LMFeedView {
    // MARK: UI Elements
    open private(set) lazy var containerView: LMFeedView = {
        let view = LMFeedView().translatesAutoresizingMaskIntoConstraints()
        return view
    }()
    
    open private(set) lazy var titleLabel: LMFeedLabel = {
        let label = LMFeedLabel().translatesAutoresizingMaskIntoConstraints()
        label.text = "Poll expires on"
        label.font = LMFeedAppearance.shared.fonts.buttonFont2
        label.textColor = LMFeedAppearance.shared.colors.appTintColor
        return label
    }()
    
    open private(set) lazy var dateLabel: LMFeedLabel = {
        let label = LMFeedLabel().translatesAutoresizingMaskIntoConstraints()
        label.text = "DD-MM-YYYY hh:mm"
        label.font = LMFeedAppearance.shared.fonts.textFont1
        label.textColor = LMFeedAppearance.shared.colors.gray155
        return label
    }()
    
    
    // MARK: setupViews
    open override func setupViews() {
        super.setupViews()
        
        addSubview(containerView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(dateLabel)
    }
    
    
    // MARK: setupLayouts
    open override func setupLayouts() {
        super.setupLayouts()
        
        pinSubView(subView: containerView)
        
        titleLabel.addConstraint(top: (containerView.topAnchor, 16),
                                 leading: (containerView.leadingAnchor, 16))
        titleLabel.trailingAnchor.constraint(greaterThanOrEqualTo: containerView.trailingAnchor, constant: -16).isActive = true
        
        dateLabel.addConstraint(top: (titleLabel.bottomAnchor, 16),
                                bottom: (containerView.bottomAnchor, -16),
                                leading: (titleLabel.leadingAnchor, 0))
        dateLabel.trailingAnchor.constraint(greaterThanOrEqualTo: containerView.trailingAnchor, constant: -16).isActive = true
    }
    
    
    // MARK: setupAppearance
    open override func setupAppearance() {
        super.setupAppearance()
        
        containerView.backgroundColor = LMFeedAppearance.shared.colors.white
    }
    
    
    // MARK: configure
    open func configure(with date: Date) {
        dateLabel.textColor = LMFeedAppearance.shared.colors.black
        dateLabel.text = DateUtility.formatDate(date)
    }
}
