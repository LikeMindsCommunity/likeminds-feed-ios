//
//  LMFeedPostDetailCommentHeaderView.swift
//  LMFramework
//
//  Created by Devansh Mohata on 14/12/23.
//

import UIKit

@IBDesignable
open class LMFeedPostDetailCommentHeaderView: LMTableViewHeaderFooterView {
    // MARK: UI Elements
    open private(set) lazy var containerView: LMView = {
        let view = LMView().translatesAutoresizingMaskIntoConstraints()
        return view
    }()
    
    open private(set) lazy var authorNameLabel: LMLabel = {
        let label = LMLabel().translatesAutoresizingMaskIntoConstraints()
        label.textColor = Appearance.shared.colors.gray1
        label.font = Appearance.shared.fonts.headingFont3
        label.text = "Ronald Richards"
        return label
    }()
    
    open private(set) lazy var commentStack: LMStackView = {
        let stack = LMStackView().translatesAutoresizingMaskIntoConstraints()
        stack.axis = .vertical
        stack.alignment = .leading
        stack.distribution = .fill
        stack.spacing = 8
        return stack
    }()
    
    open private(set) lazy var commentContainerStack: LMStackView = {
        let stack = LMStackView().translatesAutoresizingMaskIntoConstraints()
        stack.axis = .horizontal
        stack.alignment = .center
        stack.distribution = .equalSpacing
        return stack
    }()
    
    open private(set) lazy var commentLabel: LMTextView = {
        let label = LMTextView().translatesAutoresizingMaskIntoConstraints()
        label.isScrollEnabled = false
        label.isEditable = false
        label.textContainer.lineBreakMode = .byTruncatingTail
        label.backgroundColor = Appearance.shared.colors.clear
        label.textColor = Appearance.shared.colors.gray1
        label.font = Appearance.shared.fonts.subHeadingFont2
        label.textContainer.lineFragmentPadding = CGFloat(0.0)
        label.textContainerInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        label.contentInset = UIEdgeInsets(top: 0,left: 0,bottom: 0,right: 0)
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
    
    open private(set) lazy var sepratorView: LMView = {
        let view = LMView().translatesAutoresizingMaskIntoConstraints()
        view.backgroundColor = Appearance.shared.colors.gray3
        return view
    }()
    
    open private(set) lazy var replyButton: LMButton = {
        let button = LMButton().translatesAutoresizingMaskIntoConstraints()
        button.setImage(nil, for: .normal)
        button.setTitle("Reply", for: .normal)
        button.setTitleColor(Appearance.shared.colors.gray3, for: .normal)
        button.setFont(Appearance.shared.fonts.buttonFont1)
        return button
    }()
    
    open private(set) lazy var replyCountButton: LMButton = {
        let button = LMButton().translatesAutoresizingMaskIntoConstraints()
        button.setTitle(nil, for: .normal)
        button.setImage(nil, for: .normal)
        button.setTitleColor(Appearance.shared.colors.appTintColor, for: .normal)
        button.setFont(Appearance.shared.fonts.buttonFont1)
        return button
    }()
    
    open private(set) lazy var commentTimeLabel: LMLabel = {
        let label = LMLabel().translatesAutoresizingMaskIntoConstraints()
        label.textColor = Appearance.shared.colors.gray3
        label.font = Appearance.shared.fonts.subHeadingFont1
        return label
    }()
    
    
    // MARK: Data Variables
    weak var delegate: LMChatPostCommentProtocol?
    public var commentId: String?
    public var indexPath: IndexPath?
    public var seeMoreAction: (() -> Void)?

    
    // MARK: setupViews
    open override func setupViews() {
        super.setupViews()
        
        contentView.addSubview(containerView)
        
        [authorNameLabel, commentContainerStack, actionStack, commentTimeLabel].forEach { subView in
            containerView.addSubview(subView)
        }
        
        commentContainerStack.addArrangedSubview(commentStack)
        commentContainerStack.addArrangedSubview(menuButton)
        commentStack.addArrangedSubview(commentLabel)
        commentStack.addArrangedSubview(seeMoreText)
        
        [likeButton, likeTextButton, sepratorView, replyButton, replyCountButton].forEach { subView in
            actionStack.addArrangedSubview(subView)
        }
    }
    
    
    // MARK: setupLayouts
    open override func setupLayouts() {
        super.setupLayouts()
        
        contentView.pinSubView(subView: containerView)
        authorNameLabel.addConstraint(top: (containerView.topAnchor, 16),
                                      leading: (containerView.leadingAnchor, 16))
        
        commentContainerStack.addConstraint(top: (authorNameLabel.bottomAnchor, 2),
                                            bottom: (actionStack.topAnchor, -8),
                                            leading: (authorNameLabel.leadingAnchor, 0),
                                            trailing: (containerView.trailingAnchor, -16))
        
        actionStack.addConstraint(bottom: (containerView.bottomAnchor, -8),
                                  leading: (commentContainerStack.leadingAnchor, 0))
        
        commentTimeLabel.addConstraint(trailing: (commentContainerStack.trailingAnchor, 0),
                                       centerY: (actionStack.centerYAnchor, 0))
        
        sepratorView.setWidthConstraint(with: 1)
        actionStack.setHeightConstraint(with: 34)
        
        authorNameLabel.trailingAnchor.constraint(lessThanOrEqualTo: containerView.trailingAnchor, constant: -16).isActive = true
        commentTimeLabel.leadingAnchor.constraint(greaterThanOrEqualTo: actionStack.trailingAnchor, constant: 16).isActive = true
        
        seeMoreText.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
    }
    
    
    // MARK: setupActions
    open override func setupActions() {
        super.setupActions()
        
        seeMoreText.addTarget(self, action: #selector(didTapSeeMoreButton), for: .touchUpInside)
        menuButton.addTarget(self, action: #selector(didTapMenuButton), for: .touchUpInside)
        likeButton.addTarget(self, action: #selector(didTapLikeButton), for: .touchUpInside)
        likeTextButton.addTarget(self, action: #selector(didTapLikeCountButton), for: .touchUpInside)
        replyButton.addTarget(self, action: #selector(didTapReplyButton), for: .touchUpInside)
        replyCountButton.addTarget(self, action: #selector(didTapReplyCountButton), for: .touchUpInside)
    }
    
    @objc
    open func didTapSeeMoreButton() {
        seeMoreAction?()
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
    open func didTapReplyButton() {
        guard let commentId else { return }
        delegate?.didTapReplyButton(for: commentId)
    }
    
    @objc
    open func didTapReplyCountButton() {
        guard let commentId else { return }
        delegate?.didTapReplyCountButton(for: commentId)
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
        }
    }
    
    open func didTapURL(url: URL) { 
        delegate?.didTapURL(url: url)
    }
    
    open func didTapHashTag(hashtag: String) { }
    
    open func didTapRoute(route: String) {
        delegate?.didTapUserName(for: route)
    }
    
    // MARK: setupAppearance
    open override func setupAppearance() {
        super.setupAppearance()
        contentView.backgroundColor = Appearance.shared.colors.white
        containerView.backgroundColor = Appearance.shared.colors.clear
        
        commentLabel.textContainer.lineFragmentPadding = .zero
        commentLabel.textContainerInset = .zero
        commentLabel.contentInset = .zero
    }
    
    
    // MARK: configure
    open func configure(with data: LMFeedPostDetailCommentCellViewModel, delegate: LMChatPostCommentProtocol, indexPath: IndexPath, seeMoreAction: (() -> Void)? = nil) {
        commentId = data.commentId
        
        self.delegate = delegate
        self.indexPath = indexPath
        self.seeMoreAction = seeMoreAction
        
        authorNameLabel.text = data.authorName
        
        commentLabel.attributedText = GetAttributedTextWithRoutes.getAttributedText(from: data.comment.trimmingCharacters(in: .whitespacesAndNewlines))
        
        seeMoreText.isHidden = true // !(commentLabel.numberOfLines > 4 && data.isShowMore)
        commentLabel.textContainer.maximumNumberOfLines = 0 // commentLabel.numberOfLines > 4 && !data.isShowMore ? .zero : 4
        
        
        commentTimeLabel.text = data.commentTimeFormatted
        
        likeButton.setImage(data.isLiked ? Constants.shared.images.heartFilled : Constants.shared.images.heart, for: .normal)
        likeButton.tintColor = data.isLiked ? Appearance.shared.colors.red : Appearance.shared.colors.gray3
        likeButton.isEnabled = data.commentId != nil
        
        likeTextButton.isHidden = data.likeCount == .zero
        likeTextButton.setTitle(data.likeText, for: .normal)
        
        replyButton.isEnabled = data.commentId != nil
        replyCountButton.setTitle(data.commentText, for: .normal)
        replyCountButton.isHidden = data.totalReplyCount == .zero
    }
}
