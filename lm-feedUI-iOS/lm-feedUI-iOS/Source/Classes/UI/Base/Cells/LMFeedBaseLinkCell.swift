//
//  LMFeedBaseLinkCell.swift
//  LikeMindsFeedUI
//
//  Created by Devansh Mohata on 23/07/24.
//

import UIKit

open class LMFeedBaseLinkCell: LMPostWidgetTableViewCell {
    
    open private(set) lazy var postText: LMFeedPostBaseTextCell = {
        let postText = LMUIComponents.shared.textCell.init()
        postText.translatesAutoresizingMaskIntoConstraints = false
        return postText
    }()
    
    // MARK: UI Elements
    open private(set) lazy var linkPreveiw: LMFeedLinkPreview = {
        let view = LMUIComponents.shared.linkPreview.init().translatesAutoresizingMaskIntoConstraints()
        view.clipsToBounds = true
        return view
    }()
    
    // MARK: Data Variables
    open weak var delegate: LMFeedLinkProtocol?
    public var postURL: String?
    
    
    // MARK: setupAppearance
    open override func setupAppearance() {
        super.setupAppearance()
        backgroundColor = LMFeedAppearance.shared.colors.clear
        contentView.backgroundColor = LMFeedAppearance.shared.colors.clear
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
    open func configure(with data: LMFeedPostContentModel, delegate: LMFeedLinkProtocol?) {
        postID = data.postID
        userUUID = data.userUUID
        
        self.delegate = delegate
        self.actionDelegate = delegate
        postURL = data.linkPreview?.url
        
        topicFeed.configure(with: data.topics)
        
        topicFeed.isHidden = data.topics.topics.isEmpty
        
        postText.configure(text: data.postText, showMore: data.isShowMore)
        
        if let linkPreview = data.linkPreview {
            linkPreveiw.configure(with: linkPreview)
            contentStack.addArrangedSubview(linkPreveiw)
        }
        
        NSLayoutConstraint.activate([
            linkPreveiw.leadingAnchor.constraint(equalTo: contentStack.leadingAnchor, constant: 16),
            linkPreveiw.trailingAnchor.constraint(equalTo: contentStack.trailingAnchor, constant: -16)
        ])
    }
}
