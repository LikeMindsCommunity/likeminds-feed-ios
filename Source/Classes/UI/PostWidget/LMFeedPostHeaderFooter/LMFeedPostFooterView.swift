//
//  LMFeedPostFooterView.swift
//  LMFramework
//
//  Created by Devansh Mohata on 28/11/23.
//

import UIKit

public protocol LMFeedPostFooterViewProtocol: AnyObject {
    func didTapLikeButton()
    func didTapLikeTextButton()
    func didTapCommentButton()
    func didTapShareButton()
    func didTapSaveButton()
}

@IBDesignable
open class LMFeedPostFooterView: LMView {
    public struct ViewModel {
        var isSaved: Bool
        var isLiked: Bool
        
        public init(isSaved: Bool = false, isLiked: Bool = false) {
            self.isSaved = isSaved
            self.isLiked = isLiked
        }
    }
    
    
    // MARK: UI Elements
    open private(set) lazy var stackView: LMStackView = {
        let stack = LMStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.spacing = 0
        stack.alignment = .center
        stack.distribution = .fill
        return stack
    }()
    
    open private(set) lazy var likeButton: LMButton = {
        if #available(iOS 15.0, *) {
            var btnConfig = UIButton.Configuration.plain()
            btnConfig.contentInsets = .init(top: 0, leading: 0, bottom: 0, trailing: 4)
            btnConfig.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(font: Appearance.shared.fonts.buttonFont)
            btnConfig.image = Constants.Images.shared.heart
            
            let button = LMButton(configuration: btnConfig)
            button.translatesAutoresizingMaskIntoConstraints = false
            button.setContentHuggingPriority(.defaultLow, for: .horizontal)
            button.tintColor = Appearance.shared.colors.gray2
            return button
        } else {
            let button = LMButton()
            button.translatesAutoresizingMaskIntoConstraints = false
            button.setContentHuggingPriority(.defaultLow, for: .horizontal)
            button.contentEdgeInsets = .init(top: 0, left: 0, bottom: 0, right: 4)
            button.setImage(Constants.Images.shared.heart, for: .normal)
            button.tintColor = Appearance.shared.colors.gray2
            return button
        }
    }()
    
    open private(set) lazy var likeTextButton: LMButton = {
        if #available(iOS 15.0, *) {
            var btnConfig = UIButton.Configuration.plain()
            btnConfig.contentInsets = .zero
            btnConfig.titleAlignment = .center
            
            var titleAttributes = AttributeContainer()
            titleAttributes.font = Appearance.shared.fonts.buttonFont
            titleAttributes.foregroundColor = Appearance.shared.colors.gray2
            btnConfig.attributedTitle = AttributedString(Constants.shared.strings.like, attributes: titleAttributes)
            
            btnConfig.titlePadding = .zero
            
            let button = LMButton(configuration: btnConfig)
            button.translatesAutoresizingMaskIntoConstraints = false
            button.tintColor = Appearance.shared.colors.gray2
            button.setContentHuggingPriority(.defaultLow, for: .horizontal)
            return button
        } else {
            let button = LMButton()
            button.translatesAutoresizingMaskIntoConstraints = false
            button.setContentHuggingPriority(.defaultLow, for: .horizontal)
            button.setTitle(Constants.shared.strings.like, for: .normal)
            button.setTitleColor(Appearance.shared.colors.gray2, for: .normal)
            button.titleLabel?.font = Appearance.shared.fonts.buttonFont
            button.tintColor = Appearance.shared.colors.gray2
            return button
        }
    }()
    
    open private(set) lazy var commentButton: LMButton = {
        if #available(iOS 15.0, *) {
            var btnConfig = UIButton.Configuration.plain()
            btnConfig.contentInsets = .init(top: 0, leading: 8, bottom: 0, trailing: 0)
            
            var titleAttributes = AttributeContainer()
            titleAttributes.font = Appearance.shared.fonts.buttonFont
            titleAttributes.foregroundColor = Appearance.shared.colors.gray2
            btnConfig.attributedTitle = AttributedString(Constants.shared.strings.comment, attributes: titleAttributes)
            
            btnConfig.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(font: Appearance.shared.fonts.buttonFont)
            btnConfig.image = Constants.Images.shared.commentIcon
            btnConfig.imagePadding = 4
            
            let button = LMButton(configuration: btnConfig)
            button.translatesAutoresizingMaskIntoConstraints = false
            button.tintColor = Appearance.shared.colors.gray2
            button.setTitleColor(Appearance.shared.colors.gray2, for: .normal)
            button.setContentHuggingPriority(.defaultLow, for: .horizontal)
            return button
        } else {
            let button = LMButton()
            button.translatesAutoresizingMaskIntoConstraints = false
            button.setContentHuggingPriority(.defaultLow, for: .horizontal)
            button.setTitle(Constants.shared.strings.comment, for: .normal)
            button.setTitleColor(Appearance.shared.colors.gray2, for: .normal)
            button.titleLabel?.font = Appearance.shared.fonts.buttonFont
            button.imageEdgeInsets = .init(top: 0, left: 0, bottom: 0, right: 4)
            button.setImage(Constants.Images.shared.commentIcon, for: .normal)
            button.tintColor = Appearance.shared.colors.gray2
            return button
        }
    }()
    
    open private(set) lazy var saveButton: LMButton = {
        if #available(iOS 15.0, *) {
            var btnConfig = UIButton.Configuration.plain()
            btnConfig.contentInsets = .init(top: 0, leading: 0, bottom: 0, trailing: 8)
            
            btnConfig.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(font: Appearance.shared.fonts.buttonFont)
            btnConfig.image = Constants.Images.shared.bookmark
            btnConfig.title = nil
            
            let button = LMButton(configuration: btnConfig)
            button.translatesAutoresizingMaskIntoConstraints = false
            button.tintColor = Appearance.shared.colors.gray2
            button.setContentHuggingPriority(.defaultLow, for: .horizontal)
            return button
        } else {
            let button = LMButton()
            button.translatesAutoresizingMaskIntoConstraints = false
            button.setTitle(nil, for: .normal)
            button.contentEdgeInsets = .init(top: 0, left: 0, bottom: 0, right: 8)
            button.tintColor = Appearance.shared.colors.gray2
            button.setImage(Constants.Images.shared.bookmark, for: .normal)
            return button
        }
    }()
    
    open private(set) lazy var shareButton: LMButton = {
        if #available(iOS 15.0, *) {
            var btnConfig = UIButton.Configuration.plain()
            btnConfig.contentInsets = .zero
            btnConfig.imagePadding = 8
            
            btnConfig.title = nil
            btnConfig.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(font: Appearance.shared.fonts.buttonFont)
            btnConfig.image = Constants.Images.shared.shareIcon
            
            let button = LMButton(configuration: btnConfig)
            button.translatesAutoresizingMaskIntoConstraints = false
            button.tintColor = Appearance.shared.colors.gray2
            button.setContentHuggingPriority(.defaultLow, for: .horizontal)
            return button
        } else {
            let button = LMButton()
            button.translatesAutoresizingMaskIntoConstraints = false
            button.setTitle(nil, for: .normal)
            button.contentEdgeInsets = .init(top: 0, left: 8, bottom: 0, right: 0)
            button.tintColor = Appearance.shared.colors.gray2
            button.setImage(Constants.Images.shared.shareIcon, for: .normal)
            return button
        }
    }()
    
    open private(set) lazy var spacer: LMView = {
        LMView().translatesAutoresizingMaskIntoConstraints()
    }()
    
    // MARK: Data Variables
    public weak var delegate: LMFeedPostFooterViewProtocol?
    
    // MARK: View Hierachy
    open override func setupViews() {
        super.setupViews()
        
        addSubview(stackView)
        [likeButton, likeTextButton, commentButton, spacer, saveButton, shareButton].forEach { stackView.addArrangedSubview($0) }
    }
    
    // MARK: -  Constraints
    open override func setupLayouts() {
        super.setupLayouts()
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            stackView.topAnchor.constraint(equalTo: self.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
        
        [likeButton, likeTextButton, commentButton, spacer, saveButton, shareButton].forEach { btn in
            NSLayoutConstraint.activate([
                btn.topAnchor.constraint(equalTo: stackView.topAnchor),
                btn.bottomAnchor.constraint(equalTo: stackView.bottomAnchor)
            ])
        }
    }
    
    // MARK: Actions
    open override func setupActions() {
        super.setupActions()
        
        likeButton.addTarget(self, action: #selector(didTapLikeButton), for: .touchUpInside)
        likeTextButton.addTarget(self, action: #selector(didTapLikeTextButton), for: .touchUpInside)
        commentButton.addTarget(self, action: #selector(didTapCommentButton), for: .touchUpInside)
        saveButton.addTarget(self, action: #selector(didTapSaveButton), for: .touchUpInside)
        shareButton.addTarget(self, action: #selector(didTapShareButton), for: .touchUpInside)
    }
    
    // MARK: Appearance
    open override func setupAppearance() {
        super.setupAppearance()
        backgroundColor = .clear
    }
    
    
    // MARK: configure
    open func configure(with data: ViewModel) {
        likeButton.setImage(data.isLiked ? Constants.shared.images.heartFilled : Constants.shared.images.heart , for: .normal)
        likeButton.tintColor = data.isLiked ? Appearance.shared.colors.red : Appearance.shared.colors.gray2
        
        saveButton.setImage(data.isSaved ? Constants.shared.images.bookmarkFilled : Constants.shared.images.bookmark, for: .normal)
    }
}

// MARK: Actions
@objc
extension LMFeedPostFooterView {
    open func didTapLikeButton() {
        delegate?.didTapLikeButton()
    }
    
    open func didTapLikeTextButton() {
        delegate?.didTapLikeTextButton()
    }
    
    open func didTapCommentButton() {
        delegate?.didTapCommentButton()
    }
    
    open func didTapSaveButton() {
        delegate?.didTapSaveButton()
    }
    
    open func didTapShareButton() {
        delegate?.didTapShareButton()
    }
}
