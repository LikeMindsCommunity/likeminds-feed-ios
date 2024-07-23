//
//  LMFeedPostQnAFooterView.swift
//  LikeMindsFeedUI
//
//  Created by Devansh Mohata on 21/07/24.
//

import UIKit

open class LMFeedPostQnAFooterView: LMFeedPostBaseFooterView {
    open private(set) lazy var containerStackView: LMStackView = {
        let stack = LMStackView().translatesAutoresizingMaskIntoConstraints()
        stack.axis = .vertical
        stack.alignment = .fill
        stack.distribution = .fill
        stack.spacing = 8
        return stack
    }()
    
    open private(set) lazy var topResponseView: LMFeedTopResponseView = {
        let view = LMFeedTopResponseView().translatesAutoresizingMaskIntoConstraints()
        return view
    }()
    
    open override func prepareForReuse() {
        super.prepareForReuse()
        
        if containerStackView.arrangedSubviews.contains(topResponseView) {
            containerStackView.removeArrangedSubview(topResponseView)
            topResponseView.removeFromSuperview()
        }
    }
    
    // MARK: setupViews
    open override func setupViews() {
        super.setupViews()
        
        contentView.addSubview(containerView)
        containerView.addSubview(containerStackView)
        containerStackView.addArrangedSubview(topResponseView)
        containerStackView.addSubview(actionStackView)
        [likeButton, likeTextButton, commentButton, spacer, saveButton, shareButton].forEach { actionStackView.addArrangedSubview($0) }
    }
    
    // MARK: setupLayouts
    open override func setupLayouts() {
        super.setupLayouts()
        
        contentView.pinSubView(subView: containerView, padding: .init(top: 0, left: 0, bottom: -8, right: 0))
        containerView.pinSubView(subView: containerStackView, padding: .init(top: 8, left: 8, bottom: -8, right: -8))
        
        [likeButton, likeTextButton, commentButton, saveButton, shareButton].forEach { btn in
            btn.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        }
    }
    
    open func configure(with data: ContentModel, postID: String, delegate: LMFeedPostFooterViewProtocol, topComment: LMFeedCommentContentModel?) {
        configure(with: data, postID: postID, delegate: delegate)
        
        if let topComment {
            topResponseView.isHidden = false
            topResponseView.configure(with: topComment)
        } else {
            topResponseView.isHidden = true
        }
    }
}
