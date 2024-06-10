//
//  LMFeedCreatePollMetaOptionWidget.swift
//  LikeMindsFeedUI
//
//  Created by Devansh Mohata on 07/06/24.
//

import UIKit

open class LMFeedCreatePollMetaOptionWidget: LMView {
    public struct ContentModel {
        let id: Int
        let title: String
        let isSelected: Bool
        
        public init(id: Int, title: String, isSelected: Bool) {
            self.id = id
            self.title = title
            self.isSelected = isSelected
        }
    }
    
    
    // MARK: UI Elements
    open private(set) lazy var containerView: LMView = {
        let view = LMView().translatesAutoresizingMaskIntoConstraints()
        return view
    }()
    
    open private(set) lazy var optionTitleLabel: LMLabel = {
        let label = LMLabel().translatesAutoresizingMaskIntoConstraints()
        label.textColor = Appearance.shared.colors.black
        label.font = Appearance.shared.fonts.buttonFont2
        return label
    }()
    
    open private(set) lazy var optionSwitcher: UISwitch = {
        let switcher = UISwitch()
        switcher.translatesAutoresizingMaskIntoConstraints = false
        switcher.tintColor = Appearance.shared.colors.appTintColor
        return switcher
    }()
    
    open private(set) lazy var sepratorView: LMView = {
        let view = LMView().translatesAutoresizingMaskIntoConstraints()
        view.backgroundColor = Appearance.shared.colors.gray155
        return view
    }()
    
    
    // MARK: Data Variables
    public var onValueSwitched: ((Int) -> Void)?
    public var id: Int?
    
    
    // MARK: setupViews
    open override func setupViews() {
        super.setupViews()
        addSubview(containerView)
        containerView.addSubview(optionTitleLabel)
        containerView.addSubview(optionSwitcher)
        containerView.addSubview(sepratorView)
    }
    
    
    // MARK: setupLayouts
    open override func setupLayouts() {
        super.setupLayouts()
        
        pinSubView(subView: containerView)
        
        optionTitleLabel.addConstraint(top: (containerView.topAnchor, 16),
                                    bottom: (containerView.bottomAnchor, -16),
                                    leading: (containerView.leadingAnchor, 16))
        
        optionSwitcher.addConstraint(trailing: (containerView.trailingAnchor, -16),
                                     centerY: (optionTitleLabel.centerYAnchor, 0))
        
        optionSwitcher.leadingAnchor.constraint(greaterThanOrEqualTo: optionTitleLabel.trailingAnchor, constant: 16).isActive = true
        optionSwitcher.topAnchor.constraint(greaterThanOrEqualTo: containerView.topAnchor, constant: 16).isActive = true
        optionSwitcher.bottomAnchor.constraint(greaterThanOrEqualTo: containerView.bottomAnchor, constant: -16).isActive = true
        
        
        sepratorView.addConstraint(bottom: (containerView.bottomAnchor, 0),
                                   leading: (containerView.leadingAnchor, 0),
                                   trailing: (containerView.trailingAnchor, 0))
        sepratorView.setHeightConstraint(with: 1)
    }
    
    
    // MARK: setupActions
    open override func setupActions() {
        super.setupActions()
        optionSwitcher.addTarget(self, action: #selector(onValueChange), for: .valueChanged)
    }
    
    @objc
    open func onValueChange(_ sender: UISwitch) {
        guard let id else { return }
        onValueSwitched?(id)
    }
    
    
    // MARK: configure
    open func configure(with data: ContentModel, onValueSwitched: ((Int) -> Void)?) {
        self.onValueSwitched = onValueSwitched
        self.id = data.id
        
        optionTitleLabel.text = data.title
        optionSwitcher.isOn = data.isSelected
    }
}
