//
//  LMFeedCreatePollMetaView.swift
//  LikeMindsFeedUI
//
//  Created by Devansh Mohata on 07/06/24.
//

import UIKit

public protocol LMFeedCreatePollMetaViewProtocol: AnyObject {
    func onTapUserMetaOptions()
}

open class LMFeedCreatePollMetaView: LMView {
    public struct ContentModel {
        public let metaOptions: [LMFeedCreatePollMetaOptionWidget.ContentModel]
        public let optionState: String
        public let optionCount: Int
        
        public init(metaOptions: [LMFeedCreatePollMetaOptionWidget.ContentModel], optionState: String, optionCount: Int) {
            self.metaOptions = metaOptions
            self.optionState = optionState
            self.optionCount = optionCount
        }
        
        public var optionCountFormatted: String {
            return "\(optionCount) option\(optionCount == 1 ? "" : "s")"
        }
    }
    
    
    // MARK: UI Elements
    open private(set) lazy var containerView: LMView = {
        let view = LMView().translatesAutoresizingMaskIntoConstraints()
        return view
    }()
    
    open private(set) lazy var metaOptionStackView: LMStackView = {
        let stack = LMStackView().translatesAutoresizingMaskIntoConstraints()
        stack.axis = .vertical
        stack.alignment = .fill
        stack.distribution = .fillEqually
        stack.spacing = 8
        return stack
    }()
    
    open private(set) lazy var optionContainerView: LMView = {
        let view = LMView().translatesAutoresizingMaskIntoConstraints()
        return view
    }()
    
    open private(set) lazy var titleLabel: LMLabel = {
        let label = LMLabel().translatesAutoresizingMaskIntoConstraints()
        label.font = Appearance.shared.fonts.buttonFont1
        label.textColor = Appearance.shared.colors.gray155
        label.text = "User can vote for"
        return label
    }()
    
    open private(set) lazy var optionTypeButton: LMFeedCreatePollUserOptionWidget = {
        let view = LMFeedCreatePollUserOptionWidget().translatesAutoresizingMaskIntoConstraints()
        return view
    }()
    
    open private(set) lazy var maxOptionButton: LMFeedCreatePollUserOptionWidget = {
        let view = LMFeedCreatePollUserOptionWidget().translatesAutoresizingMaskIntoConstraints()
        return view
    }()
    
    open private(set) lazy var equalSymbol: LMImageView = {
        let image = Constants.shared.images.equalIcon.withConfiguration(UIImage.SymbolConfiguration(font: .systemFont(ofSize: 24)))
        let imageView = LMImageView(image: image)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    open private(set) lazy var optionPickerStackView: LMStackView = {
        let stack = LMStackView().translatesAutoresizingMaskIntoConstraints()
        stack.axis = .vertical
        stack.alignment = .fill
        stack.distribution = .fill
        stack.spacing = 0
        return stack
    }()
 
    open private(set) lazy var pickerView: LMFeedPickerView = {
        let picker = LMFeedPickerView()
        picker.isHidden = true
        picker.translatesAutoresizingMaskIntoConstraints = false
        picker.dataSource = self
        picker.delegate = self
        return picker
    }()
    
    open private(set) lazy var pickerDoneButtonStack: LMStackView = {
        let stack = LMStackView().translatesAutoresizingMaskIntoConstraints()
        stack.axis = .horizontal
        stack.alignment = .fill
        stack.distribution = .fill
        stack.spacing = 0
        stack.isHidden = true
        return stack
    }()
    
    open private(set) lazy var doneButton: LMButton = {
        let button = LMButton().translatesAutoresizingMaskIntoConstraints()
        button.setTitle("Done", for: .normal)
        button.setImage(nil, for: .normal)
        button.setTitleColor(Appearance.shared.colors.appTintColor, for: .normal)
        button.setFont(Appearance.shared.fonts.buttonFont1)
        button.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        button.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        return button
    }()
    
    open private(set) lazy var cancelButton: LMButton = {
        let button = LMButton().translatesAutoresizingMaskIntoConstraints()
        button.setTitle("Cancel", for: .normal)
        button.setImage(nil, for: .normal)
        button.setTitleColor(Appearance.shared.colors.appTintColor, for: .normal)
        button.setFont(Appearance.shared.fonts.buttonFont1)
        button.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        button.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        return button
    }()
    
    open private(set) lazy var spacerView: LMView = {
        let view = LMView().translatesAutoresizingMaskIntoConstraints()
        view.backgroundColor = Appearance.shared.colors.clear
        view.setContentHuggingPriority(.defaultLow, for: .horizontal)
        return view
    }()
    
    open private(set) lazy var sepratorView: LMView = {
        let view = LMView().translatesAutoresizingMaskIntoConstraints()
        view.backgroundColor = Appearance.shared.colors.gray102
        return view
    }()
    
    
    // MARK: LMFeedCreatePollMetaViewProtocol
    public weak var delegate: LMFeedCreatePollMetaViewProtocol?
    public var userOptions: [[String]] = []
    
    // MARK: setupViews
    open override func setupViews() {
        super.setupViews()
        
        addSubview(containerView)
        containerView.addSubview(metaOptionStackView)
        containerView.addSubview(optionContainerView)
        containerView.addSubview(optionPickerStackView)
        
        optionContainerView.addSubview(titleLabel)
        optionContainerView.addSubview(optionTypeButton)
        optionContainerView.addSubview(maxOptionButton)
        optionContainerView.addSubview(equalSymbol)
        
        optionPickerStackView.addArrangedSubview(sepratorView)
        optionPickerStackView.addArrangedSubview(pickerDoneButtonStack)
        optionPickerStackView.addArrangedSubview(pickerView)
        
        pickerDoneButtonStack.addArrangedSubview(cancelButton)
        pickerDoneButtonStack.addArrangedSubview(spacerView)
        pickerDoneButtonStack.addArrangedSubview(doneButton)
        
    }
    
    
    // MARK: setupLayouts
    open override func setupLayouts() {
        super.setupLayouts()
        
        pinSubView(subView: containerView)
        
        metaOptionStackView.addConstraint(top: (containerView.topAnchor, 0),
                                          leading: (containerView.leadingAnchor, 0),
                                          trailing: (containerView.trailingAnchor, 0))
        
        optionContainerView.addConstraint(top: (metaOptionStackView.bottomAnchor, 0),
                                          leading: (containerView.leadingAnchor, 0),
                                          trailing: (containerView.trailingAnchor, 0))
        
        optionPickerStackView.addConstraint(top: (optionContainerView.bottomAnchor, 0),
                                            bottom: (containerView.bottomAnchor, 0),
                                            leading: (optionContainerView.leadingAnchor, 16),
                                            trailing: (optionContainerView.trailingAnchor, -16))
        
        titleLabel.addConstraint(top: (optionContainerView.topAnchor, 8),
                                 leading: (optionContainerView.leadingAnchor, 16))
        titleLabel.trailingAnchor.constraint(greaterThanOrEqualTo: optionContainerView.trailingAnchor, constant: -16).isActive = true
        
        optionTypeButton.addConstraint(top: (titleLabel.bottomAnchor, 8),
                                       bottom: (optionContainerView.bottomAnchor, -16),
                                       leading: (titleLabel.leadingAnchor, 0))
        
        equalSymbol.addConstraint(centerX: (optionContainerView.centerXAnchor, 0), 
                                  centerY: (optionTypeButton.centerYAnchor, 0))
        equalSymbol.leadingAnchor.constraint(greaterThanOrEqualTo: optionTypeButton.trailingAnchor, constant: 24).isActive = true
        equalSymbol.trailingAnchor.constraint(lessThanOrEqualTo: maxOptionButton.leadingAnchor, constant: -24).isActive = true
        
        maxOptionButton.addConstraint(top: (optionTypeButton.topAnchor, 0),
                                       bottom: (optionTypeButton.bottomAnchor, 0),
                                      trailing: (optionContainerView.trailingAnchor, -16))
        
        sepratorView.setHeightConstraint(with: 1)
    }
    
    
    // MARK: setupAppearance
    open override func setupAppearance() {
        super.setupAppearance()
        containerView.backgroundColor = Appearance.shared.colors.white
    }
    
    
    // MARK: setupActions
    open override func setupActions() {
        optionTypeButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onTapUserMetaOptions)))
        maxOptionButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onTapUserMetaOptions)))
        doneButton.addTarget(self, action: #selector(didTapDoneButton), for: .touchUpInside)
        cancelButton.addTarget(self, action: #selector(didTapCancelButton), for: .touchUpInside)
    }
    
    @objc
    open func onTapUserMetaOptions() {
        delegate?.onTapUserMetaOptions()
    }
    
    @objc
    open func didTapDoneButton() {
        print("Done")
        showHidePickerView(isShow: false)
    }
    
    @objc
    open func didTapCancelButton() {
        showHidePickerView(isShow: false)
    }
    
    
    // MARK: configure
    open func configure(with data: ContentModel, delegate: LMFeedCreatePollMetaViewProtocol?) {
        self.delegate = delegate
        
        data.metaOptions.forEach { option in
            let view = LMFeedCreatePollMetaOptionWidget().translatesAutoresizingMaskIntoConstraints()
            view.configure(with: option)
            metaOptionStackView.insertArrangedSubview(view, at: 0)
        }
        
        optionTypeButton.configure(with: data.optionState)
        maxOptionButton.configure(with: data.optionCountFormatted)
    }
    
    open func displayUserMetaOptions(with data: [[String]], selectedOption: Int, selectedOptionCount: Int) {
        userOptions = data
        
        pickerView.reloadAllComponents()
        pickerView.selectRow(selectedOption, inComponent: 0, animated: true)
        pickerView.selectRow(selectedOptionCount, inComponent: 1, animated: true)
        
        showHidePickerView(isShow: true)
    }
    
    open func showHidePickerView(isShow: Bool) {
        UIView.animate(withDuration: isShow ? 0.3 : 0.1) { [weak optionPickerStackView] in
            optionPickerStackView?.subviews.forEach {
                $0.isHidden = !isShow
            }
        }
    }
}


// MARK: UIPickerViewDataSource
extension LMFeedCreatePollMetaView: UIPickerViewDataSource, UIPickerViewDelegate {
    open func numberOfComponents(in pickerView: UIPickerView) -> Int {
        userOptions.count
    }
    
    open func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        userOptions[component].count
    }
    
    open func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        userOptions[component][row]
    }
}
