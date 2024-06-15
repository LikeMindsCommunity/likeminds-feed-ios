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
        public var isAnonymousPoll: Bool
        public var isInstantPoll: Bool
        public var allowAddOptions: Bool
        public var answerText: String
        public var isShowSubmitButton: Bool
        public var isShowEditVote: Bool
        
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
            allowAddOptions: Bool,
            isShowSubmitButton: Bool,
            isShowEditVote: Bool
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
            self.isShowSubmitButton = isShowSubmitButton
            self.isShowEditVote = isShowEditVote
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
        stack.spacing = 8
        return stack
    }()
    
    open private(set) lazy var submitButton: LMButton = {
        let button = LMButton.createButton(with: Constants.shared.strings.submitVote, image: nil, textColor: Appearance.shared.colors.white, textFont: Appearance.shared.fonts.buttonFont2, contentSpacing: .init(top: 8, left: 16, bottom: 8, right: 16))
        button.translatesAutoresizingMaskIntoConstraints = false
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
    
    open private(set) lazy var addOptionButton: LMButton = {
        let button = LMButton.createButton(with: "Add an Option", image: Constants.shared.images.plusIcon, textColor: Appearance.shared.colors.black, textFont: Appearance.shared.fonts.buttonFont1, contentSpacing: .init(top: 8, left: 0, bottom: 8, right: 0), imageSpacing: 4)
        button.tintColor = Appearance.shared.colors.black
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    
    // MARK: Data Variables
    public weak var delegate: LMFeedPostPollCellProtocol?
    public var postID: String?
    public var pollID: String?
    
    
    // MARK: setupViews
    open override func setupViews() {
        super.setupViews()
        
        addSubview(containerView)
        containerView.addSubview(questionContainerStackView)
        
        questionContainerStackView.addArrangedSubview(questionTitle)
        questionContainerStackView.addArrangedSubview(optionSelectCountLabel)
        
        containerView.addSubview(optionStackView)
        
        containerView.addSubview(bottomStack)
        
        bottomStack.addArrangedSubview(addOptionButton)
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
        
        addOptionButton.addConstraint(leading: (bottomStack.leadingAnchor, 0),
                                      trailing: (bottomStack.trailingAnchor, 0))
        
        bottomStack.addConstraint(top: (optionStackView.bottomAnchor, 16),
                                  bottom: (containerView.bottomAnchor, -16),
                                  leading: (optionStackView.leadingAnchor, 0),
                                  trailing: (optionStackView.trailingAnchor, 0))
        
        bottomMetaStack.trailingAnchor.constraint(lessThanOrEqualTo: bottomStack.trailingAnchor, constant: -16).isActive = true
    }
    
    
    // MARK: setupAppearance
    open override func setupAppearance() {
        super.setupAppearance()
        
        addOptionButton.layer.borderColor = Appearance.shared.colors.gray155.cgColor
        addOptionButton.layer.borderWidth = 1
        addOptionButton.layer.cornerRadius = 8
        
        expiryDateLabel.font = Appearance.shared.fonts.textFont1
        
        submitButton.layer.cornerRadius = 8
    }
    
    
    // MARK: setupActions
    open override func setupActions() {
        super.setupActions()
        
        submitButton.addTarget(self, action: #selector(didTapSubmitButton), for: .touchUpInside)
        editVoteLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(editVoteTapped)))
        answerTitleLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(voteCountTapped)))
    }
    
    @objc
    open func didTapSubmitButton() {
        guard let postID,
              let pollID else { return }
        delegate?.didTapSubmitVote(for: postID, pollID: pollID)
    }
    
    @objc
    open func editVoteTapped() {
        guard let postID,
              let pollID else { return }
        
        delegate?.editVoteTapped(for: postID, pollID: pollID)
    }
    
    @objc
    open func voteCountTapped() {
        guard let postID,
              let pollID else { return }
        
        delegate?.didTapVoteCountButton(for: postID, pollID: pollID, optionID: nil)
    }
    
    
    // MARK: configure
    open func configure(with data: ContentModel, delegate: LMFeedPostPollCellProtocol?) {
        self.delegate = delegate
        self.postID = data.postID
        self.pollID = data.pollID
        
        questionTitle.text = data.question
        
        optionSelectCountLabel.text = data.optionStringFormatted
        optionSelectCountLabel.isHidden = !data.isShowOption
        
        optionStackView.removeAllArrangedSubviews()
        
        data.options.forEach { option in
            let optionView = LMFeedDisplayPollWidget().translatesAutoresizingMaskIntoConstraints()
            optionView.configure(with: option, delegate: self)
            optionStackView.addArrangedSubview(optionView)
        }
        
        answerTitleLabel.text = data.answerText
        
        let expiryText = "• \(data.expiryDateFormatted)\(data.isShowEditVote ? " •": "")"
        expiryDateLabel.text = expiryText
        
        addOptionButton.isHidden = !data.allowAddOptions
        
        editVoteLabel.isHidden = !data.isShowEditVote
        
        submitButton.isHidden = !data.isShowSubmitButton
    }
}


// MARK: LMFeedDisplayPollWidgetProtocol
extension LMFeedDisplayPollView: LMFeedDisplayPollWidgetProtocol {
    public func didTapVoteCountButton(optionID: String) {
        guard let postID,
              let pollID else { return }
        delegate?.didTapVoteCountButton(for: postID, pollID: pollID, optionID: optionID)
    }
    
    public func didTapToVote(optionID: String) {
        guard let postID,
              let pollID else { return }
        delegate?.didTapToVote(for: postID, pollID: pollID, optionID: optionID)
    }
}
