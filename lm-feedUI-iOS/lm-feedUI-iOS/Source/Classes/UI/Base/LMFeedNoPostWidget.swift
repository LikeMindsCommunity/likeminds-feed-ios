//
//  LMFeedNoPostWidget.swift
//  lm-feedUI-iOS
//
//  Created by Devansh Mohata on 07/02/24.
//

import UIKit

@IBDesignable
open class LMFeedNoPostWidget: LMView {
    // MARK: UI Elements
    open private(set) lazy var containerView: LMView = {
        let view = LMView().translatesAutoresizingMaskIntoConstraints()
        view.backgroundColor = LMFeedAppearance.shared.colors.clear
        return view
    }()
    
    open private(set) lazy var stackView: LMStackView = {
        let sv = LMStackView().translatesAutoresizingMaskIntoConstraints()
        sv.axis  = .vertical
        sv.alignment = .center
        sv.distribution = .fill
        sv.spacing = 8
        return sv
    }()
    
    open private(set) lazy var emptyImageView: LMImageView = {
        let imageView = LMImageView().translatesAutoresizingMaskIntoConstraints()
        imageView.clipsToBounds = true
        imageView.image = LMFeedConstants.shared.images.docImageIcon
        imageView.tintColor = LMFeedAppearance.shared.colors.gray102
        imageView.preferredSymbolConfiguration = .init(pointSize: 40, weight: .light, scale: .medium)
        return imageView
    }()
    
    open private(set) lazy var emptyTitleLabel: LMLabel = {
        let label = LMLabel().translatesAutoresizingMaskIntoConstraints()
        label.textColor = LMFeedAppearance.shared.colors.gray1
        label.font = LMFeedAppearance.shared.fonts.buttonFont1
        label.text = ""
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    open private(set) lazy var emptySubtitleLabel: UILabel = {
        let label = LMLabel().translatesAutoresizingMaskIntoConstraints()
        label.textColor = LMFeedAppearance.shared.colors.gray2
        label.font = LMFeedAppearance.shared.fonts.buttonFont1
        label.text = ""
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    open private(set) lazy var createPostButton: LMButton = {
        let button = LMButton.createButton(
            with: "",
            image: LMFeedConstants.shared.images.createPostIcon,
            textColor: LMFeedAppearance.shared.colors.white,
            textFont: LMFeedAppearance.shared.fonts.buttonFont1,
            contentSpacing: .init(top: 8, left: 16, bottom: 8, right: 16),
            imageSpacing: 8
        )
        button.tintColor = LMFeedAppearance.shared.colors.white
        button.backgroundColor = LMFeedAppearance.shared.colors.appTintColor
        return button
    }()
    
    
    public var createAction: (() -> Void)?
    
    
    // MARK: setupViews
    open override func setupViews() {
        super.setupViews()
        addSubview(containerView)
        containerView.addSubview(stackView)
        
        stackView.addArrangedSubview(emptyImageView)
        stackView.addArrangedSubview(emptyTitleLabel)
        stackView.addArrangedSubview(emptySubtitleLabel)
        stackView.addArrangedSubview(createPostButton)
    }
    
    
    // MARK: setupLayouts
    open override func setupLayouts() {
        super.setupLayouts()
        
        pinSubView(subView: containerView)
        
        stackView.addConstraint(leading: (containerView.leadingAnchor, 16),
                                trailing: (containerView.trailingAnchor, -16),
                                centerY: (containerView.centerYAnchor, -60)
        )
        
        emptyImageView.setHeightConstraint(with: 40)
        emptyImageView.setWidthConstraint(with: emptyImageView.heightAnchor)
    }
    
    
    
    // MARK: setupActions
    open override func setupActions() {
        super.setupActions()
        createPostButton.addTarget(self, action: #selector(didTapCreateButton), for: .touchUpInside)
    }
    
    @objc
    open func didTapCreateButton() {
        createAction?()
    }
    
    // MARK: setupAppearance
    open override func setupAppearance() {
        super.setupAppearance()
        createPostButton.roundCorners(with: 8)
    }
    
    
    // MARK: configure
    open func configure(title: String, _ createAction: (() -> Void)?) {
        createPostButton.setTitle("New \(title)", for: .normal)
        emptyTitleLabel.text = "No \(title.pluralize().lowercased()) to show"
        emptySubtitleLabel.text = "Be the first one to \(title.lowercased()) here"
        
        self.createAction = createAction
    }
}
