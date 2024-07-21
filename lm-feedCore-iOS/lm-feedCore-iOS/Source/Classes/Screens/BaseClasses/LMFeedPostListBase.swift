//
//  LMFeedPostListBase.swift
//  LikeMindsFeedCore
//
//  Created by Devansh Mohata on 21/07/24.
//

import LikeMindsFeedUI

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
    
    public var postCell: LMFeedPostMediaCell.Type {
        LMUIComponents.shared.postCell
    }
    
    public var linkCell: LMFeedPostLinkCell.Type {
        LMUIComponents.shared.linkCell
    }
    
    public var documentCell: LMFeedPostDocumentCell.Type {
        LMUIComponents.shared.documentCell
    }
    
    public var pollCell: LMFeedPostPollCell.Type {
        LMUIComponents.shared.pollCell
    }
    
    public var headerView: LMFeedPostHeaderView.Type {
        LMUIComponents.shared.headerView
    }
    
    public var footerView: LMFeedPostFooterView.Type {
        LMUIComponents.shared.footerView
    }
    
    open func setupTableView() {
        postList.register(postCell)
        postList.register(documentCell)
        postList.register(linkCell)
        postList.register(pollCell)
        postList.registerHeaderFooter(headerView)
        postList.registerHeaderFooter(footerView)
    }
    
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
        view.backgroundColor = Appearance.shared.colors.backgroundColor
        postList.backgroundColor = Appearance.shared.colors.clear
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
}
