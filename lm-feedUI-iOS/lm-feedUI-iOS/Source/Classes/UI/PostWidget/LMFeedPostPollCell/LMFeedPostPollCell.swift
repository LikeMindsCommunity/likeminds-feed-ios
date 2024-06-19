//
//  LMFeedPostPollCell.swift
//  LikeMindsFeedUI
//
//  Created by Devansh Mohata on 14/06/24.
//

import UIKit

public protocol LMFeedPostPollCellProtocol: LMPostWidgetTableViewCellProtocol {
    func didTapVoteCountButton(for postID: String, pollID: String, optionID: String?)
    func didTapToVote(for postID: String, pollID: String, optionID: String)
    func didTapSubmitVote(for postID: String, pollID: String)
    func editVoteTapped(for postID: String, pollID: String)
    func didTapAddOption(for postID: String, pollID: String)
}

open class LMFeedPostPollCell: LMPostWidgetTableViewCell {
    // MARK: UI Elements
    open private(set) lazy var pollPreview: LMFeedDisplayPollView = {
        let poll = LMFeedDisplayPollView().translatesAutoresizingMaskIntoConstraints()
        return poll
    }()
    
    
    // MARK: setupViews
    open override func setupViews() {
        super.setupViews()
        
        contentView.addSubview(containerView)
        containerView.addSubview(contentStack)
        
        [topicFeed, postText].forEach { subView in
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
    }
    
    open func configure(with data: LMFeedPostContentModel, delegate: LMFeedPostPollCellProtocol?) {
        topicFeed.configure(with: data.topics)
        topicFeed.isHidden = data.topics.topics.isEmpty
        
        setupPostText(text: data.postText, showMore: data.isShowMore)
        
        if let pollData = data.pollWidget {
            pollPreview.configure(with: pollData, delegate: delegate)
            contentStack.addArrangedSubview(pollPreview)
            
            NSLayoutConstraint.activate([
                pollPreview.leadingAnchor.constraint(equalTo: contentStack.leadingAnchor, constant: 8),
                pollPreview.trailingAnchor.constraint(equalTo: contentStack.trailingAnchor, constant: -8)
            ])
        }
    }
}
