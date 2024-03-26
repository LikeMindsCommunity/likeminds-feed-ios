//
//  LMFeedPostListScreen.swift
//  likeminds-feed-iOS
//
//  Created by Devansh Mohata on 02/01/24.
//

import UIKit
import LikeMindsFeedUI

// MARK: LMFeedPostListVCProtocol
// This contains list of functions that are triggered from Child View Controller aka `LMFeedPostListScreen` to be handled by Parent View Controller
public protocol LMFeedPostListVCFromProtocol: AnyObject {
    func tableViewScrolled(_ scrollView: UIScrollView)
    func postDataFetched(isEmpty: Bool)
}

// MARK: LMFeedPostListVCToProtocol
// This contains list of functions that are triggered from Parent View Controller to be handled by Child View Controller aka `LMFeedPostListScreen`
public protocol LMFeedPostListVCToProtocol: AnyObject {
    func loadPostsWithTopics(_ topics: [String])
}

@IBDesignable
open class LMFeedPostListScreen: LMViewController, LMFeedPostListViewModelProtocol {
    open private(set) lazy var tableView: LMTableView = {
        let table = LMTableView(frame: .zero, style: .grouped)
        table.translatesAutoresizingMaskIntoConstraints = false
        table.dataSource = self
        table.delegate = self
        table.prefetchDataSource = self
        table.separatorStyle = .none
        table.showsVerticalScrollIndicator = false
        table.showsHorizontalScrollIndicator = false
        table.register(LMUIComponents.shared.postCell)
        table.register(LMUIComponents.shared.documentCell)
        table.register(LMUIComponents.shared.linkCell)
        table.registerHeaderFooter(LMUIComponents.shared.headerView)
        table.registerHeaderFooter(LMUIComponents.shared.footerView)
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
        LMFeedCore.analytics?.trackEvent(for: .feedOpened, eventProperties: ["feed_type": "universal_feed"])
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        scrollingFinished()
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tableView.visibleCells.forEach { cell in
            (cell as? LMFeedPostMediaCell)?.tableViewScrolled()
        }
    }
    
    open func reloadTable(for index: IndexSet? = nil) {
        tableView.visibleCells.forEach { cell in
            (cell as? LMFeedPostMediaCell)?.tableViewScrolled()
        }
        
        tableView.reloadTableForSection(for: index)
    }
    
    
    // MARK: LMFeedPostListViewModelProtocol
    open func updateHeader(with data: [LMFeedPostTableCellProtocol], section: Int) {
        self.data = data
        (tableView.headerView(forSection: section) as? LMFeedPostHeaderView)?.pinButton.isHidden.toggle()
    }
    
    open func navigateToEditScreen(for postID: String) {
        guard let viewcontroller = LMFeedEditPostViewModel.createModule(for: postID) else { return }
        navigationController?.pushViewController(viewcontroller, animated: true)
    }
    
    open func loadPosts(with data: [LMFeedPostTableCellProtocol], index: IndexSet?, reloadNow: Bool) {
        if data.isEmpty {
            emptyListView.configure { [weak self] in
                do {
                    let viewcontroller = try LMFeedCreatePostViewModel.createModule()
                    self?.navigationController?.pushViewController(viewcontroller, animated: true)
                } catch let error {
                    print(error.localizedDescription)
                }
            }
            
            tableView.backgroundView = emptyListView
            emptyListView.setHeightConstraint(with: tableView.heightAnchor)
            emptyListView.setWidthConstraint(with: tableView.widthAnchor)
        } else {
            tableView.backgroundView = nil
        }
        
        guard reloadNow else { return }
        
        let initialCount = self.data.count
        let newCount = data.count
        self.data = data
        
        if let index {
            reloadTable(for: index)
        } else if newCount > initialCount {
            UIView.performWithoutAnimation {
                tableView.beginUpdates()
                tableView.insertSections(IndexSet(integersIn: (initialCount..<newCount)), with: .none)
                tableView.endUpdates()
            }
        } else {
            reloadTable()
        }
        delegate?.postDataFetched(isEmpty: self.data.isEmpty)
    }
    
    open func showHideFooterLoader(isShow: Bool) {
        tableView.showHideFooterLoader(isShow: isShow)
    }
    
    open func showActivityLoader() {
        data.removeAll()
        reloadTable()
    }
    
    open func navigateToDeleteScreen(for postID: String) {
        guard let viewcontroller = LMFeedDeleteReviewViewModel.createModule(postID: postID) else { return }
        viewcontroller.modalPresentationStyle = .overFullScreen
        present(viewcontroller, animated: false)
    }
    
    open func navigateToReportScreen(for postID: String, creatorUUID: String) {
        do {
            let viewcontroller = try LMFeedReportContentViewModel.createModule(creatorUUID: creatorUUID, postID: postID)
            navigationController?.pushViewController(viewcontroller, animated: true)
        } catch let error {
            print(error.localizedDescription)
        }
    }
}

// MARK: UITableView
@objc
extension LMFeedPostListScreen: UITableViewDataSource, UITableViewDelegate, UITableViewDataSourcePrefetching {
    open func numberOfSections(in tableView: UITableView) -> Int { data.count }
    
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { 1 }
    
    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cellData = data[indexPath.section] as? LMFeedPostMediaCell.ContentModel,
           let cell = tableView.dequeueReusableCell(LMUIComponents.shared.postCell, for: indexPath) {
            cell.configure(with: cellData, delegate: self)
            return cell
        } else if let cellData = data[indexPath.section] as? LMFeedPostDocumentCell.ContentModel,
            let cell = tableView.dequeueReusableCell(LMUIComponents.shared.documentCell, for: indexPath) {
            cell.configure(for: indexPath, with: cellData, delegate: self)
            return cell
        } else if let cellData = data[indexPath.section] as? LMFeedPostLinkCell.ContentModel,
                  let cell = tableView.dequeueReusableCell(LMUIComponents.shared.linkCell, for: indexPath) {
            cell.configure(with: cellData, delegate: self)
            return cell
        }
        
        return UITableViewCell()
    }
        
    open func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if let cellData = data[safe: section],
           let header = tableView.dequeueReusableHeaderFooterView(LMUIComponents.shared.headerView) {
            header.configure(with: cellData.headerData, postID: cellData.postID, userUUID: cellData.userUUID, delegate: self)
            return header
        }
        return nil
    }
    
    open func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }
    
    open func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        Constants.shared.number.postHeaderSize
    }
    
    open func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if let cellData = data[safe: section],
           let footer = tableView.dequeueReusableHeaderFooterView(LMUIComponents.shared.footerView) {
            footer.configure(with: cellData.footerData, postID: cellData.postID, delegate: self)
            return footer
        }
        return nil
    }
    
    open func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        UITableView.automaticDimension
    }
    
    open func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        let filtered = indexPaths.filter({ $0.section >= data.count - 1 })
        
        if !filtered.isEmpty {
            viewModel?.getFeed()
        }
    }
    
    open func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        (cell as? LMFeedPostMediaCell)?.tableViewScrolled()
    }
    
    open func scrollViewDidScroll(_ scrollView: UIScrollView) {
        delegate?.tableViewScrolled(scrollView)
    }
    
    open func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        tableView.visibleCells.forEach { cell in
            (cell as? LMFeedPostMediaCell)?.tableViewScrolled()
        }
    }
    
    open func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            scrollingFinished()
        }
    }

    open func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        scrollingFinished()
    }

    func scrollingFinished() {
        for cell in tableView.visibleCells {
            if type(of: cell) == LMFeedPostMediaCell.self,
               tableView.percentVisibility(of: cell) >= 0.8 {
                (cell as? LMFeedPostMediaCell)?.tableViewScrolled(isPlay: true)
                break
            }
        }
    }
}


// MARK: LMFeedPostListVCToProtocol
@objc
extension LMFeedPostListScreen: LMFeedPostListVCToProtocol {
    open func loadPostsWithTopics(_ topics: [String]) {
        viewModel?.updateTopics(with: topics)
    }
}


@objc
extension LMFeedPostListScreen: LMFeedPostHeaderViewProtocol {
    open func didTapProfilePicture(having uuid: String) {
        showError(with: "User Profile Tapped having UUID: \(uuid)", isPopVC: false)
    }
    
    open func didTapPostMenuButton(for postID: String) {
        viewModel?.showMenu(for: postID)
    }
}

// MARK: LMFeedPostFooterViewProtocol
@objc
extension LMFeedPostListScreen: LMFeedPostFooterViewProtocol {
    open func didTapLikeButton(for postID: String) {
        if let index = data.firstIndex(where: { $0.postID == postID }) {
            data[index].footerData.isLiked.toggle()
            let isLiked = data[index].footerData.isLiked
            data[index].footerData.likeCount += isLiked ? 1 : -1
            viewModel?.likePost(for: postID)
        }
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
        guard let viewController = LMFeedPostDetailViewModel.createModule(for: postID, openCommentSection: true) else { return }
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    open func didTapShareButton(for postID: String) {
        LMFeedShareUtility.sharePost(from: self, postID: postID)
    }
    
    open func didTapSaveButton(for postID: String) {
        if let index = data.firstIndex(where: { $0.postID == postID }) {
            data[index].footerData.isSaved.toggle()
            viewModel?.savePost(for: postID)
        }
    }
}


// MARK: LMPostWidgetTableViewCellProtocol, LMFeedLinkProtocol, LMFeedPostDocumentCellProtocol
@objc
extension LMFeedPostListScreen: LMFeedLinkProtocol, LMFeedPostDocumentCellProtocol {
    open func didTapPost(postID: String) {
        guard let viewController = LMFeedPostDetailViewModel.createModule(for: postID, openCommentSection: false) else { return }
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    open func didTapURL(url: URL) {
        openURL(with: url)
    }
    
    open func didTapRoute(route: String) {
        showError(with: "Tapped User Route with route: \(route)", isPopVC: false)
    }
    
    open func didTapSeeMoreButton(for postID: String) { }
    
    open func didTapLinkPreview(with url: String) {
        guard let urlLink = url.convertIntoURL() else { return }
        openURL(with: urlLink)
    }
    
    open func didTapShowMoreDocuments(for indexPath: IndexPath) {
        if var docData = data[safe: indexPath.section] as? LMFeedPostDocumentCell.ContentModel {
            docData.isShowAllDocuments.toggle()
            data[indexPath.section] = docData
            reloadTable(for: .init(integer: indexPath.section))
        }
    }
    
    open func didTapDocument(with url: URL) {
        openURL(with: url)
    }
}
