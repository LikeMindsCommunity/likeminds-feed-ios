//
//  LMFeedNoCommentWidget.swift
//  lm-feedUI-iOS
//
//  Created by Devansh Mohata on 07/02/24.
//

import UIKit

@IBDesignable
open class LMFeedNoCommentWidget: LMTableViewHeaderFooterView {
    open private(set) lazy var containerView: LMView = {
        let view = LMView().translatesAutoresizingMaskIntoConstraints()
        return view
    }()
    
    open private(set) lazy var titleLabel: LMLabel = {
        let label =  LMLabel().translatesAutoresizingMaskIntoConstraints()
        label.text = "Hello"
        label.textColor = Appearance.shared.colors.gray1
        return label
    }()
    
    open private(set) lazy var subtitleLabel: LMLabel = {
        let label = LMLabel().translatesAutoresizingMaskIntoConstraints()
        label.text = "No Way"
        label.textColor = Appearance.shared.colors.gray51
        return label
    }()
    
    open override func setupViews() {
        super.setupViews()
        
        contentView.addSubview(containerView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(subtitleLabel)
    }
    
    open override func setupLayouts() {
        super.setupLayouts()
        
        contentView.pinSubView(subView: containerView)
        
        titleLabel.addConstraint(top: (containerView.topAnchor, 16),
                                 centerX: (containerView.centerXAnchor, 0))
        
        subtitleLabel.addConstraint(top: (titleLabel.bottomAnchor, 4),
                                    bottom: (containerView.bottomAnchor, -16),
                                    centerX: (titleLabel.centerXAnchor, 0))
    }
}
