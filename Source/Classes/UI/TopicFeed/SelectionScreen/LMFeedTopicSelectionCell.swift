//
//  LMFeedTopicSelectionCell.swift
//  likeminds-feed-iOS
//
//  Created by Devansh Mohata on 26/12/23.
//

import UIKit

@IBDesignable
open class LMFeedTopicSelectionCell: LMTableViewCell {
    public struct ViewModel {
        let topic: String
        let topicID: String?
        let isSelected: Bool
    }
    
    
    // MARK: UI Elements
    open private(set) lazy var topicLabel: LMLabel = {
        let label = LMLabel().translatesAutoresizingMaskIntoConstraints()
        label.font = Appearance.shared.fonts.headingFont1
        label.textColor = Appearance.shared.colors.gray51
        label.text = "Topic #1"
        return label
    }()
    
    open private(set) lazy var tickButton: LMImageView = {
        let button = LMImageView().translatesAutoresizingMaskIntoConstraints()
        button.image = nil
        button.tintColor = Appearance.shared.colors.appTintColor
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
        
        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            topicLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            topicLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            topicLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16),
            
            tickButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            tickButton.centerYAnchor.constraint(equalTo: topicLabel.centerYAnchor),
            tickButton.leadingAnchor.constraint(greaterThanOrEqualTo: topicLabel.trailingAnchor, constant: 16),
            tickButton.heightAnchor.constraint(equalToConstant: 24),
            tickButton.widthAnchor.constraint(equalTo: tickButton.heightAnchor, multiplier: 1)
        ])
    }
    
    
    // MARK: configure
    open func configure(with data: ViewModel) {
        topicLabel.text = data.topic
        tickButton.image = data.isSelected ? Constants.shared.images.checkmarkIconFilled : nil
    }
}
