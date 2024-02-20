//
//  LMFeedPostFooterView.swift
//  LMFramework
//
//  Created by Devansh Mohata on 28/11/23.
//

import UIKit

public protocol LMFeedPostFooterViewProtocol: AnyObject {
    func didTapLikeButton(for postID: String)
    func didTapLikeTextButton(for postID: String)
    func didTapCommentButton(for postID: String)
    func didTapShareButton(for postID: String)
    func didTapSaveButton(for postID: String)
    func didTapPost(postID: String)
}

@IBDesignable
open class LMFeedPostFooterView: LMTableViewHeaderFooterView {
    public struct ViewModel {
        public var isSaved: Bool
        public var isLiked: Bool
        public var likeCount: Int
        public var commentCount: Int
        
        public init(likeCount: Int, commentCount: Int, isSaved: Bool = false, isLiked: Bool = false) {
            self.likeCount = likeCount
            self.commentCount = commentCount
            self.isSaved = isSaved
            self.isLiked = isLiked
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
        button.setImage(Constants.shared.images.heart, for: .normal)
        button.setImage(Constants.shared.images.heartFilled, for: .selected)
        button.tintColor = Appearance.shared.colors.gray2
        button.setPreferredSymbolConfiguration(.init(font: Appearance.shared.fonts.buttonFont1, scale: .large), forImageIn: .normal)
        return button
    }()
    
    open private(set) lazy var likeTextButton: LMButton = {
        let button = LMButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(Constants.shared.strings.like, for: .normal)
        button.setTitleColor(Appearance.shared.colors.gray2, for: .normal)
        button.tintColor = Appearance.shared.colors.gray2
        return button
    }()
    
    open private(set) lazy var commentButton: LMButton = {
        let button = LMButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(Constants.Images.shared.commentIcon, for: .normal)
        button.setTitle(Constants.shared.strings.comment, for: .normal)
        button.setTitleColor(Appearance.shared.colors.gray2, for: .normal)
        button.tintColor = Appearance.shared.colors.gray2
        button.centerTextAndImage(spacing: 4)
        button.setPreferredSymbolConfiguration(.init(font: Appearance.shared.fonts.buttonFont1, scale: .large), forImageIn: .normal)
        return button
    }()
    
    open private(set) lazy var saveButton: LMButton = {
        let button = LMButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(Constants.shared.images.bookmark, for: .normal)
        button.setImage(Constants.shared.images.bookmarkFilled, for: .selected)
        button.tintColor = Appearance.shared.colors.gray2
        button.setPreferredSymbolConfiguration(.init(font: Appearance.shared.fonts.buttonFont1, scale: .large), forImageIn: .normal)
        return button
    }()
    
    open private(set) lazy var shareButton: LMButton = {
        let button = LMButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(Constants.shared.images.shareIcon, for: .normal)
        button.tintColor = Appearance.shared.colors.gray2
        button.setPreferredSymbolConfiguration(.init(font: Appearance.shared.fonts.buttonFont1, scale: .large), forImageIn: .normal)
        return button
    }()
    
    open private(set) lazy var spacer: LMView = {
        LMView().translatesAutoresizingMaskIntoConstraints()
    }()
    
    // MARK: Data Variables
    public weak var delegate: LMFeedPostFooterViewProtocol?
    public var postID: String?
    public var likeCount: Int = 0
    
    // MARK: View Hierachy
    open override func setupViews() {
        super.setupViews()
        
        contentView.addSubview(containerView)
        containerView.addSubview(actionStackView)
        [likeButton, likeTextButton, commentButton, spacer, saveButton, shareButton].forEach { actionStackView.addArrangedSubview($0) }
    }
    
    // MARK: -  Constraints
    open override func setupLayouts() {
        super.setupLayouts()
        
        contentView.pinSubView(subView: containerView, padding: .init(top: 0, left: 0, bottom: -8, right: 0))
        containerView.pinSubView(subView: actionStackView, padding: .init(top: 8, left: 16, bottom: -8, right: -16))
        
        [likeButton, likeTextButton, commentButton, saveButton, shareButton].forEach { btn in
            btn.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
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
        containerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapPost)))
    }
    
    // MARK: Appearance
    open override func setupAppearance() {
        super.setupAppearance()
        containerView.backgroundColor = Appearance.shared.colors.white
    }
    
    
    // MARK: configure
    open func configure(with data: ViewModel, postID: String, delegate: LMFeedPostFooterViewProtocol) {
        self.postID = postID
        self.likeCount = data.likeCount
        self.delegate = delegate
        
        likeButton.isSelected = data.isLiked
//        likeButton.setImage(data.isLiked ? Constants.shared.images.heartFilled : Constants.shared.images.heart , for: .normal)
        likeButton.tintColor = data.isLiked ? Appearance.shared.colors.red : Appearance.shared.colors.gray2
        
        likeTextButton.setTitle(getLikeText(for: data.likeCount), for: .normal)
        commentButton.setTitle(getCommentText(for: data.commentCount), for: .normal)
        
        saveButton.isSelected = data.isSaved
    }
    
    open func getLikeText(for likeCount: Int) -> String {
        if likeCount == .zero {
            return "Like"
        } else if likeCount == 1 {
            return "1 Like"
        }
        
        return "\(likeCount) Likes"
    }
    
    open func getCommentText(for commentCount: Int) -> String {
        if commentCount == .zero {
            return "Add Comment"
        } else if commentCount == 1 {
            return "1 Comment"
        }
        
        return "\(commentCount) Comments"
    }
}

// MARK: Actions
@objc
extension LMFeedPostFooterView {
    open func didTapLikeButton() {
        guard let postID else { return }
        likeButton.isSelected.toggle()
        likeButton.tintColor = likeButton.isSelected ? Appearance.shared.colors.red : Appearance.shared.colors.gray2
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
