//
//  LMFeedPollAddOptionScreen.swift
//  LikeMindsFeedCore
//
//  Created by Devansh Mohata on 18/06/24.
//

import LikeMindsFeedUI
import UIKit

public protocol LMFeedAddOptionProtocol: AnyObject {
    func onAddOptionResponse(postID: String, success: Bool, errorMessage: String?)
}

open class LMFeedPollAddOptionScreen: LMViewController {
    // MARK: UI Elements
    open private(set) lazy var dismissView: LMView = {
        let view = LMView().translatesAutoresizingMaskIntoConstraints()
        view.backgroundColor = Appearance.shared.colors.black.withAlphaComponent(0.5)
        return view
    }()
    
    open private(set) lazy var containerView: LMView = {
        let view = LMView().translatesAutoresizingMaskIntoConstraints()
        view.backgroundColor = Appearance.shared.colors.white
        return view
    }()
    
    open private(set) lazy var sepratorView: LMView = {
        let view = LMView().translatesAutoresizingMaskIntoConstraints()
        view.backgroundColor = Appearance.shared.colors.sepratorColor
        return view
    }()
    
    open private(set) lazy var titleLabel: LMLabel = {
        let label = LMLabel().translatesAutoresizingMaskIntoConstraints()
        label.font = Appearance.shared.fonts.headingFont1
        label.text = "Add new poll option"
        label.textColor = Appearance.shared.colors.gray51
        return label
    }()
    
    open private(set) lazy var subtitleLabel: LMLabel = {
        let label = LMLabel().translatesAutoresizingMaskIntoConstraints()
        label.font = Appearance.shared.fonts.subHeadingFont2
        label.text = "Enter an option that you think is missing in this poll. This can not be undone."
        label.textColor = Appearance.shared.colors.gray51
        label.numberOfLines = 0
        return label
    }()
    
    open private(set) lazy var optionTextContainer: LMView = {
        let view = LMView().translatesAutoresizingMaskIntoConstraints()
        view.backgroundColor = Appearance.shared.colors.clear
        return view
    }()
    
    open private(set) lazy var optionTextField: LMTextField = {
        let text = LMTextField()
        text.translatesAutoresizingMaskIntoConstraints = false
        text.placeholder = "Type new option"
        text.textColor = Appearance.shared.colors.gray51
        return text
    }()
    
    open private(set) lazy var submitButton: LMLoadingButton = {
        let button = LMLoadingButton().translatesAutoresizingMaskIntoConstraints()
        button.setTitle(Constants.shared.strings.submit.uppercased(), for: .normal)
        button.setImage(nil, for: .normal)
        button.setTitleColor(.white, for: .normal)
        return button
    }()
    
    
    // MARK: Data Variables
    public var bottomConstraint: NSLayoutConstraint?
    open var submitButtonHeight: CGFloat { 44 }
    public var allowBackGesture: Bool = true
    public var viewmodel: LMFeedPollAddOptionViewModel?
    public var delegate: LMFeedAddOptionProtocol?
    
    
    // MARK: setupViews
    open override func setupViews() {
        super.setupViews()
        
        view.addSubview(dismissView)
        view.addSubview(containerView)
        
        containerView.addSubview(sepratorView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(subtitleLabel)
        containerView.addSubview(optionTextContainer)
        optionTextContainer.addSubview(optionTextField)
        containerView.addSubview(submitButton)
    }
    
    
    // MARK: setupLayouts
    open override func setupLayouts() {
        super.setupLayouts()
        
        view.pinSubView(subView: dismissView)
        
        containerView.addConstraint(leading: (view.leadingAnchor, 0),
                                    trailing: (view.trailingAnchor, 0))
        bottomConstraint = containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        bottomConstraint?.isActive = true
        
        sepratorView.addConstraint(top: (containerView.topAnchor, 16),
                                   centerX: (containerView.centerXAnchor, 0))
        sepratorView.setWidthConstraint(with: containerView.widthAnchor, multiplier: 0.3)
        sepratorView.setHeightConstraint(with: 8)
        
        titleLabel.addConstraint(top: (sepratorView.bottomAnchor, 16),
                                 leading: (containerView.leadingAnchor, 16))
        titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: containerView.trailingAnchor, constant: -16).isActive = true
        
        subtitleLabel.addConstraint(top: (titleLabel.bottomAnchor, 4),
                                    leading: (titleLabel.leadingAnchor, 0))
        subtitleLabel.trailingAnchor.constraint(lessThanOrEqualTo: containerView.trailingAnchor, constant: -16).isActive = true
        
        optionTextContainer.addConstraint(top: (subtitleLabel.bottomAnchor, 20),
                                      leading: (containerView.leadingAnchor, 16),
                                      trailing: (containerView.trailingAnchor, -16))
        optionTextContainer.setHeightConstraint(with: 48)
        
        optionTextContainer.pinSubView(subView: optionTextField, padding: .init(top: 4, left: 8, bottom: -4, right: -8))
        
        submitButton.addConstraint(top: (optionTextField.bottomAnchor, 24),
                                   bottom: (containerView.bottomAnchor, -24),
                                   centerX: (containerView.centerXAnchor, 0))
        
        submitButton.setWidthConstraint(with: containerView.widthAnchor, multiplier: 0.5)
        submitButton.setHeightConstraint(with: submitButtonHeight)
    }
    
    
    // MARK: setupAppearance
    open override func setupAppearance() {
        super.setupAppearance()
        
        containerView.layer.cornerRadius = 8
        containerView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        sepratorView.layer.cornerRadius = sepratorView.frame.height / 2
        submitButton.layer.cornerRadius = submitButtonHeight / 2
        
        optionTextContainer.layer.cornerRadius = optionTextField.frame.height / 4
        optionTextContainer.layer.borderWidth = 1
        optionTextContainer.layer.borderColor = Appearance.shared.colors.gray4.cgColor
        optionTextField.addDoneButtonOnKeyboard()
    }
    
    
    // MARK: setupActions
    open override func setupActions() {
        super.setupActions()
        
        dismissView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapDismissView)))
        submitButton.addTarget(self, action: #selector(submitButtonTapped), for: .touchUpInside)
        optionTextField.addTarget(self, action: #selector(editingChanged), for: .editingChanged)
    }
    
    
    @objc
    open func didTapDismissView() {
        guard allowBackGesture else { return }
        dismiss(animated: false)
    }
    
    @objc
    open func submitButtonTapped() {
        view.endEditing(true)
        viewmodel?.onSubmitClick(with: optionTextField.text)
    }
    
    @objc
    open func editingChanged(_ sender: UITextField) {
        viewmodel?.checkValidOption(with: sender.text)
    }
    
    
    // MARK: setupObservers
    open override func setupObservers() {
        super.setupObservers()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc
    open func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if bottomConstraint?.constant == .zero {
                UIView.animate(withDuration: 0.3) { [weak bottomConstraint] in
                    bottomConstraint?.constant -= keyboardSize.height
                }
            }
        }
    }
    
    @objc
    open func keyboardWillHide(notification: NSNotification) {
        UIView.animate(withDuration: 0.3) { [weak bottomConstraint] in
            bottomConstraint?.constant = .zero
        }
    }
    
    
    // MARK: viewDidLoad
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        bottomConstraint?.constant = -containerView.frame.height
        setSubmitButton(isEnabled: false)
    }
    
    
    // MARK: viewDidAppear
    open override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        UIView.animate(withDuration: 1) { [weak bottomConstraint] in
            bottomConstraint?.constant = .zero
        }
    }
}


// MARK: LMFeedPollAddOptionViewModelProtocol
extension LMFeedPollAddOptionScreen: LMFeedPollAddOptionViewModelProtocol {
    public func setSubmitButton(isEnabled: Bool) {
        submitButton.isEnabled = isEnabled
        submitButton.backgroundColor = isEnabled ? Appearance.shared.colors.appTintColor : Appearance.shared.colors.backgroundColor
    }
    
    public func showButtonLoader() {
        submitButton.isEnabled = false
        submitButton.showLoading()
        allowBackGesture = false
    }
    
    public func onAddOptionResponse(postID: String, success: Bool, errorMessage: String?) {
        delegate?.onAddOptionResponse(postID: postID, success: success, errorMessage: errorMessage)
        dismiss(animated: false)
    }
}
