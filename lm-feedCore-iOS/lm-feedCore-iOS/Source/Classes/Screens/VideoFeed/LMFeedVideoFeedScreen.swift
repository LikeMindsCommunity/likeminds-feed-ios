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
    
    // MARK: Data Variables
    private let feedType: LMFeedType
    public var viewModel: LMFeedVideoFeedViewModel?
    
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
        
        viewModel = LMFeedVideoFeedViewModel(delegate: self)
    }
    
    // MARK: Setup Methods
    open override func setupViews() {
        super.setupViews()
    }
    
    open override func setupLayouts() {
        super.setupLayouts()
    }
    
    open override func setupActions() {
        super.setupActions()
        // Set title to the left
        let titleLabel = UILabel()
        titleLabel.text = "Reels"
        titleLabel.textColor = .white
        titleLabel.font = .systemFont(ofSize: 20, weight: .bold)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: titleLabel)
        
        // Add post button to the right
        let buttonContainer = UIView(frame: CGRect(x: 0, y: 0, width: 120, height: 40))
        buttonContainer.addSubview(newPostButton)
        newPostButton.frame = buttonContainer.bounds
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: buttonContainer)
    }
    
    open override func setupAppearance() {
        super.setupAppearance()
        view.backgroundColor = .black
        navigationController?.navigationBar.barTintColor = .black
        navigationController?.navigationBar.tintColor = .black
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
            navigationController?.pushViewController(shortVideoScreen, animated: true)
        } catch {
            print(error.localizedDescription)
        }
    }
}
