import UIKit

open class LMFeedVideoTextCell: LMFeedPostBaseTextCell {
    // MARK: - Properties
    private var isExpanded = false
    private let initialMaxLines = 2
    
    // MARK: - Setup Methods
    open override func setupViews() {
        super.setupViews()
        
        // First add containerView to contentView
        contentView.addSubview(containerView)
        
        // Update seeMoreButton appearance
        seeMoreButton.setTitle("...See More", for: .normal)
        seeMoreButton.setTitleColor(.white, for: .normal)
        seeMoreButton.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        seeMoreButton.contentHorizontalAlignment = .left // Align button text to left
        
        // Set text color to white for better visibility
        postText.textColor = .white
        
        // Configure postText
        postText.isEditable = false
        postText.isSelectable = true
        postText.isScrollEnabled = false // Initially disable scrolling
        postText.showsVerticalScrollIndicator = false // Hide scroll indicator
        
        // Add contentStack to containerView
        containerView.addSubview(contentStack)
        
        // Add arranged subviews to contentStack
        contentStack.addArrangedSubview(questionTitle)
        contentStack.addArrangedSubview(postText)
        contentStack.addArrangedSubview(seeMoreButton)
        
        // Configure contentStack
        contentStack.axis = .vertical
        contentStack.spacing = 0 // Remove spacing between elements
        contentStack.alignment = .fill// Align all elements to the left
    }
    
    open override func setupLayouts() {
        super.setupLayouts()
        
        // Set up containerView constraints
        containerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
        
        // Set up contentStack constraints
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            contentStack.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 8),
            contentStack.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            contentStack.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            contentStack.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -8)
        ])
        
        // Set up stack view element constraints
        questionTitle.translatesAutoresizingMaskIntoConstraints = false
        postText.translatesAutoresizingMaskIntoConstraints = false
        seeMoreButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            questionTitle.leadingAnchor.constraint(equalTo: contentStack.leadingAnchor, constant: 16),
            questionTitle.trailingAnchor.constraint(equalTo: contentStack.trailingAnchor, constant: -16),
            
            postText.leadingAnchor.constraint(equalTo: contentStack.leadingAnchor, constant: 12),
            postText.trailingAnchor.constraint(equalTo: contentStack.trailingAnchor, constant: -12),
            postText.heightAnchor.constraint(equalToConstant: 60), // Initial height
            
            seeMoreButton.leadingAnchor.constraint(equalTo: contentStack.leadingAnchor, constant: 12), // Match postText leading
            seeMoreButton.topAnchor.constraint(equalTo: postText.bottomAnchor, constant: 0)
        ])
    }
    
    // MARK: - Configuration
    open override func configure(data: LMFeedPostContentModel) {
        super.configure(data: data)
        
        // Reset state
        isExpanded = false
        postText.isScrollEnabled = false // Disable scrolling initially
        
        // Configure text view
        postText.textContainer.maximumNumberOfLines = initialMaxLines
        
        // Update seeMoreButton visibility
        updateSeeMoreButtonState()
        
        // Force layout update
        setNeedsLayout()
        layoutIfNeeded()
    }
    
    // MARK: - Actions
    open override func didTapSeeMoreButton() {
        isExpanded.toggle()
        
        UIView.animate(withDuration: 0.3) {
            if self.isExpanded {
                self.seeMoreButton.isHidden = true
                self.postText.textContainer.maximumNumberOfLines = 0
                self.postText.heightAnchor.constraint(equalToConstant:300).isActive = true // Expanded height
                self.postText.isScrollEnabled = true // Enable scrolling when expanded
            } else {
                self.postText.textContainer.maximumNumberOfLines = self.initialMaxLines
                self.postText.heightAnchor.constraint(equalToConstant: 60).isActive = true // Collapsed height
                self.postText.isScrollEnabled = false // Disable scrolling when collapsed
            }
            self.layoutIfNeeded()
        }
    }
    
    // MARK: - Helper Methods
    private func updateSeeMoreButtonState() {
        let textHeight = postText.sizeThatFits(CGSize(width: postText.bounds.width, height: .greatestFiniteMagnitude)).height
        let twoLineHeight = (postText.font?.lineHeight ?? 0) * CGFloat(initialMaxLines)
        
        seeMoreButton.isHidden = postText.numberOfLines <= initialMaxLines
    }
    
    // MARK: - Reuse
    open override func prepareForReuse() {
        super.prepareForReuse()
        isExpanded = false
        postText.textContainer.maximumNumberOfLines = initialMaxLines
        postText.isScrollEnabled = false // Reset scrolling state
        seeMoreButton.setTitle("...See More", for: .normal)
    }
    
    // MARK: - Layout
    open override func layoutSubviews() {
        super.layoutSubviews()
        updateSeeMoreButtonState()
    }
}
