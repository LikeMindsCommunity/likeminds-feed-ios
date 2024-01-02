//
//  LMFeedTopicEditViewCell.swift
//  likeminds-feed-iOS
//
//  Created by Devansh Mohata on 20/12/23.
//

import UIKit

public struct LMFeedTopicCollectionCellDataModel {
    let topic: String
    let topicID: String
}

@IBDesignable
open class LMFeedTopicEditViewCell: LMCollectionViewCell {
    // MARK: UI Elements
    open private(set) lazy var textLabel: LMLabel = {
        let label = LMLabel().translatesAutoresizingMaskIntoConstraints()
        label.textColor = Appearance.shared.colors.appTintColor
        label.font = Appearance.shared.fonts.textFont1
        return label
    }()
    
    open private(set) lazy var crossButton: LMButton = {
        let button = LMButton().translatesAutoresizingMaskIntoConstraints()
        button.setTitle(nil, for: .normal)
        button.setImage(Constants.shared.images.xmarkIcon, for: .normal)
        button.tintColor = Appearance.shared.colors.appTintColor
        return button
    }()
    
    
    // MARK: Data Variables
    public var topicID: String?
    public weak var delegate: LMFeedTopicViewCellProtocol?
    
    // MARK: setupViews
    open override func setupViews() {
        super.setupViews()
        
        contentView.addSubview(containerView)
        containerView.addSubview(textLabel)
        containerView.addSubview(crossButton)
    }
    
    
    // MARK: setupLayouts
    open override func setupLayouts() {
        super.setupLayouts()
        
        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            textLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8),
            textLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 4),
            textLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -4),
            
            crossButton.centerYAnchor.constraint(equalTo: textLabel.centerYAnchor),
            crossButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -4),
            crossButton.leadingAnchor.constraint(equalTo: textLabel.trailingAnchor, constant: 8),
            crossButton.heightAnchor.constraint(equalToConstant: 20),
            crossButton.heightAnchor.constraint(equalTo: crossButton.widthAnchor, multiplier: 1)
        ])
    }
    
    
    // MARK: setupActions
    open override func setupActions() {
        super.setupActions()
        
        crossButton.addTarget(self, action: #selector(didTapCrossButton), for: .touchUpInside)
    }
    
    @objc
    open func didTapCrossButton() {
        guard let topicID else { return }
        delegate?.didTapCrossButton(for: topicID)
    }
    
    
    // MARK: setupAppearance
    open override func setupAppearance() {
        super.setupAppearance()
        
        containerView.clipsToBounds = true
        containerView.layer.cornerRadius = 4
        containerView.layer.borderColor = Appearance.shared.colors.appTintColor.cgColor
        containerView.layer.borderWidth = 1
    }
    
    
    // MARK: configure
    open func configure(with data: LMFeedTopicCollectionCellDataModel, delegate: LMFeedTopicViewCellProtocol?) {
        self.delegate = delegate
        topicID = data.topicID
        textLabel.text = data.topic
    }
}
