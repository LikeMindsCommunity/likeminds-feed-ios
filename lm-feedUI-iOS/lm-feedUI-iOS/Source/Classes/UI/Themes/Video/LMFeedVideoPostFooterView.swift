    import UIKit

open class LMFeedVideoPostFooterView: LMFeedBasePostFooterView {
    // MARK: UI Elements
    open private(set) lazy var footerContainerView: LMFeedStackView = {
        let stack = LMFeedStackView().translatesAutoresizingMaskIntoConstraints()
        stack.axis = .vertical
        stack.alignment = .fill
        stack.distribution = .fill
        stack.spacing = 8
        return stack
    }()
    
    open private(set) lazy var likeContainerStack: LMFeedStackView = {
        let stack = LMFeedStackView().translatesAutoresizingMaskIntoConstraints()
        stack.axis = .vertical
        stack.alignment = .center
        stack.distribution = .fill
        stack.spacing = 4
        return stack
    }()
    
    open private(set) lazy var commentContainerStack: LMFeedStackView = {
        let stack = LMFeedStackView().translatesAutoresizingMaskIntoConstraints()
        stack.axis = .vertical
        stack.alignment = .center
        stack.distribution = .fill
        stack.spacing = 4
        return stack
    }()
    
    open private(set) lazy var shareContainerStack: LMFeedStackView = {
        let stack = LMFeedStackView().translatesAutoresizingMaskIntoConstraints()
        stack.axis = .horizontal
        stack.alignment = .center
        stack.distribution = .fill
        stack.spacing = 4
        return stack
    }()
    
    open private(set) lazy var moreButton: LMFeedButton = {
        let button = LMFeedButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "ellipsis"), for: .normal)
        button.tintColor = LMFeedAppearance.shared.colors.gray2
        button.setPreferredSymbolConfiguration(.init(font: LMFeedAppearance.shared.fonts.buttonFont1, scale: .large), forImageIn: .normal)
        button.contentHorizontalAlignment = .left
        return button
    }()
    
    // MARK: setupViews
    open override func setupViews() {
        contentView.addSubview(containerView)
        containerView.addSubview(footerContainerView)
        
        footerContainerView.addArrangedSubview(topResponseView)
        footerContainerView.addArrangedSubview(actionStackView)
        
        // Setup like container
        likeContainerStack.addArrangedSubview(likeButton)
        likeContainerStack.addArrangedSubview(likeTextButton)
        
        // Setup comment container
        commentContainerStack.addArrangedSubview(commentButton)
        
        // Setup share container
        shareContainerStack.addArrangedSubview(shareButton)
        
        // Add all containers to action stack
        [likeContainerStack, commentContainerStack, shareContainerStack, moreButton].forEach { actionStackView.addArrangedSubview($0) }
    }
    
    // MARK: setupLayouts
    open override func setupLayouts() {
        containerView.addConstraint(top: (contentView.topAnchor, 0),
                                  leading: (contentView.leadingAnchor, 0),
                                  trailing: (contentView.trailingAnchor, 0))
        
        containerView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -8).isActive = true
        
        containerView.pinSubView(subView: footerContainerView, padding: .init(top: 8, left: 16, bottom: -8, right: -16))
        
        [likeButton, commentButton, shareButton, moreButton].forEach { btn in
            btn.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        }
    }
    
    // MARK: setupActions
    open override func setupActions() {
        super.setupActions()
        likeText = "Like"
//        moreButton.addTarget(self, action: #selector(didTapMoreButton), for: .touchUpInside)
    }
    
    // MARK: setupAppearance
    open override func setupAppearance() {
        super.setupAppearance()
        containerView.backgroundColor = .clear
        containerBackgroundColor = .clear
        contentView.backgroundColor = .clear
        backgroundView = nil
        
        // Customize button appearances
        [likeButton, commentButton, shareButton, moreButton].forEach { button in
            button.tintColor = LMFeedAppearance.shared.colors.white
        }
        likeTextButton.setTitleColor(LMFeedAppearance.shared.colors.white, for: .normal)
        commentButton.setTitleColor(LMFeedAppearance.shared.colors.white, for: .normal)
    }
    
    // MARK: Helper Methods
    open override func updateLikeText(for likeCount: Int) {
//        likeTextButton.isHidden = likeCount == .zero
        likeTextButton.setTitle(formattedText(for: likeCount), for: .normal)
    }
    
    open override func updateCommentText(for commentCount: Int) {
        commentButton.setTitle(formattedText(for: commentCount), for: .normal)
    }
    
    open override func configure(with data: ContentModel, topResponse: LMFeedCommentContentModel?, postID: String, delegate: LMFeedPostFooterViewProtocol, orientation: LMFeedPostFooterOrientation = .vertical) {
        super.configure(with: data, topResponse: topResponse, postID: postID, delegate: delegate, orientation: orientation)
    }
    
    // MARK: Action Methods
//    @objc private func didTapMoreButton() {
//        guard let postID = postID else { return }
//        delegate?.didTapPostMenuButton(for: postID)
//    }
} 
