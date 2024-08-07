//
//  LMFeedTopicViewCell.swift
//  Kingfisher
//
//  Created by Devansh Mohata on 20/12/23.
//

import UIKit

@IBDesignable
open class LMFeedTopicViewCell: LMCollectionViewCell {
    // MARK: UI Elements
    open private(set) lazy var textLabel: LMLabel = {
        let label = LMLabel().translatesAutoresizingMaskIntoConstraints()
        label.font = LMFeedAppearance.shared.fonts.textFont2
        label.textColor = LMFeedAppearance.shared.colors.appTintColor
        return label
    }()
    
    
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
        
        NSLayoutConstraint.activate([
            textLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8),
            textLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8),
            textLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 4),
            textLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -4)
        ])
    }
    
    
    // MARK: setupAppearance
    open override func setupAppearance() {
        super.setupAppearance()
        
        containerView.clipsToBounds = true
        containerView.layer.cornerRadius = 4
        containerView.backgroundColor = LMFeedAppearance.shared.colors.appTintColor.withAlphaComponent(0.1)
    }
    
    // MARK: configure
    open func configure(with data: LMFeedTopicCollectionCellDataModel) {
        textLabel.text = data.topic
    }
}
