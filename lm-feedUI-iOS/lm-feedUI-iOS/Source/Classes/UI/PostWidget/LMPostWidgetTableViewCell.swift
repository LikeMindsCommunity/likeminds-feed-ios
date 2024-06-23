//
//  LMPostWidgetTableViewCell.swift
//  LMFramework
//
//  Created by Devansh Mohata on 17/12/23.
//

import UIKit

// MARK: LMFeedPostTableCellProtocol
public enum LMFeedPostType {
    case text,
         link,
         media,
         documents,
         poll,
         other
}

public protocol LMFeedPostTableCellProtocol {
    var postType: LMFeedPostType { get }
    var postID: String { get }
    var userUUID: String { get }
    var headerData: LMFeedPostHeaderView.ContentModel { get set }
    var postText: String { get }
    var isShowMore: Bool { get set }
    var topics: LMFeedTopicView.ContentModel { get }
    var footerData: LMFeedPostFooterView.ContentModel { get set }
    var totalCommentCount: Int { get set }
}

public struct LMFeedPostContentModel: LMFeedPostTableCellProtocol {
    public var postType: LMFeedPostType
    public var postID: String
    public var userUUID: String
    public var headerData: LMFeedPostHeaderView.ContentModel
    public var postText: String
    public var isShowMore: Bool
    public var topics: LMFeedTopicView.ContentModel
    public var footerData: LMFeedPostFooterView.ContentModel
    public var totalCommentCount: Int
    public var documents: [LMFeedDocumentPreview.ContentModel]
    public var isShowMoreDocuments: Bool
    public var linkPreview: LMFeedLinkPreview.ContentModel?
    public var mediaData: [LMFeedMediaProtocol]
    public var pollWidget: LMFeedDisplayPollView.ContentModel?
    
    public init(
        postType: LMFeedPostType,
        postID: String,
        userUUID: String,
        headerData: LMFeedPostHeaderView.ContentModel,
        postText: String,
        topics: LMFeedTopicView.ContentModel,
        footerData: LMFeedPostFooterView.ContentModel,
        totalCommentCount: Int,
        documents: [LMFeedDocumentPreview.ContentModel],
        linkPreview: LMFeedLinkPreview.ContentModel?,
        mediaData: [LMFeedMediaProtocol],
        pollWidget: LMFeedDisplayPollView.ContentModel?,
        isShowMore: Bool = true,
        isShowMoreDocuments: Bool = false
    ) {
        self.postType = postType
        self.postID = postID
        self.userUUID = userUUID
        self.headerData = headerData
        self.postText = postText
        self.isShowMore = isShowMore
        self.topics = topics
        self.footerData = footerData
        self.totalCommentCount = totalCommentCount
        self.documents = documents
        self.isShowMoreDocuments = isShowMoreDocuments
        self.linkPreview = linkPreview
        self.mediaData = mediaData
        self.pollWidget = pollWidget
    }
}

// MARK: LMPostWidgetTableViewCellProtocol
public protocol LMPostWidgetTableViewCellProtocol: AnyObject {
    func didTapPost(postID: String)
    func didTapURL(url: URL)
    func didTapRoute(route: String)
    func didTapSeeMoreButton(for postID: String)
}

public extension LMPostWidgetTableViewCellProtocol {
    func didTapPost(postID: String) { }
    func didTapSeeMoreButton(for postID: String) { }
}


@IBDesignable
open class LMPostWidgetTableViewCell: LMTableViewCell {
    // MARK: UI Elements
    open private(set) lazy var contentStack: LMStackView = {
        let stack = LMStackView().translatesAutoresizingMaskIntoConstraints()
        stack.axis = .vertical
        stack.alignment = .center
        stack.distribution = .fill
        stack.spacing = 8
        return stack
    }()
    
    open private(set) lazy var topicFeed: LMFeedTopicView = {
        let view = LMFeedTopicView().translatesAutoresizingMaskIntoConstraints()
        return view
    }()
    
    open private(set) lazy var postText: LMTextView = {
        let textView = LMTextView().translatesAutoresizingMaskIntoConstraints()
        textView.textContainer.maximumNumberOfLines = 0
        textView.isScrollEnabled = false
        textView.isUserInteractionEnabled = true
        textView.isEditable = false
        textView.isSelectable = false
        textView.font = Appearance.shared.fonts.textFont1
        textView.textColor = Appearance.shared.colors.textColor
        textView.backgroundColor = .clear
        textView.smartInsertDeleteType = .no
        return textView
    }()
    
    open private(set) lazy var seeMoreButton: LMButton = {
        let button = LMButton.createButton(with: "See More", image: nil, textColor: Appearance.shared.colors.textColor, textFont: Appearance.shared.fonts.textFont1)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    
    // MARK: Data Variables
    public weak var actionDelegate: LMPostWidgetTableViewCellProtocol?
    public var userUUID: String?
    public var postID: String?
    
    deinit { }
    
    // MARK: setupLayouts
    open override func setupLayouts() {
        super.setupLayouts()
        
        topicFeed.setContentHuggingPriority(.defaultHigh, for: .vertical)
        topicFeed.setHeightConstraint(with: 10, priority: .defaultLow)
        postText.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        postText.setHeightConstraint(with: 10, priority: .defaultLow)
        seeMoreButton.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
    }
    
    open override func prepareForReuse() {
        super.prepareForReuse()
        print(#function)
    }
    
    // MARK: setupActions
    open override func setupActions() {
        super.setupActions()
        containerView.isUserInteractionEnabled = true
        postText.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tappedTextView)))
        containerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapPost)))
        seeMoreButton.addTarget(self, action: #selector(didTapSeeMoreButton), for: .touchUpInside)
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
        } else if let postID {
            actionDelegate?.didTapPost(postID: postID)
        }
    }
    
    open func didTapURL(url: URL) {
        actionDelegate?.didTapURL(url: url)
    }
    
    open func didTapHashTag(hashtag: String) { }
    
    open func didTapRoute(route: String) { 
        actionDelegate?.didTapRoute(route: route)
    }
    
    @objc
    open func didTapPost() {
        guard let postID else { return }
        actionDelegate?.didTapPost(postID: postID)
    }
    
    @objc
    open func didTapSeeMoreButton() {
        guard let postID else { return }
        actionDelegate?.didTapSeeMoreButton(for: postID)
    }
    
    open func setupPostText(text: String, showMore: Bool) {
        postText.attributedText = GetAttributedTextWithRoutes.getAttributedText(from: text.trimmingCharacters(in: .whitespacesAndNewlines), andPrefix: "@")
        postText.isHidden = text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        
        seeMoreButton.isHidden = true // !(postText.numberOfLines > 4 && showMore)
        postText.textContainer.maximumNumberOfLines = 0 // postText.numberOfLines > 4 && !showMore ? .zero : 4
    }
}
