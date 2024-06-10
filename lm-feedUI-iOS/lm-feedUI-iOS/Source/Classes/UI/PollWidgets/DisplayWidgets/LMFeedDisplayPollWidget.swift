//
//  LMFeedDisplayPollWidget.swift
//  LikeMindsFeedUI
//
//  Created by Devansh Mohata on 09/06/24.
//

import UIKit

open class LMFeedDisplayPollWidget: LMView {
    public struct ContentModel {
        let option: String
        let addedByUser: String?
        
        public init(option: String, addedBy: String?) {
            self.option = option
            self.addedByUser = addedBy
        }
        
        public var addedByFormatted: String? {
            guard let addedByUser else { return nil }
            return "Added by \(addedByUser)"
        }
    }
    
    
    // MARK: UI Elements
    open private(set) lazy var containerView: LMView = {
        let view = LMView().translatesAutoresizingMaskIntoConstraints()
        view.backgroundColor = Appearance.shared.colors.clear
        return view
    }()
    
    open private(set) lazy var stackView: LMStackView = {
        let stack = LMStackView().translatesAutoresizingMaskIntoConstraints()
        stack.axis = .vertical
        stack.alignment = .fill
        stack.distribution = .fill
        stack.spacing = 4
        return stack
    }()
    
    open private(set) lazy var optionLabel: LMLabel = {
        let label = LMLabel().translatesAutoresizingMaskIntoConstraints()
        label.font = Appearance.shared.fonts.headingFont1
        label.textColor = Appearance.shared.colors.gray51
        return label
    }()
    
    open private(set) lazy var addedByLabel: LMLabel = {
        let label = LMLabel().translatesAutoresizingMaskIntoConstraints()
        label.font = Appearance.shared.fonts.subHeadingFont1
        label.textColor = Appearance.shared.colors.blueGray.withAlphaComponent(0.7)
        return label
    }()
    
    
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
