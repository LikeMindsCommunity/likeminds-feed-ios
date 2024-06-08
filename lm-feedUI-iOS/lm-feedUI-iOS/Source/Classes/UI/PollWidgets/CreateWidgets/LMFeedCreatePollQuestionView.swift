//
//  LMFeedCreatePollQuestionView.swift
//  LikeMindsFeedUI
//
//  Created by Devansh Mohata on 06/06/24.
//

import UIKit

open class LMFeedCreatePollQuestionView: LMView {
    // MARK: UI Elements
    open private(set) lazy var containerView: LMView = {
        let view = LMView().translatesAutoresizingMaskIntoConstraints()
        return view
    }()
    
    open private(set) lazy var answerLabel: LMLabel = {
        let label = LMLabel().translatesAutoresizingMaskIntoConstraints()
        label.text = "Answer options"
        label.font = Appearance.shared.fonts.buttonFont2
        label.textColor = Appearance.shared.colors.appTintColor
        return label
    }()
    
    open private(set) lazy var optionStack: LMStackView = {
        let stack = LMStackView().translatesAutoresizingMaskIntoConstraints()
        stack.axis = .vertical
        stack.alignment = .fill
        stack.distribution = .fillEqually
        stack.spacing = 4
        return stack
    }()
    
    open private(set) lazy var addOptionView: LMView = {
        let view = LMView().translatesAutoresizingMaskIntoConstraints()
        view.backgroundColor = .clear
        return view
    }()
    
    open private(set) lazy var addOptionImage: LMImageView = {
        let image = LMImageView(image: Constants.shared.images.plusCircleIcon.withConfiguration(UIImage.SymbolConfiguration(font: Appearance.shared.fonts.buttonFont2)))
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    
    open private(set) lazy var addOptionText: LMLabel = {
        let label = LMLabel().translatesAutoresizingMaskIntoConstraints()
        label.text = "Add an option..."
        label.font = Appearance.shared.fonts.buttonFont2
        label.textColor = Appearance.shared.colors.appTintColor
        return label
    }()
    
    
    // MARK: Data Variables
    open var addOptionImageSize: CGFloat { 20 }
    
    open override func setupViews() {
        super.setupViews()
        
        addSubview(containerView)
        containerView.addSubview(answerLabel)
        containerView.addSubview(optionStack)
        containerView.addSubview(addOptionView)
        addOptionView.addSubview(addOptionImage)
        addOptionView.addSubview(addOptionText)
    }
    
    open override func setupLayouts() {
        super.setupLayouts()
        
        pinSubView(subView: containerView)
        
        answerLabel.addConstraint(top: (containerView.topAnchor, 16),
                                  leading: (containerView.leadingAnchor, 16))
        answerLabel.trailingAnchor.constraint(greaterThanOrEqualTo: containerView.trailingAnchor, constant: -16).isActive = true
        
        optionStack.addConstraint(top: (answerLabel.bottomAnchor, 16),
                                leading: (containerView.leadingAnchor, 0),
                                trailing: (containerView.trailingAnchor, 0))
        
        addOptionView.addConstraint(top: (optionStack.bottomAnchor, 16),
                                    bottom: (containerView.bottomAnchor, -16),
                                    leading: (containerView.leadingAnchor, 0),
                                    trailing: (containerView.trailingAnchor, 0))
        addOptionImage.addConstraint(top: (addOptionView.topAnchor, 8),
                                     bottom: (addOptionView.bottomAnchor, -8),
                                     leading: (addOptionView.leadingAnchor, 16))
        addOptionImage.setWidthConstraint(with: addOptionImageSize)
        addOptionImage.setHeightConstraint(with: addOptionImage.widthAnchor)
        
        addOptionText.addConstraint(leading: (addOptionImage.trailingAnchor, 8),
                                    centerY: (addOptionImage.centerYAnchor, 0))
        addOptionText.trailingAnchor.constraint(greaterThanOrEqualTo: addOptionView.trailingAnchor, constant: -16).isActive = true
        
        
        for _ in 0..<10 {
            let vc = LMFeedCreatePollOptionWidget().translatesAutoresizingMaskIntoConstraints()
            vc.setHeightConstraint(with: 64)
            optionStack.addArrangedSubview(vc)
        }
    }
    
    open override func setupAppearance() {
        super.setupAppearance()
        
        containerView.backgroundColor = Appearance.shared.colors.white
    }
}
