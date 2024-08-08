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
    func onPostListScrolled(_ scrollView: UIScrollView)
    func onPostDataFetched(isEmpty: Bool)
}

// MARK: LMFeedPostListVCToProtocol
// This contains list of functions that are triggered from Parent View Controller to be handled by Child View Controller aka `LMFeedPostListScreen`
public protocol LMFeedPostListVCToProtocol: AnyObject {
    func loadPostsWithTopics(_ topics: [String])
}

@IBDesignable
open class LMFeedPostListScreen: LMViewController, LMFeedPostListViewModelProtocol {
    
    // MARK: UI Elements
    open private(set) lazy var postList: LMTableView = {
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
        table.register(LMUIComponents.shared.pollCell)
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
    public var data: [LMFeedPostContentModel] = []
    public var viewModel: LMFeedPostListViewModel?
    public weak var delegate: LMFeedPostListVCFromProtocol?
    
    
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
    
    
    // MARK: setupActions
    open override func setupActions() {
        super.setupActions()
        postList.refreshControl = refreshControl
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
        postList.backgroundColor = Appearance.shared.colors.clear
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
        postList.visibleCells.forEach { cell in
            (cell as? LMFeedPostMediaCell)?.tableViewScrolled()
        }
    }
    
    open func reloadTable(for index: IndexSet? = nil) {
        postList.visibleCells.forEach { cell in
            (cell as? LMFeedPostMediaCell)?.tableViewScrolled()
        }
        
        postList.reloadTableForSection(for: index)
    }
    
    
    // MARK: LMFeedPostListViewModelProtocol
    open func updateHeader(with data: [LMFeedPostContentModel], section: Int) {
        self.data = data
        (postList.headerView(forSection: section) as? LMFeedPostHeaderView)?.pinButton.isHidden.toggle()
    }
    
    open func navigateToEditScreen(for postID: String) {
        guard let viewcontroller = LMFeedEditPostViewModel.createModule(for: postID) else { return }
        navigationController?.pushViewController(viewcontroller, animated: true)
    }
    
    public func navigateToMediaPreviewScreen(with data: LMFeedPostDataModel) {
        guard let mediaPreviewViewController = LMFeedMediaPreviewViewModel.createModule(with: data) else { return }
        navigationController?.pushViewController(mediaPreviewViewController, animated: true)
    }
    
    open func loadPosts(with data: [LMFeedPostContentModel], index: IndexSet?, reloadNow: Bool) {
        if data.isEmpty {
            emptyListView.configure(title: LMStringConstants.shared.newPost) { [weak self] in
                do {
                    let viewcontroller = try LMFeedCreatePostViewModel.createModule()
                    self?.navigationController?.pushViewController(viewcontroller, animated: true)
                } catch let error {
                    print(error.localizedDescription)
                }
            }
            
            postList.backgroundView = emptyListView
            emptyListView.setHeightConstraint(with: postList.heightAnchor)
            emptyListView.setWidthConstraint(with: postList.widthAnchor)
        } else {
            postList.backgroundView = nil
        }
        
        guard reloadNow else { return }
        
        self.data = data
        
        if let index {
            reloadTable(for: index)
        } else {
            reloadTable()
        }
        delegate?.onPostDataFetched(isEmpty: self.data.isEmpty)
    }
    
    open func showHideFooterLoader(isShow: Bool) {
        postList.showHideFooterLoader(isShow: isShow)
    }
    
    open func showActivityLoader() {
        data.removeAll()
        reloadTable()
    }
    
    open func navigateToDeleteScreen(for postID: String) {
        guard let viewcontroller = LMFeedDeleteViewModel.createModule(postID: postID) else { return }
        viewcontroller.modalPresentationStyle = .overFullScreen
        present(viewcontroller, animated: false)
    }
    
    open func navigateToReportScreen(for postID: String, creatorUUID: String) {
        do {
            let viewcontroller = try LMFeedReportViewModel.createModule(creatorUUID: creatorUUID, postID: postID)
            navigationController?.pushViewController(viewcontroller, animated: true)
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    open func handleCustomWidget(with data: LMFeedPostContentModel) -> LMTableViewCell {
        return LMTableViewCell()
    }
    
    open func navigateToPollResultScreen(with pollID: String, optionList: [LMFeedPollDataModel.Option], selectedOption: String?) {
        do {
            let viewcontroller = try LMFeedPollResultViewModel.createModule(with: pollID, optionList: optionList, selectedOption: selectedOption)
            navigationController?.pushViewController(viewcontroller, animated: true)
        } catch {
            print("Error in \(#function)")
        }
    }
    
    open func navigateToAddOptionPoll(with postID: String, pollID: String, options: [String]) {
        do {
            let viewcontroller = try LMFeedPollAddOptionViewModel.createModule(for: postID, pollID: pollID, options: options, delegate: self)
            viewcontroller.modalPresentationStyle = .overFullScreen
            present(viewcontroller, animated: false)
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
        switch data[indexPath.section].postType {
        case .text, .media:
            if let cell = tableView.dequeueReusableCell(LMUIComponents.shared.postCell, for: indexPath) {
                cell.configure(with: data[indexPath.section], delegate: self)
                return cell
            }
        case .documents:
            if let cell = tableView.dequeueReusableCell(LMUIComponents.shared.documentCell, for: indexPath) {
                cell.configure(for: indexPath, with: data[indexPath.section], delegate: self)
                return cell
            }
        case .link:
            if let cell = tableView.dequeueReusableCell(LMUIComponents.shared.linkCell, for: indexPath) {
                cell.configure(with: data[indexPath.section], delegate: self)
                return cell
            }
        case .poll:
            if let cell = tableView.dequeueReusableCell(LMUIComponents.shared.pollCell) {
                cell.configure(with: data[indexPath.section], delegate: self)
                return cell
            }
        default:
            return handleCustomWidget(with: data[indexPath.section])
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
        delegate?.onPostListScrolled(scrollView)
    }
    
    open func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        postList.visibleCells.forEach { cell in
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

    open func scrollingFinished() {
        for cell in postList.visibleCells {
            if type(of: cell) == LMFeedPostMediaCell.self,
               postList.percentVisibility(of: cell) >= 0.8 {
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
        if var docData = data[safe: indexPath.section] {
            docData.isShowMoreDocuments.toggle()
            data[indexPath.section] = docData
            reloadTable(for: .init(integer: indexPath.section))
        }
    }
    
    open func didTapDocument(with url: URL) {
        openURL(with: url)
    }
}


// MARK: LMFeedPostPollCellProtocol
@objc
extension LMFeedPostListScreen: LMFeedPostPollCellProtocol {
    open func didTapVoteCountButton(for postID: String, pollID: String, optionID: String?) {
        viewModel?.didTapVoteCountButton(for: postID, pollID: pollID, optionID: optionID)
    }
    
    open func didTapToVote(for postID: String, pollID: String, optionID: String) {
        viewModel?.optionSelected(for: postID, pollID: pollID, option: optionID)
    }
    
    open func didTapSubmitVote(for postID: String, pollID: String) {
        viewModel?.pollSubmitButtonTapped(for: postID, pollID: pollID)
    }
    
    open func editVoteTapped(for postID: String, pollID: String) {
        viewModel?.editPoll(for: postID)
    }
    
    open func didTapAddOption(for postID: String, pollID: String) {
        viewModel?.didTapAddOption(for: postID, pollID: pollID)
    }
}


// MARK: LMFeedAddOptionProtocol
extension LMFeedPostListScreen: LMFeedAddOptionProtocol {
    public func onAddOptionResponse(postID: String, success: Bool, errorMessage: String?) {
        if !success {
            showError(with: errorMessage ?? "Something went wrong", isPopVC: false)
        } else {
            viewModel?.getPost(for: postID)
        }
    }
}
