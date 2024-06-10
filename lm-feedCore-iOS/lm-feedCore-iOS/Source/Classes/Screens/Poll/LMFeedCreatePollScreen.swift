//
//  LMFeedCreatePollScreen.swift
//  LikeMindsFeedCore
//
//  Created by Devansh Mohata on 06/06/24.
//

import LikeMindsFeedUI
import UIKit

public protocol LMFeedCreatePollProtocol: AnyObject {
    func updatePollDetails(with data: LMFeedCreatePollDataModel)
    func cancelledPollCreation()
}

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
    public weak var pollDelegate: LMFeedCreatePollProtocol?
    
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
        
        view.backgroundColor = Appearance.shared.colors.backgroundColor
    }
    
    
    // MARK: setupActions
    open override func setupActions() {
        super.setupActions()
        
        advancedOptionButton.addTarget(self, action: #selector(onTapAdvancedOption), for: .touchUpInside)
        pollExpiryDateView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(openDatePicker)))
        
        let rightBarButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(didTapDoneButton))
        navigationItem.rightBarButtonItem = rightBarButton
        
        let leftBarButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(dismissPollWidget))
        navigationItem.leftBarButtonItem = leftBarButton
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
        viewmodel?.openDatePicker()
    }
    
    @objc
    open func didTapDoneButton() {
        let question = pollQuestionHeaderView.retrivePollQestion()
        let options = pollOptionView.retrieveTextFromOptions()
        
        viewmodel?.validatePoll(with: question, options: options)
    }
    
    @objc
    open func dismissPollWidget() {
        pollDelegate?.cancelledPollCreation()
        navigationController?.popViewController(animated: true)
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
    }
    
    public func showMetaOptionsPickerView(with data: LMFeedGeneralPicker.ContentModel) {
        let vc = LMFeedGeneralPicker()
        vc.configure(with: data, delegate: self)
        vc.modalPresentationStyle = .overFullScreen
        present(vc, animated: true)
    }
    
    public func updateMetaOption(with option: String, count: Int) {
        pollMetaOptionsView.updateUserMetaOption(option: option, count: count)
    }
    
    public func presentDatePicker(with selectedDate: Date, minimumDate: Date) {
        let viewcontroller = LMFeedTimePicker()
        viewcontroller.configure(selecteDate: selectedDate, minimumDate: minimumDate, delegate: self)
        viewcontroller.modalPresentationStyle = .overFullScreen
        
        present(viewcontroller, animated: true)
    }
    
    public func updatePoll(with data: LMFeedCreatePollDataModel) {
        pollDelegate?.updatePollDetails(with: data)
        navigationController?.popViewController(animated: true)
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
    public func textValueChanged(for id: Int, newValue: String?) {
        viewmodel?.updatePollOption(for: id, option: newValue)
    }
    
    public func onCrossButtonTapped(for id: Int) {
        viewmodel?.removePollOption(at: id)
    }
    
    public func onAddNewOptionTapped() {
        viewmodel?.insertPollOption()
    }
}


// MARK: LMFeedCreatePollMetaViewProtocol
extension LMFeedCreatePollScreen: LMFeedCreatePollMetaViewProtocol {
    public func onValueChanged(for id: Int) {
        viewmodel?.metaValueChanged(for: id)
    }
    
    public func onTapUserMetaOptions() {
        viewmodel?.showMetaOptionsPicker()
    }
}


// MARK: LMFeedGeneralPickerProtocol
extension LMFeedCreatePollScreen: LMFeedGeneralPickerProtocol {
    public func didSelectRowAt(index: [Int]) {
        viewmodel?.updateMetaOptionPicker(with: index)
    }
}


// MARK: LMFeedTimePickerProtocol
extension LMFeedCreatePollScreen: LMFeedTimePickerProtocol {
    public func didSelectTime(at date: Date) {
        viewmodel?.updatePollExpiryDate(with: date)
    }
}
