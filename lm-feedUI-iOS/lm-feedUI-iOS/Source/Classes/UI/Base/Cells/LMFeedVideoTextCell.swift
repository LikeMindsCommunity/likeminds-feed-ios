import UIKit

open class LMFeedVideoTextCell: LMPostWidgetTableViewCell {
    // MARK: - Properties
    public weak var heightDelegate: LMFeedVideoTextCellHeightDelegate?
    private var isExpanded = false
    private var expandedHeight: CGFloat = 0 // Will be calculated dynamically
    private var collapsedHeight: CGFloat = 90
    private var containerHeightConstraint: NSLayoutConstraint?
    private var contentStackHeightConstraint: NSLayoutConstraint?
    private var cellHeightConstraint: NSLayoutConstraint?
    
    // Make isExpanded accessible
    public var expandedState: Bool {
        return isExpanded
    }
    
    // MARK: - UI Components
    open private(set) lazy var postText: LMFeedTextView = {
        let textView = LMFeedTextView().translatesAutoresizingMaskIntoConstraints()
        textView.textContainer.maximumNumberOfLines = 0
        textView.isScrollEnabled = false
        textView.isUserInteractionEnabled = true
        textView.isEditable = false
        textView.isSelectable = true
        textView.font = LMFeedAppearance.shared.fonts.textFont1
        textView.textColor = .white
        textView.backgroundColor = .clear
        textView.smartInsertDeleteType = .no
        // Add shadow effect
        textView.layer.shadowColor = LMFeedAppearance.shared.colors.black.cgColor
        textView.layer.shadowOffset = CGSize(width: 0, height: 0)
        textView.layer.shadowOpacity = 0.3
        textView.layer.shadowRadius = 1.0
        return textView
    }()
    
    open private(set) lazy var seeMoreButton: LMFeedButton = {
        let button = LMFeedButton.createButton(with: "...See More", image: nil, textColor: .white, textFont: .systemFont(ofSize: 14, weight: .medium))
        button.translatesAutoresizingMaskIntoConstraints = false
        button.contentHorizontalAlignment = .left
        button.backgroundColor = .clear
        button.tintColor = .white
        // Add shadow effect
        button.titleLabel?.layer.shadowColor = LMFeedAppearance.shared.colors.black.cgColor
        button.titleLabel?.layer.shadowOffset = CGSize(width: 0, height: 0)
        button.titleLabel?.layer.shadowOpacity = 0.3
        button.titleLabel?.layer.shadowRadius = 1.0
        return button
    }()
    
    // MARK: - Setup Methods
    open override func setupViews() {
        super.setupViews()
        
        // First add containerView to contentView
        contentView.addSubview(containerView)
        
        // Make background transparent
        containerView.backgroundColor = .clear
        contentView.backgroundColor = .clear
        backgroundColor = .clear
        
        // Add contentStack to containerView
        containerView.addSubview(contentStack)
        contentStack.backgroundColor = .clear
        
        // Add arranged subviews to contentStack
        contentStack.addArrangedSubview(postText)
        contentStack.addArrangedSubview(seeMoreButton)
        
        // Configure contentStack
        contentStack.axis = .vertical
        contentStack.alignment = .fill
        contentStack.spacing = 0
    }
    
    open override func setupLayouts() {
        super.setupLayouts()
        
        // Set up containerView constraints
        containerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
        
        // Create initial height constraint for container
        containerHeightConstraint = containerView.heightAnchor.constraint(equalToConstant: collapsedHeight)
        containerHeightConstraint?.isActive = true
        
        // Set up contentStack constraints
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            contentStack.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            contentStack.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            contentStack.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -8)
        ])
        
        // Create initial height constraint for content stack
        contentStackHeightConstraint = contentStack.heightAnchor.constraint(equalToConstant: collapsedHeight - 16)
        contentStackHeightConstraint?.isActive = true
        
        // Set up cell height constraint
        cellHeightConstraint = contentView.heightAnchor.constraint(equalToConstant: collapsedHeight)
        cellHeightConstraint?.isActive = true
        
        // Set up stack view element constraints
        postText.translatesAutoresizingMaskIntoConstraints = false
        seeMoreButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            postText.leadingAnchor.constraint(equalTo: contentStack.leadingAnchor, constant: 12),
            postText.trailingAnchor.constraint(equalTo: contentStack.trailingAnchor, constant: -12),
            seeMoreButton.leadingAnchor.constraint(equalTo: contentStack.leadingAnchor, constant: 12),
            seeMoreButton.heightAnchor.constraint(equalToConstant: 5)
        ])
    }
    
    open override func setupActions() {
        super.setupActions()
        containerView.isUserInteractionEnabled = true
        postText.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tappedTextView)))
        seeMoreButton.addTarget(self, action: #selector(didTapSeeMoreButton), for: .touchUpInside)
    }
    
    // MARK: - Helper Methods
    open  func calculateExpandedHeight() -> CGFloat {
        guard let font = postText.font else { return 300 }
        
        // Use the actual width from video list screen (300 - 24 for padding)
        let availableWidth: CGFloat = 276 // 300 - 24 (12 points padding on each side)
        
        // Calculate height needed for the text
        let textHeight = postText.attributedText?.boundingRect(
            with: CGSize(width: availableWidth, height: .greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            context: nil
        ).height ?? 0
        
        // Add padding for see more button and container
        let totalHeight = textHeight + 40 // 40 points for see more button and padding
        
        // Cap the maximum height at 300 points
        return min(totalHeight, 300)
    }
    
    open  func updateSeeMoreButtonState() {
        guard let font = postText.font else { return }
        
        // Use the actual width from video list screen (300 - 24 for padding)
        let availableWidth: CGFloat = 276 // 300 - 24 (12 points padding on each side)
        
        // Calculate height for two lines of text
        let twoLineHeight = font.lineHeight * 2
        
        // Calculate actual text height needed
        let textHeight = postText.attributedText?.boundingRect(
            with: CGSize(width: availableWidth, height: .greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            context: nil
        ).height ?? 0
        
        // Show see more button only if text height exceeds two lines
        seeMoreButton.isHidden = textHeight <= twoLineHeight
    }
    
    // MARK: - Actions
    open func toggleExpansion() {
        isExpanded.toggle()
        
        // Calculate expanded height based on content
        expandedHeight = calculateExpandedHeight()
        
        UIView.animate(withDuration: 0.3) {
            if self.isExpanded {
                self.seeMoreButton.setTitle("  view less", for: .normal)
                self.postText.isScrollEnabled = true
                self.containerHeightConstraint?.constant = self.expandedHeight
                self.contentStackHeightConstraint?.constant = self.expandedHeight - 16
                self.cellHeightConstraint?.constant = self.expandedHeight
            } else {
                self.seeMoreButton.setTitle(" ...see more", for: .normal)
                self.postText.isScrollEnabled = false
                self.containerHeightConstraint?.constant = self.collapsedHeight
                self.contentStackHeightConstraint?.constant = self.collapsedHeight - 16
                self.cellHeightConstraint?.constant = self.collapsedHeight
            }
            self.layoutIfNeeded()
        }
        
        // Notify delegate about height change
        heightDelegate?.videoTextCell(self, didChangeHeight: isExpanded ? expandedHeight : collapsedHeight)
    }
    
    @objc
    open func tappedTextView(tapGesture: UITapGestureRecognizer) {
        guard let textView = tapGesture.view as? LMFeedTextView,
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
        toggleExpansion()
    }
    
    // MARK: - Configuration
    open func configure(data: LMFeedPostContentModel) {
        postText.attributedText = GetAttributedTextWithRoutes.getAttributedText(from: data.postText.trimmingCharacters(in: .whitespacesAndNewlines), andPrefix: "@")
        postText.textColor = .white
        postText.isHidden = data.postText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        
        // Reset state
        isExpanded = false
        postText.isScrollEnabled = false
        containerHeightConstraint?.constant = collapsedHeight
        contentStackHeightConstraint?.constant = collapsedHeight - 16
        cellHeightConstraint?.constant = collapsedHeight
        
        // Update seeMoreButton visibility
        updateSeeMoreButtonState()
        
        // Force layout update
        setNeedsLayout()
        layoutIfNeeded()
    }
    
    // MARK: - Reuse
    open override func prepareForReuse() {
        super.prepareForReuse()
        isExpanded = false
        postText.isScrollEnabled = false
        containerHeightConstraint?.constant = collapsedHeight
        contentStackHeightConstraint?.constant = collapsedHeight - 16
        cellHeightConstraint?.constant = collapsedHeight
        seeMoreButton.setTitle("...See More", for: .normal)
    }
    
    // MARK: - Layout
    open override func layoutSubviews() {
        super.layoutSubviews()
        updateSeeMoreButtonState()
    }
}

// MARK: - Delegate Protocol
public protocol LMFeedVideoTextCellHeightDelegate: AnyObject {
    func videoTextCell(_ cell: LMFeedVideoTextCell, didChangeHeight height: CGFloat)
}
