//
//  LMFeedPostLinkCell.swift
//  LMFramework
//
//  Created by Devansh Mohata on 13/12/23.
//

import UIKit

public protocol LMFeedLinkProtocol: LMPostWidgetTableViewCellProtocol {
    func didTapLinkPreview(with url: String)
}

@IBDesignable
open class LMFeedPostLinkCell: LMPostWidgetTableViewCell {
    // MARK: Data Model
    public struct ContentModel: LMFeedPostTableCellProtocol {
        public var postID: String
        public var userUUID: String
        public var headerData: LMFeedPostHeaderView.ContentModel
        public var postText: String
        public var isShowMore: Bool
        public var topics: LMFeedTopicView.ContentModel
        public var mediaData: LMFeedLinkPreview.ContentModel
        public var footerData: LMFeedPostFooterView.ContentModel
        public var totalCommentCount: Int
        
        public init(
            postID: String,
            userUUID: String,
            headerData: LMFeedPostHeaderView.ContentModel,
            postText: String,
            topics: LMFeedTopicView.ContentModel,
            mediaData: LMFeedLinkPreview.ContentModel,
            footerData: LMFeedPostFooterView.ContentModel,
            totalCommentCount: Int,
            isShowMore: Bool = true
        ) {
            self.postID = postID
            self.userUUID = userUUID
            self.headerData = headerData
            self.postText = postText
            self.topics = topics
            self.mediaData = mediaData
            self.footerData = footerData
            self.totalCommentCount = totalCommentCount
            self.isShowMore = isShowMore
        }
    }
    
    
    // MARK: UI Elements    
    open private(set) lazy var linkPreveiw: LMFeedLinkPreview = {
        let view = LMUIComponents.shared.linkPreview.init().translatesAutoresizingMaskIntoConstraints()
        view.clipsToBounds = true
        return view
    }()
    
    // MARK: Data Variables
    open weak var delegate: LMFeedLinkProtocol?
    public var postURL: String?
    
    deinit { }
    
    open override func prepareForReuse() {
        super.prepareForReuse()
        print("Link Cell is Dequeued")
    }
    
    // MARK: setupViews
    open override func setupViews() {
        super.setupViews()
        
        contentView.addSubview(containerView)
        containerView.addSubview(contentStack)
        
        [topicFeed, postText, seeMoreButton].forEach { subView in
            contentStack.addArrangedSubview(subView)
        }
    }
    
    
    // MARK: setupLayouts
    open override func setupLayouts() {
        super.setupLayouts()
        
        contentView.pinSubView(subView: containerView)
        containerView.pinSubView(subView: contentStack)

        topicFeed.addConstraint(leading: (contentStack.leadingAnchor, 16), trailing: (contentStack.trailingAnchor, -16))
        postText.addConstraint(leading: (contentStack.leadingAnchor, 16), trailing: (contentStack.trailingAnchor, -16))
        
        linkPreveiw.setHeightConstraint(with: 1000, priority: .defaultLow)
        linkPreveiw.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
    }
    
    
    // MARK: setupAppearance
    open override func setupAppearance() {
        super.setupAppearance()
        backgroundColor = Appearance.shared.colors.clear
        contentView.backgroundColor = Appearance.shared.colors.clear
    }
    
    
    // MARK: Actions
    open override func setupActions() {
        super.setupActions()
        linkPreveiw.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapLinkPreview)))
    }
    
    @objc
    open func didTapLinkPreview() {
        guard let postURL else { return }
        delegate?.didTapLinkPreview(with: postURL)
    }
    
    
    // MARK: configure
    open func configure(with data: ContentModel, delegate: LMFeedLinkProtocol?) {
        postID = data.postID
        userUUID = data.userUUID
        
        self.delegate = delegate
        self.actionDelegate = delegate
        postURL = data.mediaData.url
        
        topicFeed.configure(with: data.topics)
        
        topicFeed.isHidden = data.topics.topics.isEmpty
        
        setupPostText(text: data.postText, showMore: data.isShowMore)
        
        linkPreveiw.configure(with: data.mediaData)
        contentStack.addArrangedSubview(linkPreveiw)
        
        NSLayoutConstraint.activate([
            linkPreveiw.leadingAnchor.constraint(equalTo: contentStack.leadingAnchor, constant: 16),
            linkPreveiw.trailingAnchor.constraint(equalTo: contentStack.trailingAnchor, constant: -16)
        ])
    }
}
