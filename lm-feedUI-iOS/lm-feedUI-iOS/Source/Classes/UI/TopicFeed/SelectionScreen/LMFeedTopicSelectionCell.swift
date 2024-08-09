//
//  LMFeedTopicSelectionCell.swift
//  likeminds-feed-iOS
//
//  Created by Devansh Mohata on 26/12/23.
//

import UIKit

@IBDesignable
open class LMFeedTopicSelectionCell: LMTableViewCell {
    public struct ContentModel {
        public let topic: String
        public let topicID: String?
        public let isSelected: Bool
        
        public init(topic: String, topicID: String?, isSelected: Bool) {
            self.topic = topic
            self.topicID = topicID
            self.isSelected = isSelected
        }
    }
    
    
    // MARK: UI Elements
    open private(set) lazy var topicLabel: LMLabel = {
        let label = LMLabel().translatesAutoresizingMaskIntoConstraints()
        label.font = LMFeedAppearance.shared.fonts.headingFont1
        label.textColor = LMFeedAppearance.shared.colors.gray51
        label.text = "Topic #1"
        return label
    }()
    
    open private(set) lazy var tickButton: LMImageView = {
        let button = LMImageView().translatesAutoresizingMaskIntoConstraints()
        button.image = nil
        button.tintColor = LMFeedAppearance.shared.colors.appTintColor
        return button
    }()
    
    
    // MARK: setupViews
    open override func setupViews() {
        super.setupViews()
        
        contentView.addSubview(containerView)
        containerView.addSubview(topicLabel)
        containerView.addSubview(tickButton)
    }
    
    
    // MARK: setupLayouts
    open override func setupLayouts() {
        super.setupLayouts()
        
        contentView.pinSubView(subView: containerView)
        tickButton.setHeightConstraint(with: 24)
        tickButton.setWidthConstraint(with: tickButton.heightAnchor)
        
        NSLayoutConstraint.activate([
            topicLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            topicLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            topicLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16),
            
            tickButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            tickButton.centerYAnchor.constraint(equalTo: topicLabel.centerYAnchor),
            tickButton.leadingAnchor.constraint(greaterThanOrEqualTo: topicLabel.trailingAnchor, constant: 16)
        ])
    }
    
    
    // MARK: configure
    open func configure(with data: ContentModel) {
        topicLabel.text = data.topic
        tickButton.image = data.isSelected ? LMFeedConstants.shared.images.checkmarkIconFilled : nil
    }
}
