//
//  LMFeedPostBaseFooterView.swift
//  LikeMindsFeedUI
//
//  Created by Devansh Mohata on 21/07/24.
//

import UIKit

// MARK: LMFeedPostFooterViewProtocol
public protocol LMFeedPostFooterViewProtocol: AnyObject {
    func didTapLikeButton(for postID: String)
    func didTapLikeTextButton(for postID: String)
    func didTapCommentButton(for postID: String)
    func didTapShareButton(for postID: String)
    func didTapSaveButton(for postID: String)
    func didTapPost(postID: String)
}


open class LMFeedPostBaseFooterView: LMTableViewHeaderFooterView {
    public struct ContentModel {
        public var isSaved: Bool
        public var isLiked: Bool
        public var likeCount: Int
        public var commentCount: Int
        public var likeText: String
        public var commentText: String
        
        public init(isSaved: Bool, isLiked: Bool, likeCount: Int, commentCount: Int, likeText: String, commentText: String) {
            self.isSaved = isSaved
            self.isLiked = isLiked
            self.likeCount = likeCount
            self.commentCount = commentCount
            self.likeText = likeText
            self.commentText = commentText
        }
    }
    
    // MARK: UI Elements
    open private(set) lazy var containerView: LMView = {
        let view = LMView().translatesAutoresizingMaskIntoConstraints()
        return view
    }()
    
    open private(set) lazy var actionStackView: LMStackView = {
        let stack = LMStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.spacing = 8
        stack.alignment = .fill
        stack.distribution = .fill
        return stack
    }()
    
    open private(set) lazy var likeButton: LMButton = {
        let button = LMButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(LMFeedConstants.shared.images.heart, for: .normal)
        button.setImage(LMFeedConstants.shared.images.heartFilled, for: .selected)
        button.tintColor = LMFeedAppearance.shared.colors.gray2
        button.setPreferredSymbolConfiguration(.init(font: LMFeedAppearance.shared.fonts.buttonFont1, scale: .large), forImageIn: .normal)
        return button
    }()
    
    open private(set) lazy var likeTextButton: LMButton = {
        let button = LMButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(LMFeedConstants.shared.strings.like, for: .normal)
        button.setTitleColor(LMFeedAppearance.shared.colors.gray2, for: .normal)
        button.tintColor = LMFeedAppearance.shared.colors.gray2
        return button
    }()
    
    open private(set) lazy var commentButton: LMButton = {
        let button = LMButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(LMFeedConstants.Images.shared.commentIcon, for: .normal)
        button.setTitle("", for: .normal)
        button.setTitleColor(LMFeedAppearance.shared.colors.gray2, for: .normal)
        button.tintColor = LMFeedAppearance.shared.colors.gray2
        button.centerTextAndImage(spacing: 4)
        button.setPreferredSymbolConfiguration(.init(font: LMFeedAppearance.shared.fonts.buttonFont1, scale: .large), forImageIn: .normal)
        return button
    }()
    
    open private(set) lazy var saveButton: LMButton = {
        let button = LMButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(LMFeedConstants.shared.images.bookmark, for: .normal)
        button.setImage(LMFeedConstants.shared.images.bookmarkFilled, for: .selected)
        button.tintColor = LMFeedAppearance.shared.colors.gray2
        button.setPreferredSymbolConfiguration(.init(font: LMFeedAppearance.shared.fonts.buttonFont1, scale: .large), forImageIn: .normal)
        return button
    }()
    
    open private(set) lazy var shareButton: LMButton = {
        let button = LMButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(LMFeedConstants.shared.images.shareIcon, for: .normal)
        button.tintColor = LMFeedAppearance.shared.colors.gray2
        button.setPreferredSymbolConfiguration(.init(font: LMFeedAppearance.shared.fonts.buttonFont1, scale: .large), forImageIn: .normal)
        return button
    }()
    
    open private(set) lazy var spacer: LMView = {
        LMView().translatesAutoresizingMaskIntoConstraints()
    }()
    
    
    // MARK: Data Variables
    public var postID: String?
    public var likeCount: Int = 0
    public weak var delegate: LMFeedPostFooterViewProtocol?
    
    public var likeText: String = "Like"
    public var commentText: String = "Comment"
    
    
    // MARK: Actions
    open override func setupActions() {
        super.setupActions()
        
        likeButton.addTarget(self, action: #selector(didTapLikeButton), for: .touchUpInside)
        likeTextButton.addTarget(self, action: #selector(didTapLikeTextButton), for: .touchUpInside)
        commentButton.addTarget(self, action: #selector(didTapCommentButton), for: .touchUpInside)
        saveButton.addTarget(self, action: #selector(didTapSaveButton), for: .touchUpInside)
        shareButton.addTarget(self, action: #selector(didTapShareButton), for: .touchUpInside)
        containerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapPost)))
    }
    
    
    // MARK: Appearance
    open override func setupAppearance() {
        super.setupAppearance()
        containerView.backgroundColor = LMFeedAppearance.shared.colors.white
    }
    
    
    // MARK: configure
    open func configure(with data: ContentModel, postID: String, delegate: LMFeedPostFooterViewProtocol) {
        self.likeText = data.likeText
        self.commentText = data.commentText
        
        self.postID = postID
        self.likeCount = data.likeCount
        self.delegate = delegate
        
        likeButton.isSelected = data.isLiked
        likeButton.tintColor = data.isLiked ? LMFeedAppearance.shared.colors.red : LMFeedAppearance.shared.colors.gray2
        
        likeTextButton.setTitle(getLikeText(for: data.likeCount), for: .normal)
        commentButton.setTitle(getCommentText(for: data.commentCount), for: .normal)
        
        saveButton.isSelected = data.isSaved
    }
    
    open func getLikeText(for likeCount: Int) -> String {
        if likeCount == .zero {
            return likeText
        }
        
        return "\(likeCount) \(likeText.pluralize(count: likeCount))"
    }
    
    open func getCommentText(for commentCount: Int) -> String {
        commentCount == .zero ? "Add \(commentText)" : "\(commentCount) \(commentText.pluralize(count: commentCount))"
    }
}


// MARK: Actions
@objc
extension LMFeedPostBaseFooterView {
    open func didTapLikeButton() {
        guard let postID else { return }
        likeButton.isSelected.toggle()
        likeButton.tintColor = likeButton.isSelected ? LMFeedAppearance.shared.colors.red : LMFeedAppearance.shared.colors.gray2
        likeCount += likeButton.isSelected ? 1 : -1
        likeTextButton.setTitle(getLikeText(for: likeCount), for: .normal)
        delegate?.didTapLikeButton(for: postID)
    }
    
    open func didTapLikeTextButton() {
        guard let postID else { return }
        delegate?.didTapLikeTextButton(for: postID)
    }
    
    open func didTapCommentButton() {
        guard let postID else { return }
        delegate?.didTapCommentButton(for: postID)
    }
    
    open func didTapSaveButton() {
        guard let postID else { return }
        saveButton.isSelected.toggle()
        delegate?.didTapSaveButton(for: postID)
    }
    
    open func didTapShareButton() {
        guard let postID else { return }
        delegate?.didTapShareButton(for: postID)
    }
    
    open func didTapPost() {
        guard let postID else { return }
        delegate?.didTapPost(postID: postID)
    }
}
