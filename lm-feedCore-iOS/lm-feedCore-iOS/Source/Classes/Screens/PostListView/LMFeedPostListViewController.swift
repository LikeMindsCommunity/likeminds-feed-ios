//
//  KFN.swift
//  likeminds-feed-iOS
//
//  Created by Devansh Mohata on 02/01/24.
//

import UIKit
import lm_feedUI_iOS

// MARK: LMFeedPostListVCProtocol
// This contains list of functions that are triggered from Child View Controller aka `LMFeedPostListViewController` to be handled by Parent View Controller
public protocol LMFeedPostListVCFromProtocol: AnyObject {
    func tableViewScrolled(_ scrollView: UIScrollView)
    func postDataFetched(isEmpty: Bool)
}

// MARK: LMFeedPostListVCToProtocol
// This contains list of functions that are triggered from Parent View Controller to be handled by Child View Controller aka `LMFeedPostListViewController`
public protocol LMFeedPostListVCToProtocol: AnyObject {
    func loadPostsWithTopics(_ topics: [String])
}

@IBDesignable
open class LMFeedPostListViewController: LMViewController {
    open private(set) lazy var tableView: LMTableView = {
        let table = LMTableView().translatesAutoresizingMaskIntoConstraints()
        table.dataSource = self
        table.delegate = self
        table.separatorStyle = .none
        table.showsVerticalScrollIndicator = false
        table.showsHorizontalScrollIndicator = false
        table.rowHeight = UITableView.automaticDimension
        table.register(LMUIComponents.shared.postCell)
        table.register(LMUIComponents.shared.documentCell)
        table.register(LMUIComponents.shared.linkCell)
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
    public var data: [LMFeedPostTableCellProtocol] = []
    public var viewModel: LMFeedPostListViewModel?
    public weak var delegate: LMFeedPostListVCFromProtocol?
    
    
    // MARK: setupViews
    open override func setupViews() {
        super.setupViews()
        view.addSubview(tableView)
    }
    
    
    // MARK: setupLayouts
    open override func setupLayouts() {
        super.setupLayouts()
        view.pinSubView(subView: tableView)
    }
    
    
    // MARK: setupActions
    open override func setupActions() {
        super.setupActions()
        tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(pullToRefresh), for: .valueChanged)
    }
    
    @objc
    open func pullToRefresh() {
        refreshControl.endRefreshing()
        viewModel?.getFeed(fetchInitialPage: true)
    }
    
    
    // MARK: setupAppearance
    open override func setupAppearance() {
        super.setupAppearance()
        view.backgroundColor = Appearance.shared.colors.backgroundColor
        tableView.backgroundColor = Appearance.shared.colors.clear
    }
    
    
    // MARK: setupObservers
    open override func setupObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(postUpdated), name: .LMPostEdited, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(postUpdated), name: .LMPostUpdate, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(postDelete), name: .LMPostDeleted, object: nil)
    }
    
    @objc 
    open func postUpdated(notification: Notification) {
        if let data = notification.object as? LMFeedPostDataModel {
            viewModel?.updatePostData(for: data)
        }
    }
    
    @objc
    open func postDelete(notification: Notification) {
        if let postID = notification.object as? String {
            viewModel?.removePost(for: postID)
        }
    }
    
    
    // MARK: viewDidLoad
    open override func viewDidLoad() {
        super.viewDidLoad()
        viewModel?.getFeed()
        
        // Analytics
        LMFeedMain.analytics?.trackEvent(for: .feedOpened, eventProperties: ["feed_type": "universal_feed"])
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tableView.visibleCells.forEach { cell in
            (cell as? LMFeedPostMediaCell)?.tableViewScrolled()
        }
    }
}

// MARK: UITableView
@objc
extension LMFeedPostListViewController: UITableViewDataSource, UITableViewDelegate {
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        data.count
    }
    
    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(LMUIComponents.shared.postCell),
           let cellData = data[indexPath.row] as? LMFeedPostMediaCell.ViewModel {
            cell.configure(with: cellData, delegate: self)
            return cell
        } else if let cell = tableView.dequeueReusableCell(LMUIComponents.shared.documentCell),
                  let cellData = data[indexPath.row] as? LMFeedPostDocumentCell.ViewModel {
            cell.configure(for: indexPath, with: cellData, delegate: self)
            return cell
        } else if let cell = tableView.dequeueReusableCell(LMUIComponents.shared.linkCell),
                  let cellData = data[indexPath.row] as? LMFeedPostLinkCell.ViewModel {
            cell.configure(with: cellData, delegate: self)
            return cell
        }
        
        return UITableViewCell()
    }
    
    open func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if data.count == indexPath.row + 1 {
            viewModel?.getFeed()
        }
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        delegate?.tableViewScrolled(scrollView)
        tableView.visibleCells.forEach { cell in
            (cell as? LMFeedPostMediaCell)?.tableViewScrolled()
        }
    }
}


// MARK: LMFeedTableCellToViewControllerProtocol
@objc
extension LMFeedPostListViewController: LMFeedTableCellToViewControllerProtocol {
    open func didTapProfilePicture(for uuid: String) {
        print(#function)
    }
    
    open func didTapMenuButton(postID: String) {
        viewModel?.showMenu(for: postID)
    }
    
    open func didTapLikeButton(for postID: String) {
        guard let index = data.firstIndex(where: { $0.postID == postID }) else { return }
        viewModel?.likePost(for: postID)
        
        var tempData = data[index]
        var tempFooterData = tempData.footerData
        tempFooterData.isLiked.toggle()
        tempFooterData.likeCount += tempFooterData.isLiked ? 1 : -1
        
        tempData.footerData = tempFooterData
        
        data[index] = tempData
        
        tableView.reloadRows(at: [.init(row: index, section: 0)], with: .none)
    }
    
    open func didTapLikeTextButton(for postID: String) {
        guard viewModel?.allowPostLikeView(for: postID) == true else { return }
        do {
            let viewcontroller = try LMFeedLikeViewModel.createModule(postID: postID)
            navigationController?.pushViewController(viewcontroller, animated: true)
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    open func didTapCommentButton(for postID: String) {
        openPost(postID: postID, openCommentSection: true)
    }
    
    open func didTapShareButton(for postID: String) {
        LMFeedShareUtility.sharePost(from: self, postID: postID)
    }
    
    open func didTapSaveButton(for postID: String) {
        guard let index = data.firstIndex(where: { $0.postID == postID }) else { return }
        viewModel?.savePost(for: postID)
        
        var tempData = data[index]
        var tempFooterData = tempData.footerData
        tempFooterData.isSaved.toggle()
        
        tempData.footerData = tempFooterData
        
        data[index] = tempData
        
        tableView.reloadRows(at: [.init(row: index, section: 0)], with: .none)
    }
    
    open func didTapPost(postID: String) {
        openPost(postID: postID)
    }
    
    public func openPost(postID: String, openCommentSection: Bool = false) {
        guard let viewController = LMFeedPostDetailViewModel.createModule(for: postID, openCommentSection: openCommentSection) else { return }
        navigationController?.pushViewController(viewController, animated: true)
    }
}


// MARK: LMFeedPostDocumentCellProtocol
@objc
extension LMFeedPostListViewController: LMFeedPostDocumentCellProtocol {
    open func didTapShowMoreDocuments(for indexPath: IndexPath) {
        if var docData = data[safe: indexPath.row] as? LMFeedPostDocumentCell.ViewModel {
            docData.isShowAllDocuments.toggle()
            data[indexPath.row] = docData
            tableView.reloadRows(at: [indexPath], with: .none)
        }
    }
    
    open func didTapDocument(with url: String) {
        guard let url = URL(string: url) else { return }
        UIApplication.shared.open(url)
    }
}


// MARK: LMChatLinkProtocol
@objc
extension LMFeedPostListViewController: LMChatLinkProtocol {
    open func didTapLinkPreview(with url: String) {
        guard let urlLink = URL(string: url) else { return }
        UIApplication.shared.open(urlLink)
    }
}


// MARK: LMFeedPostListViewModelProtocol
extension LMFeedPostListViewController: LMFeedPostListViewModelProtocol {
    public func navigateToEditScreen(for postID: String) {
        guard let viewcontroller = LMFeedEditPostViewModel.createModule(for: postID) else { return }
        navigationController?.pushViewController(viewcontroller, animated: true)
    }
    
    public func loadPosts(with data: [LMFeedPostTableCellProtocol], for index: IndexPath?) {
        self.data = data
        if let index {
            tableView.reloadRows(at: [index], with: .none)
        } else {
            tableView.reloadData()
        }
        
        if self.data.isEmpty {
            tableView.backgroundView = emptyListView
            emptyListView.setHeightConstraint(with: tableView.heightAnchor)
            emptyListView.setWidthConstraint(with: tableView.widthAnchor)
        } else {
            tableView.backgroundView = nil
        }
        
        delegate?.postDataFetched(isEmpty: self.data.isEmpty)
    }
    
    public func undoLikeAction(for postID: String) {
        guard let index = data.firstIndex(where: { $0.postID == postID }) else { return }
        var tempData = data[index].footerData
        
        tempData.isLiked.toggle()
        tempData.likeCount += tempData.isLiked ? 1 : -1
        
        data[index].footerData = tempData
        
        tableView.reloadRows(at: [.init(row: index, section: 0)], with: .none)
    }
    
    public func undoSaveAction(for postID: String) {
        guard let index = data.firstIndex(where: { $0.postID == postID }) else { return }
        var tempData = data[index].footerData
        
        tempData.isSaved.toggle()
        
        data[index].footerData = tempData
        
        tableView.reloadRows(at: [.init(row: index, section: 0)], with: .none)
    }
    
    public func showHideFooterLoader(isShow: Bool) {
        tableView.showHideFooterLoader(isShow: isShow)
    }
    
    public func showActivityLoader() {
        data.removeAll()
        tableView.reloadData()
    }
    
    public func navigateToDeleteScreen(for postID: String) {
        guard let viewcontroller = LMFeedDeleteReviewViewModel.createModule(postID: postID) else { return }
        viewcontroller.modalPresentationStyle = .overFullScreen
        present(viewcontroller, animated: false)
    }
    
    public func navigateToReportScreen(for postID: String, creatorUUID: String) {
        do {
            let viewcontroller = try LMFeedReportContentViewModel.createModule(creatorUUID: creatorUUID, postID: postID)
            navigationController?.pushViewController(viewcontroller, animated: true)
        } catch let error {
            print(error.localizedDescription)
        }
    }
}


// MARK: LMFeedPostListVCToProtocol
@objc
extension LMFeedPostListViewController: LMFeedPostListVCToProtocol {
    open func loadPostsWithTopics(_ topics: [String]) {
        viewModel?.updateTopics(with: topics)
    }
}
