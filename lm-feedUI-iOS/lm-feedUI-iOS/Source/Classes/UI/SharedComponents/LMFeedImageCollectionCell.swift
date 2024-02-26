//
//  LMFeedPostImageCollectionCell.swift
//  LMFramework
//
//  Created by Devansh Mohata on 01/12/23.
//

import Kingfisher
import UIKit

@IBDesignable
open class LMFeedImageCollectionCell: LMCollectionViewCell {
    public struct ViewModel: LMFeedMediaProtocol {
        public let image: String
        public let isFilePath: Bool
        
        public init(image: String, isFilePath: Bool = false) {
            self.image = image
            self.isFilePath = isFilePath
        }
    }
    
    
    // MARK: UI Elements
    open private(set) lazy var imageView: LMImageView = {
        let image = LMImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.contentMode = .scaleAspectFit
        image.backgroundColor = Appearance.shared.colors.black
        return image
    }()
    
    open private(set) lazy var crossButton: LMButton = {
        let button = LMButton().translatesAutoresizingMaskIntoConstraints()
        button.setTitle(nil, for: .normal)
        button.setImage(Constants.shared.images.xmarkIcon, for: .normal)
        button.backgroundColor = Appearance.shared.colors.white
        button.tintColor = Appearance.shared.colors.gray51
        button.contentMode = .scaleAspectFit
        return button
    }()
    
    
    // MARK: Data Variables
    public var crossButtonHeight: CGFloat = 24
    public var crossButtonAction: ((String) -> Void)?
    public var url: String?
    
    
    // MARK: setupViews
    public override func setupViews() {
        contentView.addSubview(containerView)
        containerView.addSubview(imageView)
        containerView.addSubview(crossButton)
    }
    
    
    // MARK: setupLayouts
    public override func setupLayouts() {
        contentView.pinSubView(subView: containerView)
        containerView.pinSubView(subView: imageView)
        
        crossButton.addConstraint(top: (containerView.topAnchor, 16),
                                  trailing: (containerView.trailingAnchor, -16))
        crossButton.setHeightConstraint(with: crossButtonHeight)
        crossButton.setWidthConstraint(with: crossButton.heightAnchor)
    }
    
    
    // MARK: setupActions
    open override func setupActions() {
        super.setupActions()
        crossButton.addTarget(self, action: #selector(didTapCrossButton), for: .touchUpInside)
    }
    
    @objc
    open func didTapCrossButton() {
        guard let url else { return }
        crossButtonAction?(url)
    }
    
    
    // MARK: setupAppearance
    open override func setupAppearance() {
        super.setupAppearance()
        crossButton.layer.cornerRadius = crossButtonHeight / 2
        crossButton.layer.borderColor = Appearance.shared.colors.gray51.cgColor
        crossButton.layer.borderWidth = 1
    }
    
    
    // MARK: configure
    open func configure(with data: ViewModel, crossButtonAction: ((String) -> Void)? = nil) {
        self.url = data.image
        self.crossButtonAction = crossButtonAction
        crossButton.isHidden = crossButtonAction == nil
        imageView.kf.setImage(with: URL(string: data.image), placeholder: Constants.shared.images.placeholderImage)
    }
}
