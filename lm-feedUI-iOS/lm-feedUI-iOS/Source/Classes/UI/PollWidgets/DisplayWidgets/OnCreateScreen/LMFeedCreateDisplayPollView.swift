//
//  LMFeedDisplayPollView.swift
//  LikeMindsFeedUI
//
//  Created by Devansh Mohata on 09/06/24.
//

import UIKit

public protocol LMFeedDisplayPollViewProtocol: AnyObject {
    func onTapCrossButton()
    func onTapEditButton()
}

open class LMFeedCreateDisplayPollView: BaseDisplayPollView {
    public struct ContentModel: BaseDisplayPollView.Content {
        public var question: String
        public var showEditIcon: Bool
        public var showCrossIcon: Bool
        public var expiryDate: Date
        public var optionState: String
        public var optionCount: Int
        public var options: [LMFeedDisplayCreatePollWidget.ContentModel]
        
        public init(question: String, showEditIcon: Bool, showCrossIcon: Bool, expiryDate: Date, optionState: String, optionCount: Int, options: [LMFeedDisplayCreatePollWidget.ContentModel]) {
            self.question = question
            self.showEditIcon = showEditIcon
            self.showCrossIcon = showCrossIcon
            self.expiryDate = expiryDate
            self.optionState = optionState
            self.optionCount = optionCount
            self.options = options
        }
    }
    
    // MARK: UI Elements
    open private(set) lazy var questionStackView: LMStackView = {
        let stack = LMStackView().translatesAutoresizingMaskIntoConstraints()
        stack.axis = .horizontal
        stack.alignment = .top
        stack.distribution = .fill
        stack.spacing = 8
        return stack
    }()
    
    open private(set) lazy var crossButton: LMButton = {
        let button = LMButton().translatesAutoresizingMaskIntoConstraints()
        button.setTitle(nil, for: .normal)
        button.setImage(Constants.shared.images.crossIcon, for: .normal)
        button.setPreferredSymbolConfiguration(UIImage.SymbolConfiguration(font: Appearance.shared.fonts.headingFont1), forImageIn: .normal)
        button.contentHorizontalAlignment = .fill
        button.contentVerticalAlignment = .fill
        button.tintColor = Appearance.shared.colors.gray51
        return button
    }()
    
    open private(set) lazy var editButton: LMButton = {
        let button = LMButton().translatesAutoresizingMaskIntoConstraints()
        button.setTitle(nil, for: .normal)
        button.setImage(Constants.shared.images.pencilIcon, for: .normal)
        button.setPreferredSymbolConfiguration(UIImage.SymbolConfiguration(font: Appearance.shared.fonts.headingFont1), forImageIn: .normal)
        button.contentHorizontalAlignment = .fill
        button.contentVerticalAlignment = .fill
        button.tintColor = Appearance.shared.colors.gray51
        return button
    }()
    
    
    // MARK: Data variables
    open var buttonSize: CGFloat { 24 }
    public weak var delegate: LMFeedDisplayPollViewProtocol?
    
    // MARK: setupViews
    open override func setupViews() {
        super.setupViews()
        
        addSubview(containerView)
        
        containerView.addSubview(questionContainerStackView)
        questionContainerStackView.addArrangedSubview(questionStackView)
        questionContainerStackView.addArrangedSubview(optionSelectCountLabel)
        containerView.addSubview(optionStackView)
        containerView.addSubview(expiryDateLabel)
        
        questionStackView.addArrangedSubview(questionTitle)
        questionStackView.addArrangedSubview(editButton)
        questionStackView.addArrangedSubview(crossButton)
    }
    
    
    // MARK: setupLayouts
    open override func setupLayouts() {
        super.setupLayouts()
        
        pinSubView(subView: containerView)
        
        questionContainerStackView.addConstraint(top: (containerView.topAnchor, 16),
                                        leading: (containerView.leadingAnchor, 16),
                                        trailing: (containerView.trailingAnchor, -16))
        
        editButton.setHeightConstraint(with: buttonSize)
        editButton.setWidthConstraint(with: buttonSize)
        
        crossButton.setHeightConstraint(with: buttonSize)
        crossButton.setWidthConstraint(with: buttonSize)
        
        crossButton.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        editButton.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        
        crossButton.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        editButton.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        
        optionSelectCountLabel.addConstraint(top: (questionStackView.bottomAnchor, 8),
                                             leading: (questionStackView.leadingAnchor, 0))
        optionSelectCountLabel.trailingAnchor.constraint(lessThanOrEqualTo: containerView.trailingAnchor, constant: -16).isActive = true
        
        optionStackView.addConstraint(top: (optionSelectCountLabel.bottomAnchor, 16),
                                      leading: (questionStackView.leadingAnchor, 0),
                                      trailing: (questionStackView.trailingAnchor, 0))
        
        expiryDateLabel.addConstraint(top: (optionStackView.bottomAnchor, 16),
                                      bottom: (containerView.bottomAnchor, -16),
                                      leading: (questionStackView.leadingAnchor, 0))
        expiryDateLabel.trailingAnchor.constraint(lessThanOrEqualTo: containerView.trailingAnchor, constant: -16).isActive = true
        
        questionTitle.bottomAnchor.constraint(equalTo: questionStackView.bottomAnchor).isActive = true
    }
    
    
    // MARK: setupAppearance
    open override func setupAppearance() {
        super.setupAppearance()
        
        containerView.layer.cornerRadius = 8
        containerView.layer.borderColor = Appearance.shared.colors.gray4.withAlphaComponent(1).cgColor
        containerView.layer.borderWidth = 1
    }
    
    
    // MARK: setupActions
    open override func setupActions() {
        super.setupActions()
        
        crossButton.addTarget(self, action: #selector(onTapCrossButton), for: .touchUpInside)
        editButton.addTarget(self, action: #selector(onTapEditButton), for: .touchUpInside)
    }
    
    @objc
    open func onTapCrossButton() {
        delegate?.onTapCrossButton()
    }
    
    @objc
    open func onTapEditButton() {
        delegate?.onTapEditButton()
    }
    
    
    // MARK: configure
    open func configure(with data: ContentModel, delegate: LMFeedDisplayPollViewProtocol?) {
        self.delegate = delegate
        questionTitle.text = data.question
        crossButton.isHidden = !data.showCrossIcon
        editButton.isHidden = !data.showEditIcon
        optionSelectCountLabel.text = data.optionStringFormatted
        
        optionStackView.removeAllArrangedSubviews()
        
        data.options.forEach { option in
            let optionView = LMFeedDisplayCreatePollWidget().translatesAutoresizingMaskIntoConstraints()
            optionView.configure(with: option)
            optionStackView.addArrangedSubview(optionView)
        }
        
        expiryDateLabel.text = data.expiryDateFormatted
        optionSelectCountLabel.isHidden = !data.isShowOption
    }
}
