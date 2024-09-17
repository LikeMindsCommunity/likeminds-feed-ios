//
//  LMFeedBasePostListScreen.swift
//  LikeMindsFeedCore
//
//  Created by Devansh Mohata on 21/07/24.
//

import LikeMindsFeedUI

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

open class LMFeedBasePostListScreen: LMViewController, LMFeedBasePostListViewModelProtocol {
    // MARK: UI Elements
    open lazy var postList: LMTableView = {
        let table = LMTableView(frame: .zero, style: .grouped)
        table.translatesAutoresizingMaskIntoConstraints = false
        table.separatorStyle = .none
        table.showsVerticalScrollIndicator = false
        table.showsHorizontalScrollIndicator = false
        configureTableViewCells(table)
        return table
    }()
    
    open lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        return refreshControl
    }()
    
    open lazy var emptyListView: LMFeedNoPostWidget = {
        let view = LMFeedNoPostWidget(frame: .zero).translatesAutoresizingMaskIntoConstraints()
        return view
    }()
    
    public typealias DataSource = UITableViewDiffableDataSource<String, LMFeedPostContentModel>
    public typealias Snapshot = NSDiffableDataSourceSnapshot<String, LMFeedPostContentModel>
    
    // MARK: Data Variables
    public var data: [LMFeedPostContentModel] = [] {
        didSet {
            print(data.count)
        }
    }
    public var viewModel: LMFeedBasePostListViewModel?
    public weak var delegate: LMFeedPostListVCFromProtocol?
    
    
    // MARK: Setup Methods
    open override func setupViews() {
        super.setupViews()
        view.addSubview(postList)
    }
    
    open override func setupLayouts() {
        super.setupLayouts()
        view.pinSubView(subView: postList)
    }
    
    open override func setupActions() {
        super.setupActions()
        postList.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(pullToRefresh), for: .valueChanged)
    }
    
    open override func setupAppearance() {
        super.setupAppearance()
        view.backgroundColor = LMFeedAppearance.shared.colors.backgroundColor
        postList.backgroundColor = LMFeedAppearance.shared.colors.clear
    }
    
    open override func setupObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(postUpdated), name: .LMPostEdited, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(postUpdated), name: .LMPostUpdate, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(postDelete), name: .LMPostDeleted, object: nil)
    }
    
    // MARK: Lifecycle Methods
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        postList.dataSource = self
        postList.delegate = self
        postList.prefetchDataSource = self
        
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
    
    // MARK: Helper Methods
    open func configureTableViewCells(_ tableView: LMTableView) {
        fatalError("Needs to be implemented by subclass")
    }
    
    open func reloadTable(for index: IndexSet? = nil) {
        postList.visibleCells.forEach { cell in
            (cell as? LMFeedPostMediaCell)?.tableViewScrolled()
        }
        
        postList.reloadTableForSection(for: index)
    }
    
    @objc open func pullToRefresh() {
        refreshControl.endRefreshing()
        viewModel?.getFeed(fetchInitialPage: true)
    }
    
    @objc open func postUpdated(notification: Notification) {
        if let data = notification.object as? LMFeedPostDataModel {
            viewModel?.updatePostData(for: data)
        }
    }
    
    @objc open func postDelete(notification: Notification) {
        if let postID = notification.object as? String {
            viewModel?.removePost(for: postID)
        }
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
    
    // MARK: LMFeedPostListViewModelProtocol
    open func updateHeader(with data: [LMFeedPostContentModel], section: Int) {
        self.data = data
        (postList.headerView(forSection: section) as? LMFeedPostHeaderView)?.pinButton.isHidden.toggle()
    }
    
    open func navigateToEditScreen(for postID: String) {
        guard let viewcontroller = LMFeedEditPostViewModel.createModule(for: postID) else { return }
        navigationController?.pushViewController(viewcontroller, animated: true)
    }
    
    public func updatePostList(with post: [LMFeedPostContentModel], isInitialPage: Bool) {
        if isInitialPage {
            data.removeAll(keepingCapacity: true)
        }
        
        let oldIndex = data.count
        data.append(contentsOf: post)
        let newIndex = data.count - 1
        
        if data.isEmpty {
            configureEmptyListView()
        } else {
            postList.backgroundView = nil
        }
        
        if isInitialPage {
            postList.reloadTable()
        } else {
            postList.beginUpdates()
            let indexSet = IndexSet(integersIn: oldIndex...newIndex)
            postList.insertSections(indexSet, with: .none)
            postList.endUpdates()
        }
    }
    
    public func updatePost(with post: LMFeedPostContentModel, onlyHeader: Bool, onlyFooter: Bool) {
        guard let index = data.firstIndex(where: { $0.postID == post.postID }) else { return }
        
        data[index] = post
        
        if onlyHeader {
            (postList.headerView(forSection: index) as? LMFeedPostHeaderView)?.togglePinStatus(isPinned: post.headerData.isPinned)
        } else if onlyFooter {
            (postList.footerView(forSection: index) as? LMFeedBasePostFooterView)?.configure(with: post.footerData,topResponse: post.topResponse, postID: post.postID, delegate: self)
        } else {
            postList.beginUpdates()
            postList.reloadSections(.init(integer: index), with: .none)
            postList.endUpdates()
        }
    }
    
    public func removePost(with postID: String) {
        guard let index = data.firstIndex(where: { $0.postID == postID }) else { return }
        
        data.remove(at: index)
        
        postList.beginUpdates()
        postList.deleteSections(.init(integer: index), with: .none)
        postList.endUpdates()
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
    
    // MARK: Helper Methods
    open func configureEmptyListView() {
        emptyListView.configure(title: LMStringConstants.shared.newPost) { [weak self] in
            do {
                let viewcontroller = try LMFeedCreatePostViewModel.createModule(showHeading: false)
                self?.navigationController?.pushViewController(viewcontroller, animated: true)
            } catch let error {
                print(error.localizedDescription)
            }
        }
        
        postList.backgroundView = emptyListView
        emptyListView.setHeightConstraint(with: postList.heightAnchor)
        emptyListView.setWidthConstraint(with: postList.widthAnchor)
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate, UITableViewDataSourcePrefetching
extension LMFeedBasePostListScreen: UITableViewDataSource, UITableViewDelegate, UITableViewDataSourcePrefetching {
    open func numberOfSections(in tableView: UITableView) -> Int { data.count }
    
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Each post can have multiple rows: one for text and others for attachments
        let item = data[section]
        
        if( item.postType == .text){
            return 1
        }else{
            if item.postText.isEmpty && item.postQuestion.isEmpty{
                return 1
            }else{
                return 2
            }
        }
    }
    
    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        fatalError("Needs to be implemented by subclass")
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
        return UITableView.automaticDimension
    }
    
    open func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return LMFeedConstants.shared.number.postHeaderSize
    }
    
    open func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        // To be implemented by subclasses
        fatalError("Must be implemented by subclass")
    }
    
    open func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return UITableView.automaticDimension
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
    
    public func getRowType(for row: Int, in item: LMFeedPostContentModel) -> LMFeedPostType {
        // First row is for text, subsequent rows are for attachments
        if row == 0, !item.postText.isEmpty || !item.postQuestion.isEmpty {
            return .text
        }
        
        return item.postType
    }
}

// MARK: - LMFeedPostListVCToProtocol
extension LMFeedBasePostListScreen: LMFeedPostListVCToProtocol {
    public func loadPostsWithTopics(_ topics: [String]) {
        viewModel?.updateTopics(with: topics)
    }
}

// MARK: - LMFeedPostHeaderViewProtocol
extension LMFeedBasePostListScreen: LMFeedPostHeaderViewProtocol {
    public func didTapProfilePicture(having uuid: String) {
        showError(with: "User Profile Tapped having UUID: \(uuid)", isPopVC: false)
    }
    
    public func didTapPostMenuButton(for postID: String) {
        viewModel?.showMenu(for: postID)
    }
}

// MARK: - LMFeedPostFooterViewProtocol
@objc
extension LMFeedBasePostListScreen: LMFeedPostFooterViewProtocol {
    public func didTapLikeButton(for postID: String) {
        if let index = data.firstIndex(where: { $0.postID == postID }) {
            data[index].footerData.isLiked.toggle()
            let isLiked = data[index].footerData.isLiked
            data[index].footerData.likeCount += isLiked ? 1 : -1
            viewModel?.likePost(for: postID)
        }
    }
    
    public func didTapLikeTextButton(for postID: String) {
        guard viewModel?.allowPostLikeView(for: postID) == true else { return }
        do {
            let viewcontroller = try LMFeedLikeViewModel.createModule(postID: postID)
            navigationController?.pushViewController(viewcontroller, animated: true)
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    public func didTapCommentButton(for postID: String) {
        fatalError("needs to be implemented by subclass")
    }
    
    public func didTapShareButton(for postID: String) {
        LMFeedShareUtility.sharePost(from: self, postID: postID)
    }
    
    public func didTapSaveButton(for postID: String) {
        if let index = data.firstIndex(where: { $0.postID == postID }) {
            data[index].footerData.isSaved.toggle()
            viewModel?.savePost(for: postID)
        }
    }
}

// MARK: - LMFeedLinkProtocol, LMFeedPostDocumentCellProtocol
@objc
extension LMFeedBasePostListScreen: LMFeedLinkProtocol, LMFeedPostDocumentCellProtocol, LMFeedPostMediaCellProtocol {
    public func didTapMedia(postID: String, index: Int) {
        
        guard let postData = data.first(where: { $0.postID == postID }) else {
            return
        }
        
        do {
            let viewcontroller = try LMFeedMediaPreviewViewModel.createModule(with: postData, postID: postData.postID, startIndex: index)
            navigationController?.pushViewController(viewcontroller, animated: true)
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    public func didTapPost(postID: String) {
        fatalError("Needs to be implemented by subclass")
    }
    
    public func didTapURL(url: URL) {
        openURL(with: url)
    }
    
    public func didTapRoute(route: String) {
        showError(with: "Tapped User Route with route: \(route)", isPopVC: false)
    }
    
    public func didTapSeeMoreButton(for postID: String) { }
    
    public func didTapLinkPreview(with url: String) {
        guard let urlLink = url.convertIntoURL() else { return }
        openURL(with: urlLink)
    }
    
    public func didTapShowMoreDocuments(for indexPath: IndexPath) {
        if var docData = data[safe: indexPath.section] {
            docData.isShowMoreDocuments.toggle()
            data[indexPath.section] = docData
            reloadTable(for: .init(integer: indexPath.section))
        }
    }
    
    public func didTapDocument(with url: URL) {
        openURL(with: url)
    }
}

// MARK: - LMFeedPostPollCellProtocol
extension LMFeedBasePostListScreen: LMFeedPostPollCellProtocol {
    public func didTapVoteCountButton(for postID: String, pollID: String, optionID: String?) {
        viewModel?.didTapVoteCountButton(for: postID, pollID: pollID, optionID: optionID)
    }
    
    public func didTapToVote(for postID: String, pollID: String, optionID: String) {
        viewModel?.optionSelected(for: postID, pollID: pollID, option: optionID)
    }
    
    public func didTapSubmitVote(for postID: String, pollID: String) {
        viewModel?.pollSubmitButtonTapped(for: postID, pollID: pollID)
    }
    
    public func editVoteTapped(for postID: String, pollID: String) {
        viewModel?.editPoll(for: postID)
    }
    
    public func didTapAddOption(for postID: String, pollID: String) {
        viewModel?.didTapAddOption(for: postID, pollID: pollID)
    }
}

// MARK: - LMFeedAddOptionProtocol
extension LMFeedBasePostListScreen: LMFeedAddOptionProtocol {
    public func onAddOptionResponse(postID: String, success: Bool, errorMessage: String?) {
        if !success {
            showError(with: errorMessage ?? "Something went wrong", isPopVC: false)
        } else {
            viewModel?.getPost(for: postID)
        }
    }
}
