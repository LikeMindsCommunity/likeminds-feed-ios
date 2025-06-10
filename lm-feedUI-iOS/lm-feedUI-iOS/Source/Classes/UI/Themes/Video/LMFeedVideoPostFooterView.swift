    import UIKit


public protocol LMFeedVideoFooterViewProtocol: LMFeedPostFooterViewProtocol {
    func didTapFooterMenuButton(for postID: String)
}

open class LMFeedVideoPostFooterView: LMFeedBasePostFooterView {
    // MARK: UI Elements
    private weak var _videoDelegate: LMFeedVideoFooterViewProtocol?
    
    public var videoDelegate: LMFeedVideoFooterViewProtocol? {
        get { _videoDelegate }
        set { _videoDelegate = newValue }
    }
    
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
        commentContainerStack.addArrangedSubview(commentTextButton)
        
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
        moreButton.addTarget(self, action: #selector(didTapFooterMenuButton), for: .touchUpInside)
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
        
        // Set custom icons for buttons
        likeButton.setImage(LMFeedConstants.shared.images.heartVideoIcon, for: .normal)
        likeButton.setImage(LMFeedConstants.shared.images.heartVideoFilledIcon, for: .selected)
        
        commentButton.setImage(LMFeedConstants.shared.images.commentVideoIcon, for: .normal)
        
        shareButton.setImage(LMFeedConstants.shared.images.shareVideoIcon, for: .normal)
        
        likeTextButton.setTitleColor(LMFeedAppearance.shared.colors.white, for: .normal)
        commentButton.setTitleColor(LMFeedAppearance.shared.colors.white, for: .normal)
        commentTextButton.setTitleColor(LMFeedAppearance.shared.colors.white, for: .normal)
    }
    
    // MARK: Helper Methods
    open override func updateLikeText(for likeCount: Int) {
        let likeCountText = likeCount == 0 ? "0" : formattedText(for: likeCount)
        likeTextButton.setTitle(likeCountText, for: .normal)
    }
    
    open override func updateCommentText(for commentCount: Int) {
        commentButton.setTitle("", for: .normal)
        let commentCountText = commentCount == 0 ? "0" : formattedText(for: commentCount)
        commentTextButton.setTitle(commentCountText, for: .normal)
    }
    
    open override func configure(with data: ContentModel, topResponse: LMFeedCommentContentModel?, postID: String, delegate: LMFeedPostFooterViewProtocol, orientation: LMFeedPostFooterOrientation = .vertical) {
        super.configure(with: data, topResponse: topResponse, postID: postID, delegate: delegate, orientation: orientation)
        self._videoDelegate = delegate as? LMFeedVideoFooterViewProtocol
    }
    
    @objc open func didTapFooterMenuButton() {
        guard let postID = postID else { return }
        _videoDelegate?.didTapFooterMenuButton(for: postID)
    }
}
