import Foundation
import LikeMindsFeedUI
import LikeMindsFeed

public protocol LMFeedVideoListViewModelProtocol: AnyObject {
    func updateVideoList(with posts: [LMFeedPostContentModel], isInitialPage: Bool)
    func showError(with message: String, isPopVC: Bool)
    func showActivityLoader()
    func showHideFooterLoader(isShow: Bool)
}

open class LMFeedVideoListViewModel {
    // MARK: Data Variables
    private var currentPage: Int = 1
    private var pageSize: Int = 20
    private var isLastPostReached: Bool = false
    private var isFetchingFeed: Bool = false
    private var postList: [LMFeedPostDataModel] = []
    
    public weak var delegate: LMFeedVideoListViewModelProtocol?
    
    // Sample colors for demonstration
    public let pageColors: [UIColor] = [
        .systemRed,
        .systemBlue,
        .systemGreen,
        .systemYellow,
        .systemPurple,
        .systemOrange,
        .systemPink,
        .systemTeal
    ]
    
    // MARK: Initialization
    public init(delegate: LMFeedVideoListViewModelProtocol?) {
        self.delegate = delegate
    }
    
    // MARK: Public Methods
    public func getFeed() {
        // Simulate network delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            // For now, we'll just update with empty data since we're showing colors
            self?.delegate?.updateVideoList(with: [], isInitialPage: true)
        }
    }
    
    public func likePost(for postID: String) {
        // Handle like action
    }
    
    public func savePost(for postID: String) {
        // Handle save action
    }
    
    public func showMenu(for postID: String) {
        // Handle menu action
    }
    
    public func allowPostLikeView(for postID: String) -> Bool {
        return true
    }
} 
