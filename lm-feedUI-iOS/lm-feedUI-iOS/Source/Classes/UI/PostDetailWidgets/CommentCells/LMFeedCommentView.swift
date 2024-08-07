//
//  LMFeedCommentView.swift
//  LMFramework
//
//  Created by Devansh Mohata on 14/12/23.
//

import UIKit

@IBDesignable
open class LMFeedCommentView: LMTableViewHeaderFooterView {
    // MARK: UI Elements
    open private(set) lazy var containerView: LMView = {
        let view = LMView().translatesAutoresizingMaskIntoConstraints()
        return view
    }()
    
    open private(set) lazy var authorNameLabel: LMLabel = {
        let label = LMLabel().translatesAutoresizingMaskIntoConstraints()
        label.textColor = LMFeedAppearance.shared.colors.gray1
        label.font = LMFeedAppearance.shared.fonts.headingFont3
        label.text = "Ronald Richards"
        label.isUserInteractionEnabled = true
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
        label.backgroundColor = LMFeedAppearance.shared.colors.clear
        label.textColor = LMFeedAppearance.shared.colors.gray1
        label.font = LMFeedAppearance.shared.fonts.subHeadingFont2
        label.textContainer.lineFragmentPadding = CGFloat(0.0)
        label.textContainerInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        label.contentInset = UIEdgeInsets(top: 0,left: 0,bottom: 0,right: 0)
        return label
    }()
    
    open private(set) lazy var seeMoreText: LMButton = {
        let button = LMButton().translatesAutoresizingMaskIntoConstraints()
        button.setTitle("See More", for: .normal)
        button.setTitleColor(LMFeedAppearance.shared.colors.gray155, for: .normal)
        button.setFont(LMFeedAppearance.shared.fonts.buttonFont1)
        button.setImage(nil, for: .normal)
        return button
    }()
    
    open private(set) lazy var menuButton: LMButton = {
        let button = LMButton().translatesAutoresizingMaskIntoConstraints()
        button.setTitle(nil, for: .normal)
        button.setImage(LMFeedConstants.shared.images.ellipsis, for: .normal)
        button.tintColor = LMFeedAppearance.shared.colors.gray102
        return button
    }()
    
    open private(set) lazy var actionStack: LMStackView = {
        let stack = LMStackView().translatesAutoresizingMaskIntoConstraints()
        stack.axis = .horizontal
        stack.alignment = .center
        stack.distribution = .fill
        stack.spacing = 8
        return stack
    }()
    
    open private(set) lazy var likeButton: LMButton = {
        let button = LMButton().translatesAutoresizingMaskIntoConstraints()
        button.setTitle(nil, for: .normal)
        button.setImage(LMFeedConstants.shared.images.heart, for: .normal)
        button.setImage(LMFeedConstants.shared.images.heartFilled, for: .selected)
        button.tintColor = LMFeedAppearance.shared.colors.gray3
        return button
    }()
    
    open private(set) lazy var likeTextButton: LMButton = {
        let button = LMButton().translatesAutoresizingMaskIntoConstraints()
        button.setTitle(nil, for: .normal)
        button.setImage(nil, for: .normal)
        button.setTitleColor(LMFeedAppearance.shared.colors.gray3, for: .normal)
        button.setFont(LMFeedAppearance.shared.fonts.buttonFont1)
        return button
    }()
    
    open private(set) lazy var sepratorView: LMView = {
        let view = LMView().translatesAutoresizingMaskIntoConstraints()
        view.backgroundColor = LMFeedAppearance.shared.colors.gray3
        return view
    }()
    
    open private(set) lazy var replyButton: LMButton = {
        let button = LMButton().translatesAutoresizingMaskIntoConstraints()
        button.setImage(nil, for: .normal)
        button.setTitle("Reply", for: .normal)
        button.setTitleColor(LMFeedAppearance.shared.colors.gray3, for: .normal)
        button.setFont(LMFeedAppearance.shared.fonts.buttonFont1)
        return button
    }()
    
    open private(set) lazy var replyCountButton: LMButton = {
        let button = LMButton().translatesAutoresizingMaskIntoConstraints()
        button.setTitle(nil, for: .normal)
        button.setImage(nil, for: .normal)
        button.setTitleColor(LMFeedAppearance.shared.colors.appTintColor, for: .normal)
        button.setFont(LMFeedAppearance.shared.fonts.buttonFont1)
        return button
    }()
    
    open private(set) lazy var commentTimeLabel: LMLabel = {
        let label = LMLabel().translatesAutoresizingMaskIntoConstraints()
        label.textColor = LMFeedAppearance.shared.colors.gray3
        label.font = LMFeedAppearance.shared.fonts.subHeadingFont1
        return label
    }()
    
    
    // MARK: Data Variables
    weak var delegate: LMFeedPostCommentProtocol?
    public var commentId: String?
    public var indexPath: IndexPath?
    public var likeCount: Int = 0
    public var likeText: String = LMFeedConstants.shared.strings.like
    public var commentUserUUID: String?
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
        sepratorView.setHeightConstraint(with: 24)
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
        authorNameLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapCommentUser)))
    }
    
    @objc
    open func didTapSeeMoreButton() {
        seeMoreAction?()
    }
    
    @objc
    open func didTapMenuButton() {
        guard let commentId else { return }
        delegate?.didTapCommentMenuButton(for: commentId)
    }
    
    @objc
    open func didTapLikeButton() {
        guard let commentId,
              let indexPath else { return }
        likeButton.isSelected.toggle()
        likeButton.tintColor = likeButton.isSelected ? LMFeedAppearance.shared.colors.red : LMFeedAppearance.shared.colors.gray3
        likeCount += likeButton.isSelected ? 1 : -1
        
        likeTextButton.isHidden = likeCount == 0
        if likeCount == 0 {
            likeTextButton.setTitle(likeText, for: .normal)
        } else {
            likeTextButton.setTitle("\(likeCount) \(likeText.pluralize(count: likeCount))", for: .normal)
        }
        
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
    
    @objc
    open func didTapCommentUser() {
        guard let commentUserUUID else { return }
        didTapRoute(route: commentUserUUID)
    }
    
    // MARK: setupAppearance
    open override func setupAppearance() {
        super.setupAppearance()
        contentView.backgroundColor = LMFeedAppearance.shared.colors.white
        containerView.backgroundColor = LMFeedAppearance.shared.colors.clear
        
        commentLabel.textContainer.lineFragmentPadding = .zero
        commentLabel.textContainerInset = .zero
        commentLabel.contentInset = .zero
    }
    
    
    // MARK: configure
    open func configure(with data: LMFeedCommentContentModel, delegate: LMFeedPostCommentProtocol, indexPath: IndexPath, seeMoreAction: (() -> Void)? = nil) {
        commentId = data.commentId
        
        self.delegate = delegate
        self.indexPath = indexPath
        self.likeCount = data.likeCount
        self.commentUserUUID = data.author.userUUID
        self.seeMoreAction = seeMoreAction
        
        authorNameLabel.text = data.authorName
        
        commentLabel.attributedText = GetAttributedTextWithRoutes.getAttributedText(from: data.comment.trimmingCharacters(in: .whitespacesAndNewlines), andPrefix: LMFeedConstants.shared.strings.taggingCharacter)
        
        seeMoreText.isHidden = true // !(commentLabel.numberOfLines > 4 && data.isShowMore)
        commentLabel.textContainer.maximumNumberOfLines = 0 // commentLabel.numberOfLines > 4 && !data.isShowMore ? .zero : 4
        
        
        commentTimeLabel.text = data.commentTimeFormatted
        
        likeButton.isSelected = data.isLiked
        likeButton.tintColor = data.isLiked ? LMFeedAppearance.shared.colors.red : LMFeedAppearance.shared.colors.gray3
        likeButton.isEnabled = data.commentId != nil
        
        likeTextButton.isHidden = data.likeCount == .zero
        likeTextButton.setTitle(data.likeText, for: .normal)
        
        replyButton.isEnabled = data.commentId != nil
        replyCountButton.setTitle(data.commentText, for: .normal)
        replyCountButton.isHidden = data.totalReplyCount == .zero
        
        self.likeText = data.likeKeyword
    }
}
