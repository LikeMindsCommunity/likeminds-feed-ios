//
//  LMFeedPollCreationScreen.swift
//  LikeMindsFeedCore
//
//  Created by Devansh Mohata on 06/06/24.
//

import LikeMindsFeedUI
import UIKit

open class LMFeedPollCreationScreen: LMViewController {
    open private(set) lazy var containerView: LMView = {
        let view = LMView().translatesAutoresizingMaskIntoConstraints()
        view.backgroundColor = .clear
        return view
    }()
    
    open private(set) lazy var containerScrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        scroll.showsHorizontalScrollIndicator = false
        scroll.showsVerticalScrollIndicator = false
        scroll.backgroundColor = .clear
        return scroll
    }()
    
    open private(set) lazy var containerStackView: LMStackView = {
        let stack = LMStackView().translatesAutoresizingMaskIntoConstraints()
        stack.axis = .vertical
        stack.alignment = .fill
        stack.distribution = .fill
        stack.spacing = 16
        stack.backgroundColor = .clear
        return stack
    }()
    
    open private(set) lazy var pollQuestionHeaderView: LMFeedCreatePollHeader = {
        let header = LMFeedCreatePollHeader().translatesAutoresizingMaskIntoConstraints()
        return header
    }()
    
    open private(set) lazy var pollOptionView: LMFeedCreatePollQuestionView = {
        let view = LMFeedCreatePollQuestionView().translatesAutoresizingMaskIntoConstraints()
        return view
    }()
    
    open private(set) lazy var pollExpiryDateView: LMFeedCreatePollDateView = {
        let view = LMFeedCreatePollDateView().translatesAutoresizingMaskIntoConstraints()
        return view
    }()
    
    open private(set) lazy var pollExpiryDateView2: LMFeedCreatePollDateView = {
        let view = LMFeedCreatePollDateView().translatesAutoresizingMaskIntoConstraints()
        return view
    }()
    
    
    open private(set) lazy var pollExpiryDateView3: LMFeedCreatePollDateView = {
        let view = LMFeedCreatePollDateView().translatesAutoresizingMaskIntoConstraints()
        return view
    }()
    
    open private(set) lazy var pollMetaOptionsView: LMFeedCreatePollMetaView = {
        let view = LMFeedCreatePollMetaView().translatesAutoresizingMaskIntoConstraints()
        return view
    }()
    
    open override func setupViews() {
        super.setupViews()
        
        view.addSubview(containerView)
        containerView.addSubview(containerScrollView)
        containerScrollView.addSubview(containerStackView)
        
        containerStackView.addArrangedSubview(pollQuestionHeaderView)
        containerStackView.addArrangedSubview(pollOptionView)
        containerStackView.addArrangedSubview(pollExpiryDateView)
        containerStackView.addArrangedSubview(pollExpiryDateView2)
        containerStackView.addArrangedSubview(pollExpiryDateView3)
        containerStackView.addArrangedSubview(pollMetaOptionsView)
    }
    
    open override func setupLayouts() {
        super.setupLayouts()
        
        view.safePinSubView(subView: containerView)
        containerView.pinSubView(subView: containerScrollView)
        
        containerStackView.addConstraint(top: (containerScrollView.contentLayoutGuide.topAnchor, 0),
                                         bottom: (containerScrollView.contentLayoutGuide.bottomAnchor, 0),
                                         leading: (containerScrollView.contentLayoutGuide.leadingAnchor, 0),
                                         trailing: (containerScrollView.contentLayoutGuide.trailingAnchor, 0))
        
        
        containerStackView.setHeightConstraint(with: 100, priority: .defaultLow)
        containerStackView.setWidthConstraint(with: containerScrollView.frameLayoutGuide.widthAnchor, multiplier: 1)
        containerStackView.setHeightConstraint(with: containerScrollView.frameLayoutGuide.heightAnchor, priority: .defaultLow, multiplier: 1)
    }
    
    open override func setupAppearance() {
        super.setupAppearance()
        view.backgroundColor = Appearance.shared.colors.gray4
    }
}
