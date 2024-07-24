//
//  LMFeedPostListBase.swift
//  LikeMindsFeedCore
//
//  Created by Devansh Mohata on 21/07/24.
//

import LikeMindsFeedUI

// MARK: LMFeedPostListVCProtocol
// This contains list of functions that are triggered from Child View Controller aka `LMFeedPostListBase` to be handled by Parent View Controller
public protocol LMFeedPostListVCFromProtocol: AnyObject {
    func onPostListScrolled(_ scrollView: UIScrollView)
    func onPostDataFetched(isEmpty: Bool)
}

// MARK: LMFeedPostListVCToProtocol
// This contains list of functions that are triggered from Parent View Controller to be handled by Child View Controller aka `LMFeedPostListBase`
public protocol LMFeedPostListVCToProtocol: AnyObject {
    func loadPostsWithTopics(_ topics: [String])
}


open class LMFeedPostListBase: LMViewController {
    open private(set) lazy var postList: LMTableView = {
        let table = LMTableView(frame: .zero, style: .grouped)
        table.translatesAutoresizingMaskIntoConstraints = false
        table.separatorStyle = .none
        table.showsVerticalScrollIndicator = false
        table.showsHorizontalScrollIndicator = false
        return table
    }()
    
    open private(set) lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        return refreshControl
    }()
    
    open private(set) lazy var emptyListView: LMFeedNoPostWidget = {
        let view = LMFeedNoPostWidget(frame: .zero).translatesAutoresizingMaskIntoConstraints()
        return view
    }()
    
    // MARK: Data Variables
    public var data: [LMFeedPostContentModel] = []
    public weak var delegate: LMFeedPostListVCFromProtocol?
    
    open func setupTableView() { }
    
    // MARK: setupViews
    open override func setupViews() {
        super.setupViews()
        
        view.addSubview(postList)
    }
    
    
    // MARK: setupLayouts
    open override func setupLayouts() {
        super.setupLayouts()
        
        view.pinSubView(subView: postList)
    }
    
    
    // MARK: setupAppearance
    open override func setupAppearance() {
        super.setupAppearance()
        view.backgroundColor = LMFeedAppearance.shared.colors.backgroundColor
        postList.backgroundColor = LMFeedAppearance.shared.colors.clear
    }
    
    
    // MARK: setupActions
    open override func setupActions() {
        super.setupActions()
        postList.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(pullToRefresh), for: .valueChanged)
    }
    
    @objc
    open func pullToRefresh() { }
    
    // MARK: setupObservers
    open override func setupObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(postUpdated), name: .LMPostEdited, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(postUpdated), name: .LMPostUpdate, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(postDelete), name: .LMPostDeleted, object: nil)
    }
    
    @objc
    open func postUpdated(notification: Notification) { }
    
    @objc
    open func postDelete(notification: Notification) { }
    
    
    // MARK: viewDidLoad
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
    }
    
    open func handleCustomWidget(with data: LMFeedPostContentModel) -> LMTableViewCell {
        return LMTableViewCell()
    }
}


// MARK: LMFeedPostListVCToProtocol
@objc
extension LMFeedPostListBase: LMFeedPostListVCToProtocol {
    open func loadPostsWithTopics(_ topics: [String]) { }
}
