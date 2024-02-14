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
        view.backgroundColor = Appearance.shared.colors.clear
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
        imageView.image = Constants.shared.images.docImageIcon
        imageView.tintColor = Appearance.shared.colors.gray102
        imageView.preferredSymbolConfiguration = .init(pointSize: 40, weight: .light, scale: .medium)
        return imageView
    }()
    
    open private(set) lazy var emptyTitleLabel: LMLabel = {
        let label = LMLabel().translatesAutoresizingMaskIntoConstraints()
        label.textColor = Appearance.shared.colors.gray1
        label.font = Appearance.shared.fonts.buttonFont1
        label.text = "No post to show"
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    open private(set) lazy var emptySubtitleLabel: UILabel = {
        let label = LMLabel().translatesAutoresizingMaskIntoConstraints()
        label.textColor = Appearance.shared.colors.gray2
        label.font = Appearance.shared.fonts.buttonFont1
        label.text = "Be the first on to post here"
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    open private(set) lazy var createPostButton: LMButton = {
        let button = LMButton.createButton(
            with: "New Post",
            image: Constants.shared.images.createPostIcon,
            textColor: Appearance.shared.colors.white,
            textFont: Appearance.shared.fonts.buttonFont1,
            contentSpacing: .init(top: 8, left: 16, bottom: 8, right: 16),
            imageSpacing: 8
        )
        button.tintColor = Appearance.shared.colors.white
        button.backgroundColor = Appearance.shared.colors.appTintColor
        return button
    }()
    
    
    open override func setupViews() {
        super.setupViews()
        addSubview(containerView)
        containerView.addSubview(stackView)
        
        stackView.addArrangedSubview(emptyImageView)
        stackView.addArrangedSubview(emptyTitleLabel)
        stackView.addArrangedSubview(emptySubtitleLabel)
        stackView.addArrangedSubview(createPostButton)
    }
    
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
    
    open override func setupAppearance() {
        super.setupAppearance()
        createPostButton.roundCorners(with: 8)
    }
}
