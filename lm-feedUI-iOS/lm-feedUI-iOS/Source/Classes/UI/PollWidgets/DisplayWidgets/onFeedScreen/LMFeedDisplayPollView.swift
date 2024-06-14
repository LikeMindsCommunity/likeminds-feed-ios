//
//  LMFeedDisplayPollView.swift
//  LikeMindsFeedUI
//
//  Created by Devansh Mohata on 13/06/24.
//

import UIKit

open class LMFeedDisplayPollView: BaseDisplayPollView {
    public struct ContentModel: BaseDisplayPollView.Content {
        public let postID: String
        public let pollID: String
        public var question: String
        public var options: [LMFeedDisplayPollWidget.ContentModel]
        public var expiryDate: Date
        public var optionState: String
        public var optionCount: Int
        public let isAnonymousPoll: Bool
        public let isInstantPoll: Bool
        public let allowAddOptions: Bool
        public let answerText: String
        
        public init(
            postID: String,
            pollID: String,
            question: String,
            answerText: String,
            options: [LMFeedDisplayPollWidget.ContentModel],
            expiryDate: Date,
            optionState: String,
            optionCount: Int,
            isAnonymousPoll: Bool,
            isInstantPoll: Bool,
            allowAddOptions: Bool
        ) {
            self.postID = postID
            self.pollID = pollID
            self.question = question
            self.options = options
            self.expiryDate = expiryDate
            self.optionState = optionState
            self.optionCount = optionCount
            self.isAnonymousPoll = isAnonymousPoll
            self.isInstantPoll = isInstantPoll
            self.allowAddOptions = allowAddOptions
            self.answerText = answerText
        }
        
        
        public var expiryDateFormatted: String {
            let now = Date()
            
            guard expiryDate > now else {
                return "Poll Ended"
            }
            
            let components = Calendar.current.dateComponents([.day, .hour, .minute], from: now, to: expiryDate)
            
            guard let days = components.day, let hours = components.hour, let minutes = components.minute else {
                return "Just Now"
            }
            
            switch (days, hours, minutes) {
            case (0, 0, let min) where min > 0:
                return "\(min)m left"
            case (0, let hr, _) where hr >= 1:
                return "\(hr)h left "
            case (let d, _, _) where d >= 1:
                return "\(d)d left"
            default:
                return "Just Now"
            }
        }
    }
    
    
    // MARK: UI Elements
    open private(set) lazy var bottomStack: LMStackView = {
        let stack = LMStackView().translatesAutoresizingMaskIntoConstraints()
        stack.axis = .vertical
        stack.alignment = .leading
        stack.distribution = .fill
        stack.spacing = 4
        return stack
    }()
    
    open private(set) lazy var submitButton: LMButton = {
        let button = LMButton().translatesAutoresizingMaskIntoConstraints()
        button.setTitle(Constants.shared.strings.submitVote, for: .normal)
        button.setImage(nil, for: .normal)
        button.backgroundColor = Appearance.shared.colors.appTintColor
        return button
    }()
    
    open private(set) lazy var bottomMetaStack: LMStackView = {
        let stack = LMStackView().translatesAutoresizingMaskIntoConstraints()
        stack.axis = .horizontal
        stack.alignment = .fill
        stack.distribution = .fill
        stack.spacing = 4
        return stack
    }()
    
    open private(set) lazy var answerTitleLabel: LMLabel = {
        let label = LMLabel().translatesAutoresizingMaskIntoConstraints()
        label.textColor = Appearance.shared.colors.appTintColor
        label.font = Appearance.shared.fonts.textFont1
        label.text = "Be the first one to vote"
        return label
    }()
    
    open private(set) lazy var editVoteLabel: LMLabel = {
        let label = LMLabel().translatesAutoresizingMaskIntoConstraints()
        label.textColor = Appearance.shared.colors.appTintColor
        label.font = Appearance.shared.fonts.textFont1
        label.text = "Edit Vote"
        return label
    }()
    
    
    // MARK: setupViews
    open override func setupViews() {
        super.setupViews()
        
        addSubview(containerView)
        containerView.addSubview(questionContainerStackView)
        
        questionContainerStackView.addArrangedSubview(questionTitle)
        questionContainerStackView.addArrangedSubview(optionSelectCountLabel)
        
        containerView.addSubview(optionStackView)
        
        containerView.addSubview(bottomStack)
        
        bottomStack.addArrangedSubview(submitButton)
        bottomStack.addArrangedSubview(bottomMetaStack)
        
        bottomMetaStack.addArrangedSubview(answerTitleLabel)
        bottomMetaStack.addArrangedSubview(expiryDateLabel)
        bottomMetaStack.addArrangedSubview(editVoteLabel)
    }
    
    
    // MARK: setupLayouts
    open override func setupLayouts() {
        super.setupLayouts()
        
        pinSubView(subView: containerView)
        
        questionContainerStackView.addConstraint(top: (containerView.topAnchor, 16),
                                                 leading: (containerView.leadingAnchor, 16),
                                                 trailing: (containerView.trailingAnchor, -16))
        
        optionStackView.addConstraint(top: (questionContainerStackView.bottomAnchor, 16),
                                      leading: (questionContainerStackView.leadingAnchor, -8),
                                      trailing: (questionContainerStackView.trailingAnchor, 8))
        
        bottomStack.addConstraint(top: (optionStackView.bottomAnchor, 16),
                                  bottom: (containerView.bottomAnchor, -16),
                                  leading: (optionStackView.leadingAnchor, 0),
                                  trailing: (optionStackView.trailingAnchor, 0))
        
        bottomMetaStack.trailingAnchor.constraint(lessThanOrEqualTo: bottomStack.trailingAnchor, constant: -16).isActive = true
    }
    
    open func configure(with data: ContentModel) {
        questionTitle.text = data.question
        
        optionSelectCountLabel.text = data.optionStringFormatted
        optionSelectCountLabel.isHidden = !data.isShowOption
        
        optionStackView.removeAllArrangedSubviews()
        
        data.options.forEach { option in
            let optionView = LMFeedDisplayPollWidget().translatesAutoresizingMaskIntoConstraints()
            optionView.configure(with: option)
            optionStackView.addArrangedSubview(optionView)
        }
    }
}
