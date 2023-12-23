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
    
    open private(set) lazy var bottomLine: LMView = {
        let view = LMView().translatesAutoresizingMaskIntoConstraints()
        view.backgroundColor = Appearance.shared.colors.gray4
        return view
    }()
    
    // MARK: Data Variables
    weak var delegate: LMChatPostCommentProtocol?
    public var commentId: String?
    
    
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
        
        [likeButton, likeTextButton, sepratorView, replyButton, replyCountButton].forEach { subView in
            actionStack.addArrangedSubview(subView)
        }
    }
    
    
    // MARK: setupLayouts
    open override func setupLayouts() {
        super.setupLayouts()
        
        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
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
            commentTimeLabel.centerYAnchor.constraint(equalTo: actionStack.centerYAnchor),
            
            sepratorView.widthAnchor.constraint(equalToConstant: 1),
            actionStack.heightAnchor.constraint(equalToConstant: 24)
        ])
    }
    
    
    // MARK: setupActions
    open override func setupActions() {
        super.setupActions()
        
        menuButton.addTarget(self, action: #selector(didTapMenuButton), for: .touchUpInside)
        likeButton.addTarget(self, action: #selector(didTapLikeButton), for: .touchUpInside)
        likeTextButton.addTarget(self, action: #selector(didTapLikeCountButton), for: .touchUpInside)
        replyButton.addTarget(self, action: #selector(didTapReplyButton), for: .touchUpInside)
        replyCountButton.addTarget(self, action: #selector(didTapReplyCountButton), for: .touchUpInside)
    }
    
    @objc
    open func didTapMenuButton() {
        guard let commentId else { return }
        delegate?.didTapMenuButton(for: commentId)
    }
    
    @objc
    open func didTapLikeButton() {
        guard let commentId else { return }
        delegate?.didTapLikeButton(for: commentId)
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
    
    
    // MARK: setupAppearance
    open override func setupAppearance() {
        super.setupAppearance()
        likeTextButton.isHidden = true
        contentView.backgroundColor = Appearance.shared.colors.white
        containerView.backgroundColor = Appearance.shared.colors.clear
    }
    
    
    // MARK: configure
    open func configure(with data: LMFeedPostDetailCommentCellViewModel, delegate: LMChatPostCommentProtocol) {
        commentId = data.commentId
        self.delegate = delegate
        
        authorNameLabel.text = data.authorName
        
        commentLabel.attributedText = GetAttributedTextWithRoutes.getAttributedText(from: data.comment)
        commentLabel.textContainer.maximumNumberOfLines = commentLabel.numberOfLines > 4 && data.isShowMore ? .zero : 4
        
        seeMoreText.isHidden = !(commentLabel.numberOfLines > 4 && data.isShowMore)
        
        commentTimeLabel.text = data.commentTimeFormatted
        
        likeButton.setImage(data.isLiked ? Constants.shared.images.heartFilled : Constants.shared.images.heart, for: .normal)
        likeButton.tintColor = data.isLiked ? Appearance.shared.colors.red : Appearance.shared.colors.gray3
        
        likeTextButton.isHidden = data.likeCount == .zero
        likeTextButton.setTitle(data.likeText, for: .normal)
        
        replyCountButton.setTitle(data.commentText, for: .normal)
        replyCountButton.isHidden = data.totalReplyCount == .zero
        
        bottomLine.isHidden = !data.replies.isEmpty
    }
}
