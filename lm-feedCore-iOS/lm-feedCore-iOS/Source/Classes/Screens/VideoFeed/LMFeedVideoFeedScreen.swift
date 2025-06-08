import UIKit
import LikeMindsFeedUI
import Photos
import BSImagePicker

public enum LMFeedType {
    case universal
    case personalize
}

open class LMFeedVideoFeedScreen: LMFeedViewController {
    // MARK: UI Elements
    private lazy var newPostButton: LMFeedButton = {
        let button = LMFeedButton.createButton(
            with: LMStringConstants.shared.newVideoPost,
            image: LMFeedConstants.shared.images.addVideoPostIcon,
            textColor: .white,
            textFont: LMFeedAppearance.shared.fonts.buttonFont1,
            contentSpacing: .init(top: 12, left: 12, bottom: 12, right: 12),
            imageSpacing: 8
        )
        button.tintColor = .white
        button.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        button.layer.cornerRadius = 20
        button.clipsToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(didTapNewPost), for: .touchUpInside)
        return button
    }()
    
    private lazy var videoListScreen: LMFeedVideoListScreen = {
        let screen = LMFeedVideoListScreen()
        screen.viewModel = LMFeedVideoListViewModel(delegate: screen, postIds: viewModel?.postIds ?? [])
        screen.delegate = self
        return screen
    }()
    
    private lazy var customNavBar: LMFeedView = {
        let view = LMFeedView().translatesAutoresizingMaskIntoConstraints()
        view.backgroundColor = LMFeedAppearance.shared.colors.black.withAlphaComponent(0.5)
        return view
    }()
    
    private lazy var titleLabel: LMFeedLabel = {
        let label = LMFeedLabel().translatesAutoresizingMaskIntoConstraints()
        label.text = "Reels"
        label.textColor = .white
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: Data Variables
    private let feedType: LMFeedType
    public var viewModel: LMFeedVideoFeedViewModel?
    public var isPostCreationInProgress: Bool = false
    
    // MARK: Initialization
    public init(feedType: LMFeedType = .universal) {
        self.feedType = feedType
        super.init(nibName: nil, bundle: nil)
    }
    
    required public init?(coder: NSCoder) {
        self.feedType = .universal
        super.init(coder: coder)
    }
    
    // MARK: Required Initializer for Components.shared.feedVideoFeedScreen.init()
    public required init() {
        self.feedType = .universal
        super.init(nibName: nil, bundle: nil)
    }
    
    // MARK: Lifecycle Methods
    open override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupLayouts()
        setupActions()
        setupAppearance()
        addChildViewController()
    }
    
    // MARK: Setup Methods
    open override func setupViews() {
        super.setupViews()
        view.addSubview(createPostLoaderView)
    }
    
    open override func setupAppearance() {
        super.setupAppearance()
        view.backgroundColor = .black
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        // Set status bar style to light content
        if #available(iOS 13.0, *) {
            let window = UIApplication.shared.windows.first
            window?.overrideUserInterfaceStyle = .dark
        }
    }
    
    // MARK: setupObservers
    open override func setupObservers() {
        super.setupObservers()
        NotificationCenter.default.addObserver(self, selector: #selector(postCreationInProgress), name: .LMPostCreationStarted, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(postCreationSuccessful), name: .LMPostCreated, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(postError), name: .LMPostEditError, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(postError), name: .LMPostCreateError, object: nil)
    }
    
    @objc
    open func postCreationInProgress(notification: Notification) {
        let image = notification.object as? UIImage
        createPostLoaderView.isHidden = false
        isPostCreationInProgress = true
        createPostLoaderView.configure(with: image)
    }
    
    @objc
    open func postCreationSuccessful() {
        isPostCreationInProgress = false
        createPostLoaderView.stopAnimating()
        createPostLoaderView.isHidden = true
    }
    
    
    @objc
    open func postError(notification: Notification) {
        isPostCreationInProgress = false
        createPostLoaderView.stopAnimating()
        createPostLoaderView.isHidden = true
        
        if let error = notification.object as? LMFeedError {
            showError(with: error.localizedDescription)
        }
    }
    
    
    
    open private(set) lazy var createPostLoaderView: LMFeedAddMediaPreview = {
        let view = LMFeedAddMediaPreview()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        return view
    }()
    

    // MARK: Child View Controller Setup
    private func addChildViewController() {
        // First add the video list screen
        addChild(videoListScreen)
        view.addSubview(videoListScreen.view)
        videoListScreen.view.translatesAutoresizingMaskIntoConstraints = false
        
        // Then add the custom navigation bar on top
        view.addSubview(customNavBar)
        customNavBar.addSubview(titleLabel)
        customNavBar.addSubview(newPostButton)
        
        NSLayoutConstraint.activate([
            // Video list screen constraints
            videoListScreen.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            videoListScreen.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            videoListScreen.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            videoListScreen.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // Navigation bar constraints
            customNavBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            customNavBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            customNavBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            customNavBar.heightAnchor.constraint(equalToConstant: 44),
            
            titleLabel.leadingAnchor.constraint(equalTo: customNavBar.leadingAnchor, constant: 16),
            titleLabel.centerYAnchor.constraint(equalTo: customNavBar.centerYAnchor),
            
            newPostButton.trailingAnchor.constraint(equalTo: customNavBar.trailingAnchor, constant: -16),
            newPostButton.centerYAnchor.constraint(equalTo: customNavBar.centerYAnchor),
            newPostButton.widthAnchor.constraint(equalToConstant: 120),
            newPostButton.heightAnchor.constraint(equalToConstant: 40),

            // Create post loader view constraints
            createPostLoaderView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            createPostLoaderView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            createPostLoaderView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            createPostLoaderView.heightAnchor.constraint(equalToConstant: 60)
        ])
        
        videoListScreen.didMove(toParent: self)
        
        // Ensure navigation bar is on top
        view.bringSubviewToFront(customNavBar)
        view.bringSubviewToFront(createPostLoaderView)
    }
    
    // MARK: Actions
    @objc private func didTapNewPost() {
        let imagePicker = ImagePickerController()
        imagePicker.settings.selection.max = 1
        imagePicker.settings.fetch.assets.supportedMediaTypes = [.video]
        
        presentImagePicker(imagePicker, select: { asset in
        }, deselect: { asset in
        }, cancel: { _ in
        }, finish: { [weak self] assets in
            self?.viewModel?.handleSelectedVideo(assets)
        })
    }
}

// MARK: - LMFeedVideoFeedViewModelDelegate
extension LMFeedVideoFeedScreen: LMFeedVideoFeedViewModelDelegate {
    public func navigateToCreateShortVideo(with video: (PHAsset, URL, Data)) {
        do {
            let shortVideoScreen = try LMFeedCreateShortVideoViewModel.createModule()
            shortVideoScreen.viewModel?.handleAssets(assets: [video])
            
            // Show navigation bar for the next screen
            navigationController?.setNavigationBarHidden(false, animated: true)
            
            // Configure navigation bar appearance
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = .black
            appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
            navigationController?.navigationBar.standardAppearance = appearance
            navigationController?.navigationBar.scrollEdgeAppearance = appearance
            navigationController?.navigationBar.tintColor = .white
            
            navigationController?.pushViewController(shortVideoScreen, animated: true)
        } catch {
            print(error.localizedDescription)
        }
    }
}

// MARK: - LMFeedPostListVCFromProtocol
extension LMFeedVideoFeedScreen: LMFeedPostListVCFromProtocol {
    public func onPostListScrolled(_ scrollView: UIScrollView) {
        
    }
    
    public func onPostDataFetched(isEmpty: Bool) {
        // Handle empty state if needed
    }
}
