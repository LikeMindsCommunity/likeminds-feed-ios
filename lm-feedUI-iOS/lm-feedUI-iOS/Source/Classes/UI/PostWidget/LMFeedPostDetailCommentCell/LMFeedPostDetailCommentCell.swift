//
//  LMFeedPostDetailCommentCell.swift
//  LMFramework
//
//  Created by Devansh Mohata on 15/12/23.
//

import UIKit

@IBDesignable
open class LMFeedPostDetailCommentCell: LMTableViewCell {
    // MARK: UI Elements    
    open private(set) lazy var authorNameLabel: LMLabel = {
        let label = LMLabel().translatesAutoresizingMaskIntoConstraints()
        label.textColor = Appearance.shared.colors.gray1
        label.font = Appearance.shared.fonts.headingFont3
        label.text = "Ronald RichardsRonald RichardsRonald RichardsRonald RichardsRonald RichardsRonald RichardsRonald RichardsRonald RichardsRonald RichardsRonald RichardsRonald Richards"
        return label
    }()
    
    open private(set) lazy var commentContainerStack: LMStackView = {
        let stack = LMStackView().translatesAutoresizingMaskIntoConstraints()
        stack.axis = .horizontal
        stack.alignment = .center
        stack.distribution = .equalSpacing
        return stack
    }()
    
    open private(set) lazy var commentStack: LMStackView = {
        let stack = LMStackView().translatesAutoresizingMaskIntoConstraints()
        stack.axis = .vertical
        stack.alignment = .leading
        stack.distribution = .fill
        stack.spacing = 0
        return stack
    }()
    
    open private(set) lazy var commentLabel: LMTextView = {
        let label = LMTextView().translatesAutoresizingMaskIntoConstraints()
        label.isScrollEnabled = false
        label.textContainer.lineBreakMode = .byTruncatingTail
        label.backgroundColor = Appearance.shared.colors.clear
        label.textColor = Appearance.shared.colors.gray1
        label.font = Appearance.shared.fonts.subHeadingFont2
        return label
    }()
    
    open private(set) lazy var seeMoreText: LMButton = {
        let button = LMButton().translatesAutoresizingMaskIntoConstraints()
        button.setTitle("See More", for: .normal)
        button.setTitleColor(Appearance.shared.colors.gray155, for: .normal)
        button.setFont(Appearance.shared.fonts.buttonFont1)
        button.setImage(nil, for: .normal)
        return button
    }()
    
    open private(set) lazy var menuButton: LMButton = {
        let button = LMButton().translatesAutoresizingMaskIntoConstraints()
        button.setTitle(nil, for: .normal)
        button.setImage(Constants.shared.images.ellipsis, for: .normal)
        button.tintColor = Appearance.shared.colors.gray102
        return button
    }()
    
    open private(set) lazy var actionStack: LMStackView = {
        let stack = LMStackView().translatesAutoresizingMaskIntoConstraints()
        stack.axis = .horizontal
        stack.alignment = .fill
        stack.distribution = .fill
        stack.spacing = 8
        return stack
    }()
    
    open private(set) lazy var likeButton: LMButton = {
        let button = LMButton().translatesAutoresizingMaskIntoConstraints()
        button.setTitle(nil, for: .normal)
        button.setImage(Constants.shared.images.heart, for: .normal)
        button.tintColor = Appearance.shared.colors.gray3
        return button
    }()
    
    open private(set) lazy var likeTextButton: LMButton = {
        let button = LMButton().translatesAutoresizingMaskIntoConstraints()
        button.setTitle(nil, for: .normal)
        button.setImage(nil, for: .normal)
        button.setTitleColor(Appearance.shared.colors.gray3, for: .normal)
        button.setFont(Appearance.shared.fonts.buttonFont1)
        return button
    }()
    
    open private(set) lazy var commentTimeLabel: LMLabel = {
        let label = LMLabel().translatesAutoresizingMaskIntoConstraints()
        label.textColor = Appearance.shared.colors.gray3
        label.font = Appearance.shared.fonts.subHeadingFont1
        label.text = "20m"
        return label
    }()
    
    open private(set) lazy var bottomLine: LMView = {
        let view = LMView().translatesAutoresizingMaskIntoConstraints()
        view.backgroundColor = Appearance.shared.colors.gray4
        return view
    }()
    
    
    // MARK: Data Variables
    weak var delegate: LMChatPostCommentProtocol?
    public var commentId: String?
    public var userUUID: String?
    public var indexPath: IndexPath?
    
    
    // MARK: setupViews
    open override func setupViews() {
        super.setupViews()
        
        contentView.addSubview(containerView)
        contentView.addSubview(bottomLine)
        
        [authorNameLabel, commentContainerStack, actionStack, commentTimeLabel].forEach { subView in
            containerView.addSubview(subView)
        }
        
        commentContainerStack.addArrangedSubview(commentStack)
        commentContainerStack.addArrangedSubview(menuButton)
        commentStack.addArrangedSubview(commentLabel)
        commentStack.addArrangedSubview(seeMoreText)
        
        actionStack.addArrangedSubview(likeButton)
    }
    
    open override func setupLayouts() {
        super.setupLayouts()
        
        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 32),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomLine.topAnchor),
            bottomLine.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor),
            bottomLine.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            bottomLine.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            bottomLine.heightAnchor.constraint(equalToConstant: 1),
            
            authorNameLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            authorNameLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            authorNameLabel.trailingAnchor.constraint(lessThanOrEqualTo: containerView.trailingAnchor, constant: -16),
            
            commentContainerStack.leadingAnchor.constraint(equalTo: authorNameLabel.leadingAnchor),
            commentContainerStack.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            commentContainerStack.topAnchor.constraint(equalTo: authorNameLabel.bottomAnchor, constant: 16),
            commentContainerStack.bottomAnchor.constraint(equalTo: actionStack.topAnchor, constant: -8),
            
            actionStack.leadingAnchor.constraint(equalTo: commentContainerStack.leadingAnchor),
            actionStack.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16),
            commentTimeLabel.trailingAnchor.constraint(equalTo: commentContainerStack.trailingAnchor),
            commentTimeLabel.leadingAnchor.constraint(greaterThanOrEqualTo: actionStack.trailingAnchor, constant: 16),
            commentTimeLabel.centerYAnchor.constraint(equalTo: actionStack.centerYAnchor)
        ])
    }
    
    
    // MARK: setupActions
    open override func setupActions() {
        super.setupActions()
        
        menuButton.addTarget(self, action: #selector(didTapMenuButton), for: .touchUpInside)
        likeButton.addTarget(self, action: #selector(didTapLikeButton), for: .touchUpInside)
        likeTextButton.addTarget(self, action: #selector(didTapLikeCountButton), for: .touchUpInside)
        commentLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tappedTextView)))
    }
    
    @objc
    open func didTapMenuButton() {
        guard let commentId else { return }
        delegate?.didTapMenuButton(for: commentId)
    }
    
    @objc
    open func didTapLikeButton() {
        guard let commentId,
              let indexPath else { return }
        delegate?.didTapLikeButton(for: commentId, indexPath: indexPath)
    }
    
    @objc
    open func didTapLikeCountButton() {
        guard let commentId else { return }
        delegate?.didTapLikeCountButton(for: commentId)
    }
    
    @objc
    open func didTapUsername() {
        guard let userUUID else { return }
        delegate?.didTapUserName(for: userUUID)
    }
    
    @objc
    open func tappedTextView(tapGesture: UITapGestureRecognizer) {
        guard let textView = tapGesture.view as? LMTextView,
              let position = textView.closestPosition(to: tapGesture.location(in: textView)),
              let text = textView.textStyling(at: position, in: .forward) else { return }
        if let url = text[.link] as? URL {
            didTapURL(url: url)
        } else if let hashtag = text[.hashtags] as? String {
            didTapHashTag(hashtag: hashtag)
        } else if let route = text[.route] as? String {
            didTapRoute(route: route)
        } else {
            didTapPostText()
        }
    }
    
    open func didTapURL(url: URL) {
        UIApplication.shared.open(url)
    }
    
    open func didTapHashTag(hashtag: String) { }
    
    open func didTapRoute(route: String) { }
    
    open func didTapPostText() { }
    
    // MARK: setupAppearance
    open override func setupAppearance() {
        super.setupAppearance()
        
        backgroundColor = Appearance.shared.colors.clear
        contentView.backgroundColor = Appearance.shared.colors.white
        containerView.backgroundColor = Appearance.shared.colors.clear
    }
    
    
    // MARK: configure
    open func configure(with data: LMFeedPostDetailCommentCellViewModel, delegate: LMChatPostCommentProtocol, isShowSeprator: Bool, indexPath: IndexPath) {
        commentId = data.commentId
        self.delegate = delegate
        self.userUUID = data.author.userUUID
        self.indexPath = indexPath
        
        authorNameLabel.text = data.authorName
        
        commentLabel.attributedText = GetAttributedTextWithRoutes.getAttributedText(from: data.comment)
        commentLabel.textContainer.maximumNumberOfLines = commentLabel.numberOfLines > 4 && data.isShowMore ? .zero : 4
        
        seeMoreText.isHidden = !(commentLabel.numberOfLines > 4 && data.isShowMore)
        
        commentTimeLabel.text = data.commentTimeFormatted
        
        likeButton.setImage(data.isLiked ? Constants.shared.images.heartFilled : Constants.shared.images.heart, for: .normal)
        likeButton.tintColor = data.isLiked ? Appearance.shared.colors.red : Appearance.shared.colors.gray3
        likeButton.isEnabled = data.commentId != nil
        
        likeTextButton.isHidden = data.likeCount == .zero
        likeTextButton.setTitle(data.likeText, for: .normal)
        
        bottomLine.isHidden = !isShowSeprator
    }
}
