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
    open private(set) lazy var imageView: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.contentMode = .scaleAspectFill
        return image
    }()
    
    open private(set) lazy var crossButton: LMButton = {
        let button = LMButton().translatesAutoresizingMaskIntoConstraints()
        button.setTitle(nil, for: .normal)
        button.setImage(Constants.shared.images.crossIcon, for: .normal)
        button.tintColor = Appearance.shared.colors.gray51
        button.backgroundColor = Appearance.shared.colors.white
        return button
    }()
    
    
    // MARK: Data Variables
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
        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            imageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            imageView.topAnchor.constraint(equalTo: containerView.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            
            crossButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            crossButton.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            crossButton.heightAnchor.constraint(equalToConstant: 24),
            crossButton.widthAnchor.constraint(equalTo: crossButton.heightAnchor)
        ])
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
        crossButton.layer.cornerRadius = crossButton.frame.height / 2
    }
    
    
    // MARK: configure
    open func configure(with data: ViewModel, crossButtonAction: ((String) -> Void)? = nil) {
        self.url = data.image
        self.crossButtonAction = crossButtonAction
        crossButton.isHidden = crossButtonAction == nil
        
        if data.isFilePath {
            let url = URL(fileURLWithPath: data.image)
            let provider = LocalFileImageDataProvider(fileURL: url)
            imageView.kf.setImage(with: provider) { [weak self] result in
                switch result {
                case .success(_):
                    break
                case .failure(_):
                    self?.imageView.image = Constants.shared.images.placeholderImage
                }
            }
        } else {
            imageView.kf.setImage(with: URL(string: data.image)) { [weak self] result in
                switch result {
                case .success(_):
                    break
                case .failure(_):
                    self?.imageView.image = Constants.shared.images.placeholderImage
                }
            }
        }
    }
}
