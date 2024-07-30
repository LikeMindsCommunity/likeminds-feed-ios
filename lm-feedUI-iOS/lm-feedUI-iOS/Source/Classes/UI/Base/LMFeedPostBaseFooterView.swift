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


open class LMFeedBasePostFooterView: LMTableViewHeaderFooterView {
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
    
    
    // MARK: Common UI Elements
    open private(set) lazy var containerView: LMView = {
        let view = LMView().translatesAutoresizingMaskIntoConstraints()
        return view
    }()
    
    open private(set) lazy var actionStackView: LMStackView = {
        let stack = LMStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.spacing = 8
        stack.alignment = .center
        stack.distribution = .fill
        return stack
    }()
    
    open private(set) lazy var likeButton: LMButton = {
        let button = LMButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(LMFeedConstants.shared.images.heart, for: .normal)
        button.setImage(LMFeedConstants.shared.images.heartFilled, for: .selected)
        button.tintColor = LMFeedAppearance.shared.colors.gray102
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
    
    // MARK: Common Data Variables
    public weak var delegate: LMFeedPostFooterViewProtocol?
    public var postID: String?
    public var likeCount: Int = 0
    
    // Private stored properties
    private var _likeText: String = "Like"
    private var _commentText: String = "Comment"
    
    // Public computed properties that can be overridden
    open var likeText: String {
        get {
            _likeText
        } set { 
            _likeText = newValue
        }
    }
    
    open var commentText: String {
        get {
            _commentText
        } set {
            _commentText = newValue
        }
    }
    
    open var likeButtonTintColor: UIColor {
        likeButton.isSelected ? LMFeedAppearance.shared.colors.red : LMFeedAppearance.shared.colors.gray102
    }
    
    // MARK: View Hierarchy
    open override func setupViews() {
        super.setupViews()
        
        contentView.addSubview(containerView)
        containerView.addSubview(actionStackView)
    }
    
    // MARK: Constraints
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
        
        containerView.backgroundColor = LMFeedAppearance.shared.colors.white
    }
    
    // MARK: Configure
    open func configure(with data: ContentModel, postID: String, delegate: LMFeedPostFooterViewProtocol) {
        self.likeText = data.likeText
        self.commentText = data.commentText
        self.postID = postID
        self.likeCount = data.likeCount
        self.delegate = delegate
        
        likeButton.isSelected = data.isLiked
        saveButton.isSelected = data.isSaved
        
        updateLikeText(for: data.likeCount)
        updateCommentText(for: data.commentCount)
    }
    
    // MARK: Helper Methods
    open func updateLikeText(for likeCount: Int) {
        // To be implemented by subclasses
    }
    
    open func updateCommentText(for commentCount: Int) {
        // To be implemented by subclasses
    }
    
    open func formattedText(for count: Int) -> String {
        if count == 0 {
            return ""
        } else if count <= 999 {
            return "\(count)"
        } else {
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            formatter.maximumFractionDigits = 0
            let formattedNumber = formatter.string(from: NSNumber(value: count / 1000)) ?? ""
            return "\(formattedNumber)k"
        }
    }
    
    // MARK: Action Methods
    @objc open func didTapLikeButton() {
        guard let postID = postID else { return }
        likeButton.isSelected.toggle()
        likeButton.tintColor = likeButtonTintColor
        likeCount += likeButton.isSelected ? 1 : -1
        updateLikeText(for: likeCount)
        delegate?.didTapLikeButton(for: postID)
    }
    
    @objc open func didTapLikeTextButton() {
        guard let postID = postID else { return }
        delegate?.didTapLikeTextButton(for: postID)
    }
    
    @objc open func didTapCommentButton() {
        guard let postID = postID else { return }
        delegate?.didTapCommentButton(for: postID)
    }
    
    @objc open func didTapSaveButton() {
        guard let postID = postID else { return }
        saveButton.isSelected.toggle()
        delegate?.didTapSaveButton(for: postID)
    }
    
    @objc open func didTapShareButton() {
        guard let postID = postID else { return }
        delegate?.didTapShareButton(for: postID)
    }
    
    @objc open func didTapPost() {
        guard let postID = postID else { return }
        delegate?.didTapPost(postID: postID)
    }
}
