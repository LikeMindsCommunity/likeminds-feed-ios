//
//  LMFeedCreatePollDateView.swift
//  LikeMindsFeedUI
//
//  Created by Devansh Mohata on 07/06/24.
//

import UIKit

public protocol LMFeedCreatePollDateViewProtocol: AnyObject {
    func onDateChanged(newDate: Date)
}

open class LMFeedCreatePollDateView: LMView {
    open private(set) lazy var containerView: LMView = {
        let view = LMView().translatesAutoresizingMaskIntoConstraints()
        return view
    }()
    
    open private(set) lazy var containerStackView: LMStackView = {
        let stack = LMStackView().translatesAutoresizingMaskIntoConstraints()
        stack.axis = .vertical
        stack.alignment = .center
        stack.distribution = .fill
        stack.spacing = 4
        return stack
    }()
    
    open private(set) lazy var wrapperView: LMView = {
        let view = LMView().translatesAutoresizingMaskIntoConstraints()
        view.isUserInteractionEnabled = true
        return view
    }()
    
    open private(set) lazy var titleLabel: LMLabel = {
        let label = LMLabel().translatesAutoresizingMaskIntoConstraints()
        label.text = "Poll expires on"
        label.font = Appearance.shared.fonts.buttonFont2
        label.textColor = Appearance.shared.colors.appTintColor
        return label
    }()
    
    open private(set) lazy var dateLabel: LMLabel = {
        let label = LMLabel().translatesAutoresizingMaskIntoConstraints()
        label.text = "DD-MM-YYYY hh:mm"
        label.font = Appearance.shared.fonts.textFont1
        label.textColor = Appearance.shared.colors.gray155
        return label
    }()
    
    open private(set) lazy var datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.translatesAutoresizingMaskIntoConstraints = false
        picker.datePickerMode = .dateAndTime
        picker.isHidden = true
        if #available(iOS 13.4, *) {
            picker.preferredDatePickerStyle = .wheels
        }
        return picker
    }()
    
    
    // MARK: Data Variables
    public weak var delegate: LMFeedCreatePollDateViewProtocol?
    
    // MARK: setupViews
    open override func setupViews() {
        super.setupViews()
        
        addSubview(containerView)
        
        containerView.addSubview(containerStackView)
        
        containerStackView.addArrangedSubview(wrapperView)
        containerStackView.addArrangedSubview(datePicker)
        
        wrapperView.addSubview(titleLabel)
        wrapperView.addSubview(dateLabel)
    }
    
    
    // MARK: setupLayouts
    open override func setupLayouts() {
        super.setupLayouts()
        
        pinSubView(subView: containerView)
        containerView.pinSubView(subView: containerStackView)
        
        wrapperView.addConstraint(leading: (containerStackView.leadingAnchor, 0),
                                  trailing: (containerStackView.trailingAnchor, 0))
        
        titleLabel.addConstraint(top: (wrapperView.topAnchor, 16),
                                 leading: (wrapperView.leadingAnchor, 16))
        titleLabel.trailingAnchor.constraint(greaterThanOrEqualTo: wrapperView.trailingAnchor, constant: -16).isActive = true
        
        dateLabel.addConstraint(top: (titleLabel.bottomAnchor, 16),
                                bottom: (wrapperView.bottomAnchor, -16),
                                leading: (titleLabel.leadingAnchor, 0))
        dateLabel.trailingAnchor.constraint(greaterThanOrEqualTo: wrapperView.trailingAnchor, constant: -16).isActive = true
    }
    
    
    // MARK: setupAppearance
    open override func setupAppearance() {
        super.setupAppearance()
        
        containerView.backgroundColor = Appearance.shared.colors.white
    }
    
    
    // MARK: setupActions
    open override func setupActions() {
        super.setupActions()
        
        wrapperView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onTapDateView)))
        datePicker.addTarget(self, action: #selector(onDateChanged), for: .valueChanged)
    }
    
    @objc
    open func onTapDateView() {
        datePicker.minimumDate = Date().addingTimeInterval(60 * 5)
        showHidePickerView(isShow: true)
    }
    
    @objc
    open func onDateChanged(sender: UIDatePicker) {
        delegate?.onDateChanged(newDate: sender.date)
    }
    
    
    // MARK: configure
    open func configure(with date: Date, delegate: LMFeedCreatePollDateViewProtocol?) {
        self.delegate = delegate
        updateExpiryDate(with: date)
    }
    
    open func updateExpiryDate(with newDate: Date) {
        dateLabel.text = DateUtility.formatDate(newDate)
        datePicker.setDate(newDate, animated: true)
    }
    
    open func showHidePickerView(isShow: Bool) {
        let duration: TimeInterval = isShow ? 0.3 : 0.1
        
        UIView.animate(withDuration: duration) { [weak self] in
            self?.datePicker.isHidden = !isShow
        }
    }
}
