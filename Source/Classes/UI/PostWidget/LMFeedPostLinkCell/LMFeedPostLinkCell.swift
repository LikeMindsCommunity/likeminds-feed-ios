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
        let headerData: LMFeedPostHeaderView.ViewModel
        let postText: String
        let topics: LMFeedTopicView.ViewModel
        let mediaData: LMFeedPostLinkCellView.ViewModel
        var footerData: LMFeedPostFooterView.ViewModel
        
        public init(headerData: LMFeedPostHeaderView.ViewModel, postText: String?, topics: LMFeedTopicView.ViewModel, mediaData: LMFeedPostLinkCellView.ViewModel, footerData: LMFeedPostFooterView.ViewModel) {
            self.headerData = headerData
            self.postText = postText ?? ""
            self.topics = topics
            self.mediaData = mediaData
            self.footerData = footerData
        }
    }
    
    
    // MARK: UI Elements
    open private(set) lazy var contentStack: LMStackView = {
        let stack = LMStackView().translatesAutoresizingMaskIntoConstraints()
        stack.axis = .vertical
        stack.alignment = .center
        stack.distribution = .fill
        stack.spacing = 8
        return stack
    }()
    
    open private(set) lazy var linkPreveiw: LMFeedPostLinkCellView = {
        let view = LMFeedPostLinkCellView().translatesAutoresizingMaskIntoConstraints()
        view.clipsToBounds = true
        return view
    }()
    
    open private(set) lazy var topicFeed: LMFeedTopicView = {
        let view = LMFeedTopicView().translatesAutoresizingMaskIntoConstraints()
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
        
        [topicFeed, postText, linkPreveiw].forEach { subView in
            contentStack.addArrangedSubview(subView)
        }
    }
    
    
    // MARK: setupLayouts
    open override func setupLayouts() {
        super.setupLayouts()
        
        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            
            headerView.topAnchor.constraint(equalTo: containerView.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            headerView.bottomAnchor.constraint(equalTo: contentStack.topAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 64),
            
            contentStack.leadingAnchor.constraint(equalTo: headerView.leadingAnchor),
            contentStack.trailingAnchor.constraint(equalTo: headerView.trailingAnchor),
            
            linkPreveiw.leadingAnchor.constraint(equalTo: contentStack.leadingAnchor),
            linkPreveiw.trailingAnchor.constraint(equalTo: contentStack.trailingAnchor),
            
            topicFeed.leadingAnchor.constraint(equalTo: contentStack.leadingAnchor),
            topicFeed.trailingAnchor.constraint(equalTo: contentStack.trailingAnchor),
            
            postText.leadingAnchor.constraint(equalTo: contentStack.leadingAnchor, constant: 16),
            postText.trailingAnchor.constraint(equalTo: contentStack.trailingAnchor, constant: -16),
            
            footerView.topAnchor.constraint(equalTo: contentStack.bottomAnchor, constant: 0),
            footerView.leadingAnchor.constraint(equalTo: contentStack.leadingAnchor, constant: 16),
            footerView.trailingAnchor.constraint(equalTo: contentStack.trailingAnchor, constant: -16),
            footerView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 0),
            footerView.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        let topicHeight = NSLayoutConstraint(item: topicFeed, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 200)
        topicHeight.priority = .defaultLow
        topicHeight.isActive = true
        
        let postTextHeight = NSLayoutConstraint(item: postText, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 10)
        postTextHeight.priority = .defaultLow
        postTextHeight.isActive = true
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
    open func configure(with data: ViewModel, delegate: (LMChatLinkProtocol & LMFeedTableCellToViewControllerProtocol)) {
        self.delegate = delegate
        self.actionDelegate = delegate
        postURL = data.mediaData.url
        
        headerView.configure(with: data.headerData)
        
        topicFeed.configure(with: data.topics)
        topicFeed.isHidden = data.topics.topics.isEmpty
        
        postText.attributedText = GetAttributedTextWithRoutes.getAttributedText(from: data.postText)
        postText.isHidden = data.postText.isEmpty
        linkPreveiw.configure(with: data.mediaData)
        
        footerView.configure(with: data.footerData)
    }
}
