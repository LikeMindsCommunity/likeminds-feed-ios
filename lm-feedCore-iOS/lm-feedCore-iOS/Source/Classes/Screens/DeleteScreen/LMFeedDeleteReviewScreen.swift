//
//  LMFeedDeleteReviewScreen.swift
//  lm-feedCore-iOS
//
//  Created by Devansh Mohata on 30/01/24.
//

import lm_feedUI_iOS
import UIKit

public protocol LMFeedDeleteProtocol: AnyObject {
    func initateDeleteAction(with reason: String)
}

public protocol LMFeedDeleteReviewViewModelProtocol: LMBaseViewControllerProtocol {
    func showTags(with tags: [String], title: String, subtitle: String)
    func setNewReason(with title: String, isShowTextField: Bool)
}


@IBDesignable
open class LMFeedDeleteReviewScreen: LMViewController {
    // MARK: UI Elements
    open private(set) lazy var contentView: LMView = {
        let view = LMView().translatesAutoresizingMaskIntoConstraints()
        view.backgroundColor = Appearance.shared.colors.black.withAlphaComponent(0.5)
        return view
    }()
    
    open private(set) lazy var containerView: LMView = {
        let view = LMView().translatesAutoresizingMaskIntoConstraints()
        view.backgroundColor = Appearance.shared.colors.white
        return view
    }()
    
    open private(set) lazy var titleLabel: LMLabel = {
        let label = LMLabel().translatesAutoresizingMaskIntoConstraints()
        label.textColor = Appearance.shared.colors.gray51
        label.font = Appearance.shared.fonts.headingFont1
        label.text = "Delete Post"
        return label
    }()
    
    open private(set) lazy var subtitleLabel: LMLabel = {
        let label = LMLabel().translatesAutoresizingMaskIntoConstraints()
        label.textColor = Appearance.shared.colors.gray102
        label.font = Appearance.shared.fonts.headingFont1
        label.numberOfLines = 0
        label.text = "Delete Post"
        return label
    }()
    
    open private(set) lazy var reasonStackView: LMStackView = {
        let stack = LMStackView().translatesAutoresizingMaskIntoConstraints()
        stack.axis = .vertical
        stack.alignment = .fill
        stack.distribution = .fill
        stack.spacing = 8
        return stack
    }()
    
    open private(set) lazy var reasonContainerView: LMView = {
        let view = LMView().translatesAutoresizingMaskIntoConstraints()
        view.backgroundColor = Appearance.shared.colors.clear
        view.clipsToBounds = true
        return view
    }()
    
    open private(set) lazy var reasonTitleLabel: LMLabel = {
        let label = LMLabel().translatesAutoresizingMaskIntoConstraints()
        label.text = "Reason for deletion"
        label.font = Appearance.shared.fonts.textFont1
        label.textColor = Appearance.shared.colors.gray155
        return label
    }()
    
    open private(set) lazy var downArrowImage: LMImageView = {
        let image = LMImageView().translatesAutoresizingMaskIntoConstraints()
        image.image = Constants.shared.images.downArrowFilled
        image.tintColor = Appearance.shared.colors.gray1
        return image
    }()
    
    open private(set) lazy var pickerView: UIPickerView = {
        let picker = UIPickerView()
        picker.translatesAutoresizingMaskIntoConstraints = false
        return picker
    }()
    
    open private(set) lazy var otherReasonTextView: LMTextView = {
        let text = LMTextView().translatesAutoresizingMaskIntoConstraints()
        text.clipsToBounds = true
        return text
    }()
    
    open private(set) lazy var sepratorView: LMView = {
        let view = LMView().translatesAutoresizingMaskIntoConstraints()
        view.backgroundColor = Appearance.shared.colors.gray1
        return view
    }()
    
    open private(set) lazy var buttonContainerStack: LMStackView = {
        let stack = LMStackView().translatesAutoresizingMaskIntoConstraints()
        stack.axis = .horizontal
        stack.alignment = .fill
        stack.distribution = .fillEqually
        stack.spacing = 2
        stack.backgroundColor = Appearance.shared.colors.gray1
        return stack
    }()
    
    open private(set) lazy var cancelButton: LMButton = {
        let button = LMButton.createButton(with: "Cancel", image: nil, textColor: Appearance.shared.colors.blueGray, textFont: Appearance.shared.fonts.buttonFont1)
        button.backgroundColor = Appearance.shared.colors.white
        button.translatesAutoresizingMaskIntoConstraints = false
        button.clipsToBounds = true
        return button
    }()
    
    open private(set) lazy var deleteButton: LMButton = {
        let button = LMButton.createButton(with: "Delete", image: nil, textColor: Appearance.shared.colors.red, textFont: Appearance.shared.fonts.buttonFont1)
        button.backgroundColor = Appearance.shared.colors.white
        button.translatesAutoresizingMaskIntoConstraints = false
        button.clipsToBounds = true
        return button
    }()
    
    
    // MARK: Data Variables
    public var tags: [String] = []
    public var viewmodel: LMFeedDeleteReviewViewModel?
    
    
    // MARK: setupViews
    open override func setupViews() {
        super.setupViews()
        
        view.addSubview(contentView)
        contentView.addSubview(containerView)
        
        containerView.addSubview(titleLabel)
        containerView.addSubview(subtitleLabel)
        containerView.addSubview(reasonStackView)
        containerView.addSubview(sepratorView)
        containerView.addSubview(buttonContainerStack)
        
        reasonStackView.addArrangedSubview(reasonContainerView)
        reasonStackView.addArrangedSubview(otherReasonTextView)
        
        reasonContainerView.addSubview(reasonTitleLabel)
        reasonContainerView.addSubview(downArrowImage)
        reasonContainerView.addSubview(pickerView)
        
        buttonContainerStack.addArrangedSubview(cancelButton)
        buttonContainerStack.addArrangedSubview(deleteButton)
    }
    
    
    // MARK: setupLayouts
    open override func setupLayouts() {
        super.setupLayouts()
        
        view.pinSubView(subView: contentView)
        containerView.addConstraint(leading: (contentView.leadingAnchor, 36),
                                    trailing: (contentView.trailingAnchor, -36),
                                    centerY: (contentView.centerYAnchor, 0))
        
        titleLabel.addConstraint(top: (containerView.topAnchor, 16),
                                 leading: (containerView.leadingAnchor, 16),
                                 trailing: (containerView.trailingAnchor, -16))
        
        subtitleLabel.addConstraint(top: (titleLabel.bottomAnchor, 16),
                                    leading: (titleLabel.leadingAnchor, 0),
                                    trailing: (titleLabel.trailingAnchor, 0))
        
        reasonStackView.addConstraint(top: (subtitleLabel.bottomAnchor, 16),
                                      leading: (subtitleLabel.leadingAnchor, 0),
                                      trailing: (subtitleLabel.trailingAnchor, 0))
        
        reasonTitleLabel.addConstraint(top: (reasonContainerView.topAnchor, 16),
                                       leading: (reasonContainerView.leadingAnchor, 16))
        
        downArrowImage.addConstraint(trailing: (reasonContainerView.trailingAnchor, -16),
                                     centerY: (reasonTitleLabel.centerYAnchor, 0))
        
        downArrowImage.leadingAnchor.constraint(greaterThanOrEqualTo: reasonTitleLabel.trailingAnchor, constant: -16).isActive = true
        
        pickerView.addConstraint(top: (reasonTitleLabel.bottomAnchor, 16),
                                 bottom: (reasonContainerView.bottomAnchor, 0),
                                 leading: (reasonTitleLabel.leadingAnchor, 0),
                                 trailing: (downArrowImage.trailingAnchor, 0))
        
        pickerView.heightAnchor.constraint(equalTo: pickerView.widthAnchor, multiplier: 0.5).isActive = true
        
        otherReasonTextView.setHeightConstraint(with: 50)
        
        sepratorView.addConstraint(top: (reasonStackView.bottomAnchor, 16),
                                   leading: (containerView.leadingAnchor, 0),
                                   trailing: (containerView.trailingAnchor, 0))
        
        sepratorView.setHeightConstraint(with: 1)
        
        buttonContainerStack.addConstraint(top: (sepratorView.bottomAnchor, 0),
                                           bottom: (containerView.bottomAnchor, 0),
                                           leading: (containerView.leadingAnchor, 0),
                                           trailing: (containerView.trailingAnchor, 0))
        
        buttonContainerStack.setHeightConstraint(with: 50)
    }
    
    
    // MARK: setupObservers
    open override func setupObservers() {
        super.setupObservers()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(sender:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(sender:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc 
    open func keyboardWillShow(sender: NSNotification) {
        self.view.frame.origin.y = -100
    }

    @objc 
    open func keyboardWillHide(sender: NSNotification) {
        self.view.frame.origin.y = 0
    }
    
    
    open override func setupActions() {
        super.setupActions()
        pickerView.dataSource = self
        pickerView.delegate = self
        cancelButton.addTarget(self, action: #selector(didTapCancelButton), for: .touchUpInside)
    }
    
    @objc
    open func didTapCancelButton() {
        dismiss(animated: true)
    }
    
    @objc
    open func didTapDeleteButton() {
        
    }
    
    // MARK: setupAppearance
    open override func setupAppearance() {
        super.setupAppearance()
        view.backgroundColor = Appearance.shared.colors.clear
        
        containerView.clipsToBounds = true
        containerView.layer.cornerRadius = 8
        
        reasonContainerView.clipsToBounds = true
        reasonContainerView.layer.cornerRadius = 8
        reasonContainerView.layer.borderWidth = 1
        reasonContainerView.layer.borderColor = Appearance.shared.colors.black.cgColor
        
        otherReasonTextView.layer.cornerRadius = 8
        otherReasonTextView.layer.borderWidth = 1
        otherReasonTextView.layer.borderColor = Appearance.shared.colors.black.cgColor
        
        otherReasonTextView.addDoneButtonOnKeyboard()
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        otherReasonTextView.isHidden = true
        containerView.isHidden = true
        viewmodel?.fetchReportTags(type: 0)
    }
    
    public override func showError(with message: String, isPopVC: Bool) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        
        let action = UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            if isPopVC {
                self?.dismiss(animated: false)
            }
        }
        
        alert.addAction(action)
        presentAlert(with: alert)
    }
}


// MARK: LMFeedDeleteReviewViewModelProtocol
extension LMFeedDeleteReviewScreen: LMFeedDeleteReviewViewModelProtocol {
    public func showTags(with tags: [String], title: String, subtitle: String) {
        titleLabel.text = title
        subtitleLabel.text = subtitle
        
        self.tags = tags
        containerView.isHidden = false
        pickerView.reloadAllComponents()
        pickerView.selectRow(0, inComponent: 0, animated: true)
        
        if tags.indices.contains(0) {
            setNewReason(with: tags[0], isShowTextField: tags[0].lowercased() == "others")
        }
    }
    
    public func setNewReason(with title: String, isShowTextField: Bool) {
        reasonTitleLabel.text = title
        reasonTitleLabel.textColor = Appearance.shared.colors.gray51
        
        otherReasonTextView.isHidden = !isShowTextField
        
        if isShowTextField {
            otherReasonTextView.becomeFirstResponder()
        } else {
            otherReasonTextView.resignFirstResponder()
        }
    }
}


// MARK: UIPickerView
extension LMFeedDeleteReviewScreen: UIPickerViewDataSource, UIPickerViewDelegate {
    open func numberOfComponents(in pickerView: UIPickerView) -> Int { 1 }
    
    open func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int { tags.count }
    
    open func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        NSAttributedString(string: tags[row], attributes: [.font: Appearance.shared.fonts.buttonFont1,
                                                           .foregroundColor: Appearance.shared.colors.gray51])
    }
    
    open func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        viewmodel?.updateSelectedReason(with: tags[row])
    }
}


// MARK: UITextViewDelegate
extension LMFeedDeleteReviewScreen: UITextViewDelegate {
    open func textViewDidBeginEditing(_ textView: UITextView) {
        
    }
    
    open func textViewDidEndEditing(_ textView: UITextView) {
        
    }
}
