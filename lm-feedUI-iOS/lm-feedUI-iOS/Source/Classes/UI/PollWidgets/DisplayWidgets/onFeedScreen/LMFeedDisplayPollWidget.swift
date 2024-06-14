//
//  LMFeedDisplayPollWidget.swift
//  LikeMindsFeedUI
//
//  Created by Devansh Mohata on 13/06/24.
//

import UIKit

open class LMFeedDisplayPollWidget: BaseDisplayPollWidget {
    public struct ContentModel {
        public let pollId: String
        public let optionId: String
        public let option: String
        public let addedBy: String?
        public let voteCount: Int
        public let votePercentage: Double
        public let isSelected: Bool
        public let showVoteCount: Bool
        
        public init(pollId: String, optionId: String, option: String, addedBy: String?, voteCount: Int, votePercentage: Double, isSelected: Bool, showVoteCount: Bool) {
            self.pollId = pollId
            self.optionId = optionId
            self.option = option
            self.addedBy = addedBy
            self.voteCount = voteCount
            self.votePercentage = votePercentage
            self.isSelected = isSelected
            self.showVoteCount = showVoteCount
        }
    }
    
    // MARK: UI Elements
    open private(set) lazy var outerStackView: LMStackView = {
        let stack = LMStackView().translatesAutoresizingMaskIntoConstraints()
        stack.axis = .vertical
        stack.alignment = .fill
        stack.distribution = .fill
        return stack
    }()
    
    open private(set) lazy var progressView: UIProgressView = {
        let progress = UIProgressView(progressViewStyle: .default)
        progress.progressTintColor = Appearance.shared.colors.appTintColor.withAlphaComponent(0.1)
        progress.trackTintColor = Appearance.shared.colors.clear
        progress.translatesAutoresizingMaskIntoConstraints = false
        return progress
    }()
    
    open private(set) lazy var voteCountContainer: LMView = {
        let view = LMView().translatesAutoresizingMaskIntoConstraints()
        view.backgroundColor = Appearance.shared.colors.clear
        return view
    }()
    
    open private(set) lazy var voteCount: LMButton = {
        let button = LMButton().translatesAutoresizingMaskIntoConstraints()
        button.setTitle("Vote Count", for: .normal)
        button.setImage(nil, for: .normal)
        button.setFont(Appearance.shared.fonts.buttonFont1)
        button.setTitleColor(Appearance.shared.colors.gray155, for: .normal)
        return button
    }()
    
    open private(set) lazy var innerContainerView: LMView = {
        let view = LMView().translatesAutoresizingMaskIntoConstraints()
        view.backgroundColor = Appearance.shared.colors.clear
        return view
    }()
    
    open private(set) lazy var checkmarkIcon: LMImageView = {
        let image = Constants.shared.images.checkmarkIconFilled
            .applyingSymbolConfiguration(UIImage.SymbolConfiguration(font: Appearance.shared.fonts.headingFont1))
        
        let imageView = LMImageView(image: image)
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.tintColor = Appearance.shared.colors.appTintColor
        return imageView
    }()
    
    
    // MARK: setupViews
    open override func setupViews() {
        super.setupViews()
        
        addSubview(containerView)
        containerView.addSubview(outerStackView)
        
        outerStackView.addArrangedSubview(innerContainerView)
        outerStackView.addArrangedSubview(voteCountContainer)
        
        voteCountContainer.addSubview(voteCount)
        
        innerContainerView.addSubview(stackView)
        innerContainerView.addSubview(checkmarkIcon)
        innerContainerView.addSubview(progressView)
        
        stackView.addArrangedSubview(optionLabel)
        stackView.addArrangedSubview(addedByLabel)
    }
    
    
    // MARK: setupLayouts
    open override func setupLayouts() {
        super.setupLayouts()
        
        pinSubView(subView: containerView)
        containerView.pinSubView(subView: outerStackView)
        
        innerContainerView.addConstraint(leading: (outerStackView.leadingAnchor, 0),
                                         trailing: (outerStackView.trailingAnchor, 0))
        
        voteCount.addConstraint(top: (voteCountContainer.topAnchor, 4),
                                bottom: (voteCountContainer.bottomAnchor, -4),
                                leading: (voteCountContainer.leadingAnchor, 8))
        voteCount.trailingAnchor.constraint(lessThanOrEqualTo: voteCountContainer.trailingAnchor, constant: -8).isActive = true
        
        stackView.addConstraint(top: (innerContainerView.topAnchor, 16),
                                bottom: (innerContainerView.bottomAnchor, -16),
                                leading: (innerContainerView.leadingAnchor, 16))
        
        checkmarkIcon.addConstraint(trailing: (innerContainerView.trailingAnchor, -16),
                                    centerY: (stackView.centerYAnchor, 0))
        checkmarkIcon.setWidthConstraint(with: checkmarkIcon.heightAnchor)
        checkmarkIcon.leadingAnchor.constraint(greaterThanOrEqualTo: stackView.trailingAnchor, constant: 16).isActive = true
        
        innerContainerView.pinSubView(subView: progressView, padding: .init(top: 2, left: 2, bottom: -2, right: -2))
    }
    
    
    // MARK: setupAppearance
    open override func setupAppearance() {
        super.setupAppearance()
        
        innerContainerView.layer.cornerRadius = 8
        innerContainerView.layer.borderColor = Appearance.shared.colors.gray155.cgColor
        innerContainerView.layer.borderWidth = 1
    }
    
    
    open func configure(with data: ContentModel) {
        optionLabel.text = data.option
        
        addedByLabel.text = data.addedBy
        addedByLabel.isHidden = data.addedBy?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty != false
        
        // TODO: Need to write logic for showing and hiding
    }
}
