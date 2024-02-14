//
//  LMFeedTopicSelectionView.swift
//  likeminds-feed-iOS
//
//  Created by Devansh Mohata on 25/12/23.
//

import UIKit

@IBDesignable
open class LMFeedTopicSelectionView: LMView {
    open private(set) lazy var containerView: LMView = {
        let view = LMView().translatesAutoresizingMaskIntoConstraints()
        view.backgroundColor = Appearance.shared.colors.clear
        return view
    }()
    
    open private(set) lazy var textLabel: LMLabel = {
        let label = LMLabel().translatesAutoresizingMaskIntoConstraints()
        label.font = Appearance.shared.fonts.headingFont1
        label.textColor = Appearance.shared.colors.gray51
        label.text = "Topic #1"
        return label
    }()
    
    open private(set) lazy var tickButton: LMButton = {
        let button = LMButton().translatesAutoresizingMaskIntoConstraints()
        button.setTitle(nil, for: .normal)
        button.setTitle(nil, for: .selected)
        button.setImage(nil, for: .normal)
        button.setImage(Constants.shared.images.checkmarkIconFilled, for: .selected)
        return button
    }()
    
    open override func setupViews() {
        super.setupViews()
        
        addSubview(containerView)
        containerView.addSubview(textLabel)
        containerView.addSubview(tickButton)
    }
    
    open override func setupLayouts() {
        super.setupLayouts()
        
        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            textLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            textLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            textLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16),
            
            tickButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            tickButton.centerYAnchor.constraint(equalTo: textLabel.centerYAnchor),
            tickButton.leadingAnchor.constraint(greaterThanOrEqualTo: textLabel.trailingAnchor, constant: 16)
        ])
    }
}
