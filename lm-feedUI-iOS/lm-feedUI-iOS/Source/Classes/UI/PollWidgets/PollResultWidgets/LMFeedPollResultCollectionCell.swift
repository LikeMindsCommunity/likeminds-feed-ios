//
//  LMFeedPollResultCollectionCell.swift
//  LikeMindsFeedUI
//
//  Created by Devansh Mohata on 17/06/24.
//

import UIKit

open class LMFeedPollResultCollectionCell: LMCollectionViewCell {
    public struct ContentModel {
        public let optionID: String
        public let title: String
        public let voteCount: Int
        public var isSelected: Bool
        
        public init(optionID: String, title: String, voteCount: Int, isSelected: Bool) {
            self.optionID = optionID
            self.title = title
            self.voteCount = voteCount
            self.isSelected = isSelected
        }
    }
    
    
    // MARK: UI Elements
    open private(set) lazy var stackView: LMStackView = {
        let stack = LMStackView().translatesAutoresizingMaskIntoConstraints()
        stack.axis = .vertical
        stack.alignment = .fill
        stack.distribution = .fillEqually
        stack.spacing = 8
        return stack
    }()
    
    open private(set) lazy var voteCountLabel: LMLabel = {
        let label = LMLabel().translatesAutoresizingMaskIntoConstraints()
        label.font = Appearance.shared.fonts.headingFont1
        label.textAlignment = .center
        return label
    }()
    
    open private(set) lazy var voteTitleLabel: LMLabel = {
        let label = LMLabel().translatesAutoresizingMaskIntoConstraints()
        label.font = Appearance.shared.fonts.headingFont1
        label.textAlignment = .center
        return label
    }()
    
    open private(set) lazy var sepratorView: LMView = {
        let view = LMView().translatesAutoresizingMaskIntoConstraints()
        view.backgroundColor = Appearance.shared.colors.clear
        return view
    }()
    
    
    // MARK: Data Variables
    open var selectedPollColor: UIColor {
        UIColor(r: 80, g: 70, b: 229)
    }
    
    open var notSelectedPollColor: UIColor {
        UIColor(r: 102, g: 102, b: 102)
    }
    
    open override func setupViews() {
        super.setupViews()
        
        contentView.addSubview(containerView)
        containerView.addSubview(stackView)
        containerView.addSubview(sepratorView)
        
        stackView.addArrangedSubview(voteCountLabel)
        stackView.addArrangedSubview(voteTitleLabel)
    }
    
    open override func setupLayouts() {
        super.setupLayouts()
        
        contentView.pinSubView(subView: containerView)
        
        stackView.addConstraint(top: (containerView.topAnchor, 8),
                                leading: (containerView.leadingAnchor, 8),
                                trailing: (containerView.trailingAnchor, -8))
        
        sepratorView.addConstraint(top: (stackView.bottomAnchor, 0),
                                   bottom: (containerView.bottomAnchor, 0),
                                   leading: (containerView.leadingAnchor, 0),
                                   trailing: (containerView.trailingAnchor, 0))
        sepratorView.setHeightConstraint(with: 4)
        sepratorView.layer.cornerRadius = 2
        
        containerView.pinSubView(subView: stackView, padding: .init(top: 8, left: 8, bottom: -8, right: -8))
    }
    
    open func configure(with data: ContentModel) {
        voteCountLabel.text = "\(data.voteCount)"
        voteTitleLabel.text = data.title
        
        voteCountLabel.textColor = data.isSelected ? selectedPollColor : notSelectedPollColor
        voteTitleLabel.textColor = data.isSelected ? selectedPollColor : notSelectedPollColor
        sepratorView.backgroundColor = data.isSelected ? selectedPollColor : Appearance.shared.colors.clear
    }
}
