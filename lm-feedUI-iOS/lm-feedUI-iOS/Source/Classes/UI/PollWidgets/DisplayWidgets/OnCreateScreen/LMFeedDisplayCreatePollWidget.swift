//
//  LMFeedDisplayCreatePollWidget.swift
//  LikeMindsFeedUI
//
//  Created by Devansh Mohata on 09/06/24.
//

import UIKit

open class LMFeedDisplayCreatePollWidget: BaseDisplayPollWidget {
    public struct ContentModel: BaseDisplayPollWidget.Content {
        public var option: String
        public var addedByUser: String?
        
        public init(option: String, addedBy: String? = nil) {
            self.option = option
            self.addedByUser = addedBy
        }
        
        public var addedByFormatted: String? {
            guard let addedByUser else { return nil }
            return "Added by \(addedByUser)"
        }
    }
    
    
    // MARK: setupViews
    open override func setupViews() {
        super.setupViews()
        
        addSubview(containerView)
        containerView.addSubview(stackView)
        stackView.addArrangedSubview(optionLabel)
        stackView.addArrangedSubview(addedByLabel)
    }
    
    
    // MARK: setupLayouts
    open override func setupLayouts() {
        super.setupLayouts()
        
        pinSubView(subView: containerView)
        containerView.pinSubView(subView: stackView, padding: .init(top: 16, left: 16, bottom: -16, right: -16))
    }
    
    
    // MARK: setupAppearance
    open override func setupAppearance() {
        super.setupAppearance()
        
        containerView.layer.cornerRadius = 8
        containerView.layer.borderColor = Appearance.shared.colors.gray155.cgColor
        containerView.layer.borderWidth = 1
    }
    
    // MARK: configure
    open func configure(with data: ContentModel) {
        optionLabel.text = data.option
        addedByLabel.text = data.addedByFormatted
        addedByLabel.isHidden = data.addedByFormatted?.isEmpty != false
    }
}
