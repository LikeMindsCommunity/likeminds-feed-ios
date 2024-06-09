//
//  LMFeedCreatePollScreen.swift
//  LikeMindsFeedCore
//
//  Created by Devansh Mohata on 06/06/24.
//

import LikeMindsFeedUI
import UIKit

open class LMFeedCreatePollScreen: LMViewController {
    // MARK: UI Elements
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
        view.isUserInteractionEnabled = true
        return view
    }()
    
    open private(set) lazy var pollMetaOptionsView: LMFeedCreatePollMetaView = {
        let view = LMFeedCreatePollMetaView().translatesAutoresizingMaskIntoConstraints()
        view.isHidden = true
        return view
    }()
    
    open private(set) lazy var advancedOptionButton: LMButton = {
        let button = LMButton.createButton(with: "ADVANCED", image: chevronIcon, textColor: Appearance.shared.colors.gray102, textFont: Appearance.shared.fonts.buttonFont3, imageSpacing: 4)
        button.tintColor = Appearance.shared.colors.gray102
        button.semanticContentAttribute = .forceRightToLeft
        
        return button
    }()
    
    open var chevronIcon: UIImage {
        if pollMetaOptionsView.isHidden {
            return Constants.shared.images.chevronDownIcon.withConfiguration(UIImage.SymbolConfiguration(font: Appearance.shared.fonts.buttonFont3))
        } else {
            return Constants.shared.images.chevronUpIcon.withConfiguration(UIImage.SymbolConfiguration(font: Appearance.shared.fonts.buttonFont3))
        }
    }
    
    
    // MARK: Data Variables
    public var viewmodel: LMFeedCreatePollViewModel?
    
    
    // MARK: setupViews
    open override func setupViews() {
        super.setupViews()
        
        view.addSubview(containerView)
        containerView.addSubview(containerScrollView)
        containerScrollView.addSubview(containerStackView)
        
        containerStackView.addArrangedSubview(pollQuestionHeaderView)
        containerStackView.addArrangedSubview(pollOptionView)
        containerStackView.addArrangedSubview(pollExpiryDateView)
        containerStackView.addArrangedSubview(pollMetaOptionsView)
        containerStackView.addArrangedSubview(advancedOptionButton)
    }
    
    
    // MARK: setupLayouts
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
    
    
    // MARK: setupAppearance
    open override func setupAppearance() {
        super.setupAppearance()
        
        view.backgroundColor = Appearance.shared.colors.gray4
    }
    
    
    // MARK: setupActions
    open override func setupActions() {
        super.setupActions()
        
        advancedOptionButton.addTarget(self, action: #selector(onTapAdvancedOption), for: .touchUpInside)
        pollExpiryDateView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(openDatePicker)))
    }
    
    @objc
    open func onTapAdvancedOption() {
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.pollMetaOptionsView.isHidden.toggle()
            self?.advancedOptionButton.setImage(self?.chevronIcon, for: .normal)
        }
    }
    
    @objc
    open func openDatePicker() {
        let picker = UIDatePicker()
        picker.datePickerMode = .dateAndTime
    }
    
    // MARK: viewDidLoad
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        pollMetaOptionsView.isHidden = true
        viewmodel?.loadInitialData()
    }
}


// MARK: LMFeedCreatePollViewModelProtocol
extension LMFeedCreatePollScreen: LMFeedCreatePollViewModelProtocol {
    public func configure(pollHeaderData: LMFeedCreatePollHeader.ContentModel, pollOptionsData: [LMFeedCreatePollOptionWidget.ContentModel], metaOptions: LMFeedCreatePollMetaView.ContentModel, expiryDate: Date?) {
        pollQuestionHeaderView.configure(with: pollHeaderData)
        pollOptionView.configure(with: pollOptionsData, delegate: self)
        pollMetaOptionsView.configure(with: metaOptions, delegate: self)
        
        if let expiryDate {
            pollExpiryDateView.configure(with: expiryDate, delegate: self)
        }
    }
    
    public func updateExpiryDate(with newDate: Date) {
        pollExpiryDateView.updateExpiryDate(with: newDate)
    }
    
    public func updatePollOptions(with newData: [LikeMindsFeedUI.LMFeedCreatePollOptionWidget.ContentModel]) {
        pollOptionView.updateOptions(with: newData)
        
        pollMetaOptionsView.showHidePickerView(isShow: false)
        pollExpiryDateView.showHidePickerView(isShow: false)
    }
    
    public func showMetaOptionsPickerView(with components: [[String]], selectedOptionRow: Int, selectedOptionCountRow: Int) {
        pollMetaOptionsView.displayUserMetaOptions(with: components, selectedOption: selectedOptionRow, selectedOptionCount: selectedOptionCountRow)
    }
}


// MARK: LMFeedCreatePollDateViewProtocol
extension LMFeedCreatePollScreen: LMFeedCreatePollDateViewProtocol {
    public func onDateChanged(newDate: Date) {
        viewmodel?.updatePollExpiryDate(with: newDate)
    }
}


// MARK: LMFeedCreatePollQuestionViewProtocol
extension LMFeedCreatePollScreen: LMFeedCreatePollQuestionViewProtocol {
    public func onCrossButtonTapped(for id: Int) {
        viewmodel?.removePollOption(at: id)
    }
    
    public func onAddNewOptionTapped() {
        viewmodel?.insertPollOption()
    }
}


// MARK: LMFeedCreatePollMetaViewProtocol
extension LMFeedCreatePollScreen: LMFeedCreatePollMetaViewProtocol {
    public func onTapUserMetaOptions() {
        viewmodel?.showMetaOptionsPicker()
    }
}
