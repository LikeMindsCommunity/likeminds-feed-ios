//
//  LMFeedCreatePollHeader.swift
//  LikeMindsFeedUI
//
//  Created by Devansh Mohata on 06/06/24.
//

import UIKit

@IBDesignable
open class LMFeedCreatePollHeader: LMView {
    public struct ContentModel {
        let profileImage: String?
        let username: String
        let pollQuestion: String?
        
        public init(profileImage: String?, username: String, pollQuestion: String?) {
            self.profileImage = profileImage
            self.username = username
            self.pollQuestion = pollQuestion
        }
    }
    
    
    // MARK: UI Elements
    open private(set) lazy var containerView: LMView = {
        let view = LMView().translatesAutoresizingMaskIntoConstraints()
        view.backgroundColor = LMFeedAppearance.shared.colors.white
        return view
    }()
    
    open private(set) lazy var userProfileImage: LMFeedProfileImageView = {
        let image = LMFeedProfileImageView().translatesAutoresizingMaskIntoConstraints()
        image.clipsToBounds = true
        return image
    }()
    
    open private(set) lazy var userNameLabel: LMLabel = {
        let label = LMLabel().translatesAutoresizingMaskIntoConstraints()
        label.font = LMFeedAppearance.shared.fonts.headingFont1
        label.textColor = LMFeedAppearance.shared.colors.gray1
        label.text = "Devansh Mohata"
        return label
    }()
    
    open private(set) lazy var pollQuestionTitle: LMLabel = {
        let label = LMLabel().translatesAutoresizingMaskIntoConstraints()
        label.font = LMFeedAppearance.shared.fonts.buttonFont2
        label.textColor = .blue // LMFeedAppearance.shared.colors.appTintColor
        label.text = "Poll question"
        return label
    }()
    
    open private(set) lazy var pollQuestionTextField: LMTextView = {
        let textView = LMTextView().translatesAutoresizingMaskIntoConstraints()
        textView.placeHolderText = textFieldPlaceholderText
        textView.addDoneButtonOnKeyboard()
        textView.delegate = self
        textView.isUserInteractionEnabled = true
        textView.textColor = LMFeedAppearance.shared.colors.gray4.withAlphaComponent(1)
        textView.text = textFieldPlaceholderText
        textView.font = LMFeedAppearance.shared.fonts.textFont1
        return textView
    }()
    
    
    // MARK: Data Variables
    open var userImageSize: CGFloat { 40 }
    open var textFieldHeight: CGFloat { 64 }
    open var textFieldPlaceholderText: String { "Ask a question" }
    
    // MARK: setupViews
    open override func setupViews() {
        super.setupViews()
        addSubview(containerView)
        
        containerView.addSubview(userProfileImage)
        containerView.addSubview(userNameLabel)
        containerView.addSubview(pollQuestionTitle)
        containerView.addSubview(pollQuestionTextField)
    }
    
    
    // MARK: setupLayouts
    open override func setupLayouts() {
        super.setupLayouts()
        
        containerView.addConstraint(top: (topAnchor, 0),
                                    leading: (leadingAnchor, 0),
                                    trailing: (trailingAnchor, 0))
        containerView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        
        userProfileImage.addConstraint(top: (containerView.topAnchor, 16),
                                       leading: (containerView.leadingAnchor, 16))
        
        userProfileImage.setWidthConstraint(with: userImageSize)
        userProfileImage.setHeightConstraint(with: userImageSize)
        
        userNameLabel.addConstraint(leading: (userProfileImage.trailingAnchor, 16),
                                    centerY: (userProfileImage.centerYAnchor, 0))
        userNameLabel.trailingAnchor.constraint(lessThanOrEqualTo: containerView.trailingAnchor, constant: -16).isActive = true
        
        pollQuestionTitle.addConstraint(top: (userProfileImage.bottomAnchor, 16),
                                        leading: (userProfileImage.leadingAnchor, 0))
        pollQuestionTitle.trailingAnchor.constraint(greaterThanOrEqualTo: containerView.trailingAnchor, constant: -16).isActive = true
        
        pollQuestionTextField.addConstraint(top: (pollQuestionTitle.bottomAnchor, 16),
                                            bottom: (containerView.bottomAnchor, -16),
                                            leading: (pollQuestionTitle.leadingAnchor, 0),
                                            trailing: (containerView.trailingAnchor, -16))
        pollQuestionTextField.setHeightConstraint(with: textFieldHeight)
    }
    
    
    // MARK: setupAppearance
    open override func setupAppearance() {
        super.setupAppearance()
        
        userProfileImage.roundCorners(with: userImageSize / 2)
    }
    
    
    // MARK: configure
    open func configure(with data: ContentModel) {
        userProfileImage.configure(
            with: data.profileImage,
            userName: data.username)
        
        
        userNameLabel.text = data.username
        
        if let question = data.pollQuestion,
           !question.isEmpty {
            pollQuestionTextField.textColor = LMFeedAppearance.shared.colors.black
            pollQuestionTextField.text = question
        }
    }
    
    public func retrivePollQestion() -> String? {
        let text = pollQuestionTextField.text.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !text.isEmpty,
              text != textFieldPlaceholderText else { return nil }
        
        return text
    }
}

extension LMFeedCreatePollHeader: UITextViewDelegate {
    open func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text.trimmingCharacters(in: .whitespacesAndNewlines) == textFieldPlaceholderText {
            textView.textColor = LMFeedAppearance.shared.colors.black
            textView.text = ""
        }
    }
    
    open func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            textView.textColor = LMFeedAppearance.shared.colors.gray4.withAlphaComponent(1)
            textView.text = textFieldPlaceholderText
        }
    }
}
