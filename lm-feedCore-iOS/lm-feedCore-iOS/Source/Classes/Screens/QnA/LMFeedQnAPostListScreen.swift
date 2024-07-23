//
//  LMFeedQnAPostListScreen.swift
//  LikeMindsFeedCore
//
//  Created by Devansh Mohata on 21/07/24.
//

import LikeMindsFeedUI

open class LMFeedQnAPostListScreen: LMFeedPostListBase, LMFeedBaseViewModelProtocol {
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
    
    open func navigateToEditScreen(for postID: String) {
        guard let viewcontroller = LMFeedEditPostViewModel.createModule(for: postID) else { return }
        navigationController?.pushViewController(viewcontroller, animated: true)
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
    
    open func updateHeader(with data: [LMFeedPostContentModel], section: Int) {
        self.data = data
        (postList.headerView(forSection: section) as? LMFeedPostHeaderView)?.pinButton.isHidden.toggle()
    }
    
    public func navigateToPollResultScreen(with pollID: String, optionList: [LMFeedPollDataModel.Option], selectedOption: String?) {
        
    }
    
    public func navigateToAddOptionPoll(with postID: String, pollID: String, options: [String]) {
        
    }
    
    open func reloadTable(for index: IndexSet? = nil) {
        postList.visibleCells.forEach { cell in
            (cell as? LMFeedPostMediaCell)?.tableViewScrolled()
        }
        
        postList.reloadTableForSection(for: index)
    }
    
    public var viewModel: LMFeedQnAPostListViewModel?
    
    open override func setupTableView() {
        super.setupTableView()
        
        postList.dataSource = self
        postList.delegate = self
        postList.prefetchDataSource = self
        
        postList.register(LMUIComponents.shared.qnaPostCell)
        postList.register(LMUIComponents.shared.qnaLinkCell)
        postList.register(LMUIComponents.shared.qnaDocumentCell)
        postList.registerHeaderFooter(LMUIComponents.shared.headerView)
        postList.registerHeaderFooter(LMUIComponents.shared.qnaFooterView)
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
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel?.getFeed()
        
        // Analytics
        LMFeedCore.analytics?.trackEvent(for: .feedOpened, eventProperties: ["feed_type": "qna_feed"])
    }
}


// MARK: UITableView
extension LMFeedQnAPostListScreen: UITableViewDataSource, UITableViewDelegate, UITableViewDataSourcePrefetching {
    open func numberOfSections(in tableView: UITableView) -> Int { data.count }
    
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { 1 }
    
    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch data[indexPath.section].postType {
        case .text, .media:
            if let cell = tableView.dequeueReusableCell(LMUIComponents.shared.qnaPostCell, for: indexPath) {
                cell.configure(with: data[indexPath.section], delegate: self)
                return cell
            }
        case .documents:
            if let cell = tableView.dequeueReusableCell(LMUIComponents.shared.qnaDocumentCell, for: indexPath) {
                cell.configure(for: indexPath, with: data[indexPath.section], delegate: self)
                return cell
            }
        case .link:
            if let cell = tableView.dequeueReusableCell(LMUIComponents.shared.qnaLinkCell, for: indexPath) {
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
           let footer = tableView.dequeueReusableHeaderFooterView(LMUIComponents.shared.qnaFooterView) {
            footer.configure(with: cellData.footerData, postID: cellData.postID, delegate: self, topComment: cellData.topResponse)
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
}


// MARK: LMPostWidgetTableViewCellProtocol, LMFeedLinkProtocol, LMFeedPostDocumentCellProtocol
@objc
extension LMFeedQnAPostListScreen: LMFeedLinkProtocol, LMFeedPostDocumentCellProtocol {
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
//            reloadTable(for: .init(integer: indexPath.section))
        }
    }
    
    open func didTapDocument(with url: URL) {
        openURL(with: url)
    }
}


// MARK: LMFeedPostHeaderViewProtocol
@objc
extension LMFeedQnAPostListScreen: LMFeedPostHeaderViewProtocol {
    open func didTapProfilePicture(having uuid: String) {
        showError(with: "User Profile Tapped having UUID: \(uuid)", isPopVC: false)
    }
    
    open func didTapPostMenuButton(for postID: String) {
        viewModel?.showMenu(for: postID)
    }
}


// MARK: LMFeedPostFooterViewProtocol
@objc
extension LMFeedQnAPostListScreen: LMFeedPostFooterViewProtocol {
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
