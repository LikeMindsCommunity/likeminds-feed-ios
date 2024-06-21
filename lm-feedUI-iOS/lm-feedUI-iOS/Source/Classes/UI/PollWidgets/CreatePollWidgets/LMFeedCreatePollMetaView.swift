//
//  LMFeedCreatePollMetaView.swift
//  LikeMindsFeedUI
//
//  Created by Devansh Mohata on 07/06/24.
//

import UIKit

public protocol LMFeedCreatePollMetaViewProtocol: AnyObject {
    func onTapUserMetaOptions()
    func onValueChanged(for id: Int)
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

    
    // MARK: LMFeedCreatePollMetaViewProtocol
    public weak var delegate: LMFeedCreatePollMetaViewProtocol?
    public var userOptions: [[String]] = []
    
    
    // MARK: setupViews
    open override func setupViews() {
        super.setupViews()
        
        addSubview(containerView)
        containerView.addSubview(metaOptionStackView)
        containerView.addSubview(optionContainerView)
        
        optionContainerView.addSubview(titleLabel)
        optionContainerView.addSubview(optionTypeButton)
        optionContainerView.addSubview(maxOptionButton)
        optionContainerView.addSubview(equalSymbol)
    }
    
    
    // MARK: setupLayouts
    open override func setupLayouts() {
        super.setupLayouts()
        
        pinSubView(subView: containerView)
        
        metaOptionStackView.addConstraint(top: (containerView.topAnchor, 0),
                                          leading: (containerView.leadingAnchor, 0),
                                          trailing: (containerView.trailingAnchor, 0))
        
        optionContainerView.addConstraint(top: (metaOptionStackView.bottomAnchor, 0),
                                          bottom: (containerView.bottomAnchor, 0),
                                          leading: (containerView.leadingAnchor, 0),
                                          trailing: (containerView.trailingAnchor, 0))
        
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
    }
    
    
    // MARK: setupAppearance
    open override func setupAppearance() {
        super.setupAppearance()
        containerView.backgroundColor = Appearance.shared.colors.white
        equalSymbol.tintColor = Appearance.shared.colors.gray155
    }
    
    
    // MARK: setupActions
    open override func setupActions() {
        optionTypeButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onTapUserMetaOptions)))
        maxOptionButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onTapUserMetaOptions)))
    }
    
    @objc
    open func onTapUserMetaOptions() {
        delegate?.onTapUserMetaOptions()
    }

    
    // MARK: configure
    open func configure(with data: ContentModel, delegate: LMFeedCreatePollMetaViewProtocol?) {
        self.delegate = delegate
        
        data.metaOptions.forEach { option in
            let view = LMFeedCreatePollMetaOptionWidget().translatesAutoresizingMaskIntoConstraints()
            view.configure(with: option) { [weak delegate] id in
                delegate?.onValueChanged(for: id)
            }
            metaOptionStackView.addArrangedSubview(view)
        }
        
        updateUserMetaOption(option: data.optionState, count: data.optionCount)
    }
    
    open func updateUserMetaOption(option: String, count: Int) {
        optionTypeButton.configure(with: option)
        maxOptionButton.configure(with: optionCountFormatted(count))
    }
    
    open func optionCountFormatted(_ count: Int) -> String {
        return "\(count) option\(count == 1 ? "" : "s")"
    }
}
