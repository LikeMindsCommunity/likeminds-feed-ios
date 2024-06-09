//
//  LMFeedTimePicker.swift
//  LikeMindsFeedCore
//
//  Created by Devansh Mohata on 09/06/24.
//

import LikeMindsFeedUI
import UIKit

public protocol LMFeedTimePickerProtocol: AnyObject {
    func didSelectTime(at date: Date)
}

open class LMFeedTimePicker: LMViewController {
    // MARK: UI Elements
    open private(set) lazy var dismissView: LMView = {
        let view = LMView().translatesAutoresizingMaskIntoConstraints()
        return view
    }()
    
    open private(set) lazy var containerView: LMView = {
        let view = LMView().translatesAutoresizingMaskIntoConstraints()
        return view
    }()
    
    open private(set) lazy var pickerView: UIDatePicker = {
        let picker = UIDatePicker()
        picker.translatesAutoresizingMaskIntoConstraints = false
        picker.datePickerMode = .dateAndTime
        if #available(iOS 13.4, *) {
            picker.preferredDatePickerStyle = .wheels
        }
        return picker
    }()
    
    
    open private(set) lazy var doneButtonStackView: LMStackView = {
        let stack = LMStackView().translatesAutoresizingMaskIntoConstraints()
        stack.axis = .horizontal
        stack.alignment = .fill
        stack.distribution = .fill
        stack.spacing = 0
        return stack
    }()
    
    
    open private(set) lazy var doneButton: LMButton = {
        let button = LMButton().translatesAutoresizingMaskIntoConstraints()
        button.setTitle("Done", for: .normal)
        button.setTitleColor(Appearance.shared.colors.appTintColor, for: .normal)
        button.setImage(nil, for: .normal)
        return button
    }()
    
    open private(set) lazy var cancelButton: LMButton = {
        let button = LMButton().translatesAutoresizingMaskIntoConstraints()
        button.setTitle("Cancel", for: .normal)
        button.setTitleColor(Appearance.shared.colors.appTintColor, for: .normal)
        button.setImage(nil, for: .normal)
        return button
    }()
    
    open private(set) lazy var spacerView: LMView = {
        let view = LMView().translatesAutoresizingMaskIntoConstraints()
        view.backgroundColor = Appearance.shared.colors.clear
        view.setContentHuggingPriority(.defaultLow, for: .horizontal)
        return view
    }()
    
    
    // MARK: Data Variables
    public weak var delegate: LMFeedTimePickerProtocol?
    
    
    // MARK: setupViews
    open override func setupViews() {
        super.setupViews()
        
        view.addSubview(dismissView)
        view.addSubview(containerView)
        
        containerView.addSubview(doneButtonStackView)
        containerView.addSubview(pickerView)
        
        doneButtonStackView.addArrangedSubview(cancelButton)
        doneButtonStackView.addArrangedSubview(spacerView)
        doneButtonStackView.addArrangedSubview(doneButton)
    }
    
    
    // MARK: setupLayouts
    open override func setupLayouts() {
        super.setupLayouts()
        
        view.pinSubView(subView: dismissView)
        
        containerView.addConstraint(bottom: (view.safeAreaLayoutGuide.bottomAnchor, 0),
                                    leading: (view.safeAreaLayoutGuide.leadingAnchor, 0),
                                    trailing: (view.safeAreaLayoutGuide.trailingAnchor, 0))
        
        pickerView.addConstraint(bottom: (containerView.bottomAnchor, 0),
                                 leading: (containerView.leadingAnchor, 0),
                                 trailing: (containerView.trailingAnchor, 0))
        pickerView.setHeightConstraint(with: pickerView.widthAnchor, multiplier: 0.5)
        
        doneButtonStackView.addConstraint(top: (containerView.topAnchor, 4),
                                          bottom: (pickerView.topAnchor, -4),
                                          leading: (containerView.leadingAnchor, 16),
                                          trailing: (containerView.trailingAnchor, -16))
    }
    
    
    // MARK: setupAppearance
    open override func setupAppearance() {
        super.setupAppearance()
        
        view.backgroundColor = .clear
        
        dismissView.backgroundColor = .black.withAlphaComponent(0.5)
        pickerView.backgroundColor = Appearance.shared.colors.white
        containerView.backgroundColor = UIColor(r: 247, g: 247, b: 247)
    }
    
    
    // MARK: setupActions
    open override func setupActions() {
        super.setupActions()
        
        doneButton.addTarget(self, action: #selector(didTapDoneButton), for: .touchUpInside)
        cancelButton.addTarget(self, action: #selector(didTapCancelButton), for: .touchUpInside)
        dismissView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapCancelButton)))
    }
    
    @objc
    open func didTapDoneButton() {
        delegate?.didSelectTime(at: pickerView.date)
        didTapCancelButton()
    }
    
    @objc
    open func didTapCancelButton() {
        dismiss(animated: false)
    }
    
    // MARK: configure
    open func configure(selecteDate: Date?, minimumDate: Date? = nil, delegate: LMFeedTimePickerProtocol?) {
        self.delegate = delegate
        
        pickerView.minimumDate = minimumDate
        pickerView.setDate(selecteDate ?? Date(), animated: true)
    }
}
