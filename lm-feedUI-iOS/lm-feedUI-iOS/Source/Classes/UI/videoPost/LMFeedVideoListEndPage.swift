import UIKit

open class LMFeedVideoListEndPage: LMFeedView {
    // MARK: UI Elements
    open private(set) lazy var checkmarkImageView: LMFeedImageView = {
        let imageView = LMFeedImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .black
        if let checkmarkImage = UIImage(systemName: "checkmark.circle") {
            imageView.image = checkmarkImage
        }
        return imageView
    }()
    
    open private(set) lazy var circleView: LMFeedView = {
        let view = LMFeedView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 30
        view.backgroundColor = .clear
        return view
    }()
    
    open private(set) lazy var messageLabel: LMFeedLabel = {
        let label = LMFeedLabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = LMFeedConstants.Strings.shared.videoListEndPageTitle
        label.textColor = .black
        label.font = .systemFont(ofSize: 18, weight: .medium)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    open private(set) lazy var viewOldPostsButton: LMFeedButton = {
        let button = LMFeedButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(LMFeedConstants.Strings.shared.videoListEndPageButtonTitle, for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16)
        button.backgroundColor = .clear
        return button
    }()
    
    // MARK: Properties
    public var onViewOldPostsTapped: (() -> Void)?
    
    // MARK: Initialization
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupLayouts()
        setupActions()
    }
    
    // MARK: Setup Methods
    open override func setupViews() {
        backgroundColor = .white
        
        // Add views in correct order
        addSubview(circleView)
        circleView.addSubview(checkmarkImageView)
        addSubview(messageLabel)
        addSubview(viewOldPostsButton)
        
        // Force layout update
        setNeedsLayout()
        layoutIfNeeded()
    }
    
    open override func setupLayouts() {
        NSLayoutConstraint.activate([
            // Circle view constraints
            circleView.centerXAnchor.constraint(equalTo: centerXAnchor),
            circleView.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -60),
            circleView.widthAnchor.constraint(equalToConstant: 60),
            circleView.heightAnchor.constraint(equalToConstant: 60),
            
            // Checkmark image constraints
            checkmarkImageView.centerXAnchor.constraint(equalTo: circleView.centerXAnchor),
            checkmarkImageView.centerYAnchor.constraint(equalTo: circleView.centerYAnchor),
            checkmarkImageView.widthAnchor.constraint(equalToConstant: 40),
            checkmarkImageView.heightAnchor.constraint(equalToConstant: 40),
            
            // Message label constraints
            messageLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            messageLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            messageLabel.topAnchor.constraint(equalTo: circleView.bottomAnchor, constant: 16),
            
            // View old posts button constraints
            viewOldPostsButton.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 16),
            viewOldPostsButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            viewOldPostsButton.widthAnchor.constraint(equalToConstant: 150),
            viewOldPostsButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    open override func setupActions() {
        viewOldPostsButton.addTarget(self, action: #selector(didTapViewOldPosts), for: .touchUpInside)
    }
    
    // MARK: Actions
    @objc open func didTapViewOldPosts() {
        onViewOldPostsTapped?()
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        // Ensure all views are visible after layout
        messageLabel.isHidden = false
        viewOldPostsButton.isHidden = false
    }
} 
