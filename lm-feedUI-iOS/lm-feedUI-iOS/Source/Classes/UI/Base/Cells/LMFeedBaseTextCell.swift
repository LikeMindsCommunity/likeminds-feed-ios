//
//  File.swift
//  LikeMindsFeedUI
//
//  Created by Anurag Tyagi on 12/09/24.
//

import Foundation

open class LMFeedPostBaseTextCell: LMPostWidgetTableViewCell {
    open private(set) lazy var questionTitle: LMLabel = {
        let label = LMLabel().translatesAutoresizingMaskIntoConstraints()
        label.font = LMFeedAppearance.shared.fonts.headingFont1
        label.textColor = LMFeedAppearance.shared.colors.gray51
        label.numberOfLines = 0
        return label
    }()
    
    open private(set) lazy var postText: LMTextView = {
        let textView = LMTextView().translatesAutoresizingMaskIntoConstraints()
        textView.textContainer.maximumNumberOfLines = 0
        textView.isScrollEnabled = false
        textView.isUserInteractionEnabled = true
        textView.isEditable = false
        textView.isSelectable = false
        textView.font = LMFeedAppearance.shared.fonts.textFont1
        textView.textColor = LMFeedAppearance.shared.colors.textColor
        textView.backgroundColor = .clear
        textView.smartInsertDeleteType = .no
        return textView
    }()
    
    open private(set) lazy var seeMoreButton: LMButton = {
        let button = LMButton.createButton(with: "See More", image: nil, textColor: LMFeedAppearance.shared.colors.textColor, textFont: LMFeedAppearance.shared.fonts.textFont1)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    deinit { }
    
    // MARK: setupLayouts
    open override func setupLayouts() {
        super.setupLayouts()
        
        questionTitle.setHeightConstraint(with: 10, priority: .defaultLow)
        postText.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        postText.setHeightConstraint(with: 10, priority: .defaultLow)
        seeMoreButton.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
    }
    
    open override func prepareForReuse() {
        super.prepareForReuse()
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
    open func didTapSeeMoreButton() {
        guard let postID else { return }
        actionDelegate?.didTapSeeMoreButton(for: postID)
    }
    
    open func configure(data: LMFeedPostContentModel) {
        questionTitle.text = data.postQuestion
        
        postText.attributedText = GetAttributedTextWithRoutes.getAttributedText(from: data.postText.trimmingCharacters(in: .whitespacesAndNewlines), andPrefix: "@")
        postText.isHidden =  data.postText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        
        seeMoreButton.isHidden = true // !(postText.numberOfLines > 4 && showMore)
        postText.textContainer.maximumNumberOfLines = 0 // postText.numberOfLines > 4 && !showMore ? .zero : 4
    }
}
