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

open class LMFeedDisplayPollView: LMView {
    public struct ContentModel {
        public let question: String
        public let showEditIcon: Bool
        public let showCrossIcon: Bool
        public let expiryDate: Date
        public let optionState: String
        public let optionCount: Int
        public let options: [LMFeedDisplayPollWidget.ContentModel]
        
        public init(question: String, showEditIcon: Bool, showCrossIcon: Bool, expiryDate: Date, optionState: String, optionCount: Int, options: [LMFeedDisplayPollWidget.ContentModel]) {
            self.question = question
            self.showEditIcon = showEditIcon
            self.showCrossIcon = showCrossIcon
            self.expiryDate = expiryDate
            self.optionState = optionState
            self.optionCount = optionCount
            self.options = options
        }
        
        public var expiryDateFormatted: String {
            if expiryDate <= Date() {
                return "Poll Ended"
            }
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd MMM yyyy hh:mm a"

            let dateString = dateFormatter.string(from: expiryDate)
            
            return "Expires on \(dateString)"
        }
        
        public var optionStringFormatted: String {
            "*Select \(optionState.lowercased()) \(optionCount) \(optionCount == 1 ? "option" : "options")"
        }
    }
    
    // MARK: UI Elements
    open private(set) lazy var containerView: LMView = {
        let view = LMView().translatesAutoresizingMaskIntoConstraints()
        view.backgroundColor = Appearance.shared.colors.clear
        return view
    }()
    
    open private(set) lazy var questionStackView: LMStackView = {
        let stack = LMStackView().translatesAutoresizingMaskIntoConstraints()
        stack.axis = .horizontal
        stack.alignment = .top
        stack.distribution = .fill
        stack.spacing = 8
        return stack
    }()
    
    open private(set) lazy var questionTitle: LMLabel = {
        let label = LMLabel().translatesAutoresizingMaskIntoConstraints()
        label.numberOfLines = 0
        label.textColor = Appearance.shared.colors.gray51
        label.font = Appearance.shared.fonts.headingFont1
        return label
    }()
    
    open private(set) lazy var crossButton: LMButton = {
        let button = LMButton().translatesAutoresizingMaskIntoConstraints()
        button.setTitle(nil, for: .normal)
        button.setImage(Constants.shared.images.crossIcon, for: .normal)
        button.setPreferredSymbolConfiguration(UIImage.SymbolConfiguration(font: Appearance.shared.fonts.headingFont1), forImageIn: .normal)
        button.tintColor = Appearance.shared.colors.gray51
        return button
    }()
    
    open private(set) lazy var editButton: LMButton = {
        let button = LMButton().translatesAutoresizingMaskIntoConstraints()
        button.setTitle(nil, for: .normal)
        button.setImage(Constants.shared.images.pencilIcon, for: .normal)
        button.setPreferredSymbolConfiguration(UIImage.SymbolConfiguration(font: Appearance.shared.fonts.headingFont1), forImageIn: .normal)
        button.tintColor = Appearance.shared.colors.gray51
        return button
    }()
    
    open private(set) lazy var optionSelectCountLabel: LMLabel = {
        let label = LMLabel().translatesAutoresizingMaskIntoConstraints()
        label.textColor = Appearance.shared.colors.gray155
        label.font = Appearance.shared.fonts.buttonFont1
        label.numberOfLines = 0
        return label
    }()
    
    open private(set) lazy var optionStackView: LMStackView = {
        let stack = LMStackView().translatesAutoresizingMaskIntoConstraints()
        stack.axis = .vertical
        stack.alignment = .fill
        stack.distribution = .fillEqually
        stack.spacing = 16
        return stack
    }()
    
    open private(set) lazy var expiryDateLabel: LMLabel = {
        let label = LMLabel().translatesAutoresizingMaskIntoConstraints()
        label.textColor = Appearance.shared.colors.gray102
        label.font = Appearance.shared.fonts.subHeadingFont1
        label.numberOfLines = 0
        return label
    }()
    
    
    // MARK: Data variables
    open var buttonSize: CGFloat { 24 }
    public weak var delegate: LMFeedDisplayPollViewProtocol?
    
    // MARK: setupViews
    open override func setupViews() {
        super.setupViews()
        
        addSubview(containerView)
        
        containerView.addSubview(questionStackView)
        containerView.addSubview(optionSelectCountLabel)
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
        
        questionStackView.addConstraint(top: (containerView.topAnchor, 16),
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
            let optionView = LMFeedDisplayPollWidget().translatesAutoresizingMaskIntoConstraints()
            optionView.configure(with: option)
            optionStackView.addArrangedSubview(optionView)
        }
        
        expiryDateLabel.text = data.expiryDateFormatted
    }
}
