//
//  LMFeedPostLinkCell.swift
//  LMFramework
//
//  Created by Devansh Mohata on 13/12/23.
//

import UIKit

public protocol LMChatLinkProtocol: AnyObject {
    func didTapLinkPreview(with url: String)
}

@IBDesignable
open class LMFeedPostLinkCell: LMPostWidgetTableViewCell {
    // MARK: Data Model
    public struct ViewModel: LMFeedPostTableCellProtocol {
        public var postID: String
        public var userUUID: String
        public var headerData: LMFeedPostHeaderView.ViewModel
        public var postText: String
        public var topics: LMFeedTopicView.ViewModel
        public var mediaData: LMFeedLinkPreview.ViewModel
        public var footerData: LMFeedPostFooterView.ViewModel
        
        public init(
            postID: String,
            userUUID: String,
            headerData: LMFeedPostHeaderView.ViewModel,
            postText: String,
            topics: LMFeedTopicView.ViewModel,
            mediaData: LMFeedLinkPreview.ViewModel,
            footerData: LMFeedPostFooterView.ViewModel
        ) {
            self.postID = postID
            self.userUUID = userUUID
            self.headerData = headerData
            self.postText = postText
            self.topics = topics
            self.mediaData = mediaData
            self.footerData = footerData
        }
    }
    
    
    // MARK: UI Elements    
    open private(set) lazy var linkPreveiw: LMFeedLinkPreview = {
        let view = LMUIComponents.shared.linkPreview.init().translatesAutoresizingMaskIntoConstraints()
        view.clipsToBounds = true
        return view
    }()
    
    // MARK: Data Variables
    open weak var delegate: LMChatLinkProtocol?
    public var postURL: String?
    
    
    // MARK: setupViews
    open override func setupViews() {
        super.setupViews()
        
        contentView.addSubview(containerView)
        
        [headerView, contentStack, footerView].forEach { subView in
            containerView.addSubview(subView)
        }
        
        [topicFeed, postText].forEach { subView in
            contentStack.addArrangedSubview(subView)
        }
    }
    
    
    // MARK: setupLayouts
    open override func setupLayouts() {
        super.setupLayouts()
        
        contentView.pinSubView(subView: containerView, padding: .init(top: .zero, left: .zero, bottom: -16, right: .zero))
        
        headerView.setHeightConstraint(with: Constants.shared.number.postHeaderSize)
        headerView.addConstraint(
            top: (containerView.topAnchor, 0),
            bottom: (contentStack.topAnchor, 0),
            leading: (containerView.leadingAnchor, 0),
            trailing: (containerView.trailingAnchor, 0)
        )
        
        contentStack.addConstraint(leading: (headerView.leadingAnchor, 0), trailing: (headerView.trailingAnchor, 0))
        topicFeed.addConstraint(leading: (contentStack.leadingAnchor, 16), trailing: (contentStack.trailingAnchor, -16))
        postText.addConstraint(leading: (contentStack.leadingAnchor, 16), trailing: (contentStack.trailingAnchor, -16))
        
        footerView.setHeightConstraint(with: Constants.shared.number.postFooterSize)
        footerView.addConstraint(
            top: (contentStack.bottomAnchor, 0),
            bottom: (containerView.bottomAnchor, 0),
            leading: (contentStack.leadingAnchor, 16),
            trailing: (contentStack.trailingAnchor, -16)
        )
        
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
    open func configure(with data: ViewModel, delegate: (LMChatLinkProtocol & LMFeedTableCellToViewControllerProtocol)?) {
        postID = data.postID
        userUUID = data.userUUID
        
        self.delegate = delegate
        self.actionDelegate = delegate
        postURL = data.mediaData.url
        
        headerView.configure(with: data.headerData)
        
        topicFeed.configure(with: data.topics)
        topicFeed.isHidden = data.topics.topics.isEmpty
        
        postText.attributedText = GetAttributedTextWithRoutes.getAttributedText(from: data.postText)
        postText.isHidden = data.postText.isEmpty
        
        linkPreveiw.configure(with: data.mediaData)
        contentStack.addArrangedSubview(linkPreveiw)
        
        NSLayoutConstraint.activate([
            linkPreveiw.leadingAnchor.constraint(equalTo: contentStack.leadingAnchor, constant: 16),
            linkPreveiw.trailingAnchor.constraint(equalTo: contentStack.trailingAnchor, constant: -16)
        ])
        
        footerView.configure(with: data.footerData)
    }
}
