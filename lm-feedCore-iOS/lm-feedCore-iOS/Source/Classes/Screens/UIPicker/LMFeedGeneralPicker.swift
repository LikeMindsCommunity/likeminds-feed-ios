//
//  LMFeedGeneralPicker.swift
//  LikeMindsFeedCore
//
//  Created by Devansh Mohata on 09/06/24.
//

import LikeMindsFeedUI
import UIKit

public protocol LMFeedGeneralPickerProtocol: AnyObject {
    func didSelectRowAt(index: [Int])
}

open class LMFeedGeneralPicker: LMViewController {
    public struct ContentModel {
        public let components: [[String]]
        public let selectedIndex: [Int]
        
        public init(components: [[String]], selectedIndex: [Int]) {
            self.components = components
            self.selectedIndex = selectedIndex
        }
    }
    
    
    // MARK: UI Elements
    open private(set) lazy var dismissView: LMView = {
        let view = LMView().translatesAutoresizingMaskIntoConstraints()
        return view
    }()
    
    open private(set) lazy var containerView: LMView = {
        let view = LMView().translatesAutoresizingMaskIntoConstraints()
        return view
    }()
    
    open private(set) lazy var pickerView: UIPickerView = {
        let picker = UIPickerView()
        picker.translatesAutoresizingMaskIntoConstraints = false
        picker.dataSource = self
        picker.delegate = self
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
        button.setTitleColor(LMFeedAppearance.shared.colors.appTintColor, for: .normal)
        button.setImage(nil, for: .normal)
        return button
    }()
    
    open private(set) lazy var cancelButton: LMButton = {
        let button = LMButton().translatesAutoresizingMaskIntoConstraints()
        button.setTitle("Cancel", for: .normal)
        button.setTitleColor(LMFeedAppearance.shared.colors.appTintColor, for: .normal)
        button.setImage(nil, for: .normal)
        return button
    }()
    
    open private(set) lazy var spacerView: LMView = {
        let view = LMView().translatesAutoresizingMaskIntoConstraints()
        view.backgroundColor = LMFeedAppearance.shared.colors.clear
        view.setContentHuggingPriority(.defaultLow, for: .horizontal)
        return view
    }()
    
    
    // MARK: Data Variables
    public var data: [[String]] = []
    public var selectedIndex: [Int] = []
    public weak var delegate: LMFeedGeneralPickerProtocol?
    public var bottomConstraint: NSLayoutConstraint?
    
    
    // MARK: viewDidLoad
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        bottomConstraint?.constant = 300
        
        if #available(iOS 13.0, *) {
            // Always adopt a light interface style.
            overrideUserInterfaceStyle = .light
        }
    }
    
    
    // MARK: viewDidAppear
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        UIView.animate(withDuration: 1) { [weak bottomConstraint] in
            bottomConstraint?.constant = .zero
        }
    }
    
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
        
        containerView.addConstraint(leading: (view.safeAreaLayoutGuide.leadingAnchor, 0),
                                    trailing: (view.safeAreaLayoutGuide.trailingAnchor, 0))
        
        bottomConstraint = containerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        bottomConstraint?.isActive = true
        
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
        pickerView.backgroundColor = LMFeedAppearance.shared.colors.white
        containerView.backgroundColor = UIColor(r: 247, g: 247, b: 247)
        
        containerView.layer.cornerRadius = 8
        containerView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
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
        var newSelectedIndex: [Int] = []
        
        let count = selectedIndex.count
        
        for i in 0..<count {
            newSelectedIndex.append(pickerView.selectedRow(inComponent: i))
        }
        
        delegate?.didSelectRowAt(index: newSelectedIndex)
        didTapCancelButton()
    }
    
    @objc
    open func didTapCancelButton() {
        dismiss(animated: false)
    }
    
    // MARK: configure
    open func configure(with data: ContentModel, delegate: LMFeedGeneralPickerProtocol) {
        self.delegate = delegate
        self.data = data.components
        self.selectedIndex = data.selectedIndex
        
        pickerView.reloadAllComponents()
        
        selectedIndex.enumerated().forEach { component, row in
            pickerView.selectRow(row, inComponent: component, animated: true)
        }
    }
}


extension LMFeedGeneralPicker: UIPickerViewDataSource, UIPickerViewDelegate {
    open func numberOfComponents(in pickerView: UIPickerView) -> Int {
        data.count
    }
    
    open func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        data[component].count
    }
    
    open func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        data[component][row]
    }
}
