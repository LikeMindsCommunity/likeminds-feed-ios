//
//  LMFeedCreatePollOptionWidget.swift
//  LikeMindsFeedUI
//
//  Created by Devansh Mohata on 07/06/24.
//

import Foundation

open class LMFeedCreatePollOptionWidget: LMTableViewCell {
    public struct ContentModel {
        public let id: Int
        public let option: String?
        
        public init(id: Int, option: String?) {
            self.id = id
            self.option = option
        }
    }
    
    
    // MARK: UI Elements
    open private(set) lazy var optionTextField: LMTextField = {
        let textField = LMTextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.addDoneButtonOnKeyboard()
        textField.attributedPlaceholder = NSAttributedString(
            string: "Option",
            attributes: [NSAttributedString.Key.foregroundColor: Appearance.shared.colors.gray102]
        )
        textField.textColor = Appearance.shared.colors.black
        return textField
    }()
    
    open private(set) lazy var crossButton: LMButton = {
        let button = LMButton().translatesAutoresizingMaskIntoConstraints()
        button.setTitle(nil, for: .normal)
        button.setImage(Constants.shared.images.xmarkIcon, for: .normal)
        button.setPreferredSymbolConfiguration(UIImage.SymbolConfiguration(font: .systemFont(ofSize: 24)), forImageIn: .normal)
        button.tintColor = UIColor(red: 208 / 255, green: 216 / 255, blue: 226 / 255, alpha: 1)
        return button
    }()
    
    open private(set) lazy var sepratorView: LMView = {
        let view = LMView().translatesAutoresizingMaskIntoConstraints()
        view.backgroundColor = UIColor(red: 208 / 255, green: 216 / 255, blue: 226 / 255, alpha: 1)
        return view
    }()
    
    
    // MARK: Data Variables
    public var onCrossButtonCallback: (() -> Void)?
    public var onTextValueChanged: ((String?) -> Void)?
    
    
    // MARK: setupViews
    open override func setupViews() {
        super.setupViews()
        
        contentView.addSubview(containerView)
        containerView.addSubview(optionTextField)
        containerView.addSubview(crossButton)
        containerView.addSubview(sepratorView)
    }
    
    
    // MARK: setupLayouts
    open override func setupLayouts() {
        super.setupLayouts()
        
        contentView.pinSubView(subView: containerView)
        
        optionTextField.addConstraint(top: (containerView.topAnchor, 16),
                                      leading: (containerView.leadingAnchor, 16))
        
        crossButton.addConstraint(leading: (optionTextField.trailingAnchor, 8),
                                  trailing: (containerView.trailingAnchor, -8),
                                  centerY: (optionTextField.centerYAnchor, 0))
        
        sepratorView.addConstraint(top: (optionTextField.bottomAnchor, 16),
                                   bottom: (containerView.bottomAnchor, 0),
                                   leading: (containerView.leadingAnchor, 0),
                                   trailing: (containerView.trailingAnchor, 0))
        sepratorView.setHeightConstraint(with: 1)
        
        crossButton.setWidthConstraint(with: crossButton.heightAnchor)
    }
    
    
    // MARK: setupAppearance
    open override func setupAppearance() {
        super.setupAppearance()
        
        containerView.backgroundColor = Appearance.shared.colors.white
    }
    
    
    // MARK: setupActions
    open override func setupActions() {
        super.setupActions()
        
        crossButton.addTarget(self, action: #selector(onTapCrossButton), for: .touchUpInside)
        optionTextField.addTarget(self, action: #selector(valueChanged), for: .editingChanged)
    }
    
    @objc
    open func onTapCrossButton() {
        onCrossButtonCallback?()
    }
    
    @objc
    open func valueChanged(_ sender: UITextField) {
        onTextValueChanged?(sender.text)
    }
    
    // MARK: configure
    open func configure(with data: ContentModel, isShowCrossIcon: Bool, onCrossButtonCallback: (() -> Void)?, onTextValueChanged: ((String?) -> Void)?) {
        self.onCrossButtonCallback = onCrossButtonCallback
        self.onTextValueChanged = onTextValueChanged
        self.crossButton.isHidden = !isShowCrossIcon
        optionTextField.text = data.option
    }
    
    open func retriveText() -> String? {
        optionTextField.text
    }
}
