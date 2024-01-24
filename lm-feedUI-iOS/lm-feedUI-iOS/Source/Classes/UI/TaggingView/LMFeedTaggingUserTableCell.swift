//
//  LMFeedTaggingUserTableCell.swift
//  lm-feedUI-iOS
//
//  Created by Devansh Mohata on 08/01/24.
//

import Kingfisher
import UIKit

@IBDesignable
open class LMFeedTaggingUserTableCell: LMTableViewCell {
    public struct ViewModel {
        public let userImage: String?
        public let userName: String
        public let route: String
        
        public init(userImage: String?, userName: String, route: String) {
            self.userImage = userImage
            self.userName = userName
            self.route = route
        }
    }
    
    
    // MARK: UI Elements
    open private(set) lazy var userImage: LMImageView = {
        let image = LMImageView().translatesAutoresizingMaskIntoConstraints()
        image.clipsToBounds = true
        return image
    }()
    
    open private(set) lazy var userNameLabel: LMLabel = {
        let label = LMLabel().translatesAutoresizingMaskIntoConstraints()
        return label
    }()
    
    open private(set) lazy var sepratorView: LMView = {
        let view = LMView().translatesAutoresizingMaskIntoConstraints()
        return view
    }()
    
    
    // MARK: setupViews
    open override func setupViews() {
        super.setupViews()
        
        contentView.addSubview(containerView)
        containerView.addSubview(userImage)
        containerView.addSubview(userNameLabel)
        containerView.addSubview(sepratorView)
    }
    
    
    // MARK: setupLayouts
    open override func setupLayouts() {
        super.setupLayouts()
        
        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            userImage.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            userImage.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            userImage.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12),
            userImage.widthAnchor.constraint(equalTo: userImage.heightAnchor),
            
            userNameLabel.centerYAnchor.constraint(equalTo: userImage.centerYAnchor),
            userNameLabel.leadingAnchor.constraint(equalTo: userImage.trailingAnchor, constant: 12),
            userNameLabel.trailingAnchor.constraint(greaterThanOrEqualTo: containerView.trailingAnchor, constant: -12),
            
            sepratorView.leadingAnchor.constraint(equalTo: userNameLabel.leadingAnchor),
            sepratorView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            sepratorView.bottomAnchor.constraint(equalTo: userImage.bottomAnchor),
            sepratorView.heightAnchor.constraint(equalToConstant: 1)
        ])
    }
    
    
    // MARK: setupAppearance
    open override func setupAppearance() {
        super.setupAppearance()
        
        sepratorView.backgroundColor = Appearance.shared.colors.gray4
        userImage.layer.cornerRadius = userImage.bounds.height / 2
        userNameLabel.font = Appearance.shared.fonts.textFont1
        userNameLabel.textColor = Appearance.shared.colors.textColor
        
        backgroundColor = Appearance.shared.colors.clear
        contentView.backgroundColor = Appearance.shared.colors.clear
        containerView.backgroundColor = Appearance.shared.colors.clear
    }
    
    
    // MARK: configure
    open func configure(with data: ViewModel) {
        userNameLabel.text = data.userName
        userImage.kf.setImage(with: URL(string: data.userImage ?? ""), placeholder: LMImageView.generateLetterImage(name: data.userName))
    }
}
