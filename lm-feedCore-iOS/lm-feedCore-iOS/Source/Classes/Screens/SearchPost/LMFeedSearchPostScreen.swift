//
//  LMFeedSearchPostScreen.swift
//  LikeMindsFeedCore
//
//  Created by Devansh Mohata on 29/06/24.
//

import LikeMindsFeedUI
import UIKit

open class LMFeedSearchPostScreen: LMViewController {
    // MARK: UI Elements
    open private(set) lazy var postList: LMTableView = {
        let table = LMTableView(frame: .zero, style: .grouped)
        table.translatesAutoresizingMaskIntoConstraints = false
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
    
    open private(set) lazy var searchController: UISearchController = {
        let search = UISearchController(searchResultsController: nil)
        search.searchBar.placeholder = Constants.shared.strings.searchTopic
        search.delegate = self
        search.searchBar.delegate = self
        return search
    }()
    
    open private(set) lazy var dataSource: DataSource = {
        let dataSource = DataSource(tableView: postList) { tableView, indexPath, item in
            switch item.postType {
            case .text, .media:
                if let cell = tableView.dequeueReusableCell(LMUIComponents.shared.postCell) {
                    cell.configure(with: item, delegate: self)
                    return cell
                }
            case .documents:
                if let cell = tableView.dequeueReusableCell(LMUIComponents.shared.documentCell) {
                    cell.configure(for: indexPath, with: item, delegate: self)
                    return cell
                }
            case .link:
                if let cell = tableView.dequeueReusableCell(LMUIComponents.shared.linkCell) {
                    cell.configure(with: item, delegate: self)
                    return cell
                }
            case .poll:
                if let cell = tableView.dequeueReusableCell(LMUIComponents.shared.pollCell) {
                    cell.configure(with: item, delegate: self)
                    return cell
                }
            default:
                return self.handleCustomWidget(with: item)
            }
            return UITableViewCell()
        }
        return dataSource
    }()
    
    
    // MARK: Data Variables
    public var data: [LMFeedPostContentModel] = []
    public var viewModel: LMFeedSearchPostViewModel?
    
    public typealias DataSource = UITableViewDiffableDataSource<String, LMFeedPostContentModel>
    public typealias Snapshot = NSDiffableDataSourceSnapshot<String, LMFeedPostContentModel>
    
    
    open func handleCustomWidget(with data: LMFeedPostContentModel) -> LMTableViewCell {
        return LMTableViewCell()
    }
    
    
    // MARK: setupViews
    open override func setupViews() {
        super.setupViews()
        
        view.addSubview(postList)
    }
    
    
    // MARK: setupLayouts
    open override func setupLayouts() {
        super.setupLayouts()
        
        view.safePinSubView(subView: postList)
    }
    
    
    // MARK: setupAppearance
    open override func setupAppearance() {
        super.setupAppearance()
        
        view.backgroundColor = Appearance.shared.colors.backgroundColor
        postList.backgroundColor = Appearance.shared.colors.clear
    }
    
    
    // MARK: viewDidLoad
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    
    // MARK: viewDidAppear
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        DispatchQueue.main.async { [weak searchController] in
            searchController?.searchBar.becomeFirstResponder()
        }
    }
    
    open func setupTableView() {
        postList.dataSource = dataSource
        postList.delegate = self
        postList.prefetchDataSource = self
    }
    
    
    public func appendPosts(with newPosts: [LMFeedPostContentModel]) {
        data.append(contentsOf: newPosts)
        applySnapshot()
    }
    
    public func updatePost(at index: Int, post: LMFeedPostContentModel) {
        guard data.indices.contains(index) else { return }
        data[index] = post
        applySnapshot()
    }
    
    public func removePost(at index: Int) {
        guard data.indices.contains(index) else { return }
        data.remove(at: index)
        applySnapshot()
    }

    public func applySnapshot(animatingDifferences: Bool = false) {
        var snapshot = Snapshot()
        
        // Append sections
        snapshot.appendSections(Array(Set(data.map { $0.postID })))

        // Append items
        for section in data {
            snapshot.appendItems([section], toSection: section.postID)
        }

        dataSource.apply(snapshot, animatingDifferences: animatingDifferences)
    }
}


// MARK: TableView
extension LMFeedSearchPostScreen: UITableViewDelegate, UITableViewDataSourcePrefetching {
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
            viewModel?.fetchPaginated()
        }
    }
    
    open func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        (cell as? LMFeedPostMediaCell)?.tableViewScrolled()
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
    
    @objc
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



// MARK: LMFeedPostDocumentCellProtocol
@objc
extension LMFeedSearchPostScreen: LMFeedLinkProtocol, LMFeedPostDocumentCellProtocol {
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
            applySnapshot()
        }
    }
    
    open func didTapDocument(with url: URL) {
        openURL(with: url)
    }
}


// MARK: LMFeedPostHeaderViewProtocol
@objc
extension LMFeedSearchPostScreen: LMFeedPostHeaderViewProtocol {
    open func didTapProfilePicture(having uuid: String) {
        showError(with: "User Profile Tapped having UUID: \(uuid)", isPopVC: false)
    }
    
    open func didTapPostMenuButton(for postID: String) {
        viewModel?.showMenu(for: postID)
    }
}


// MARK: LMFeedPostFooterViewProtocol
@objc
extension LMFeedSearchPostScreen: LMFeedPostFooterViewProtocol {
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


// MARK: LMFeedPostPollCellProtocol
@objc
extension LMFeedSearchPostScreen: LMFeedPostPollCellProtocol {
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


// MARK: UISearchControllerDelegate
extension LMFeedSearchPostScreen: UISearchBarDelegate, UISearchControllerDelegate {
    open func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        viewModel?.searchPosts(with: searchBar.text ?? "")
    }
    
    public func willDismissSearchController(_ searchController: UISearchController) {
        viewModel?.searchPosts(with: "")
    }
}


// MARK: LMFeedSearchPostViewModelProtocol
extension LMFeedSearchPostScreen: LMFeedSearchPostViewModelProtocol {
    public func navigateToPollResultScreen(with pollID: String, optionList: [LMFeedPollDataModel.Option], selectedOption: String?) {
        do {
            let viewcontroller = try LMFeedPollResultViewModel.createModule(with: pollID, optionList: optionList, selectedOption: selectedOption)
            navigationController?.pushViewController(viewcontroller, animated: true)
        } catch {
            print("Error in \(#function)")
        }
    }
    
    public func navigateToAddOptionPoll(with postID: String, pollID: String, options: [String]) {
        do {
            let viewcontroller = try LMFeedPollAddOptionViewModel.createModule(for: postID, pollID: pollID, options: options, delegate: self)
            viewcontroller.modalPresentationStyle = .overFullScreen
            present(viewcontroller, animated: false)
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    public func showLoader(isShow: Bool) {
        // TODO:
    }
    
    public func showTableFooter(isShow: Bool) {
        postList.showHideFooterLoader(isShow: isShow)
    }
    
    public func updatePostList(with post: [LMFeedPostContentModel]) {
        data.append(contentsOf: post)
        applySnapshot()
    }
    
    public func removePost(postID: String) {
        data.removeAll(where: { $0.postID == postID })
        applySnapshot()
    }
    
    public func updatePost(post: LMFeedPostContentModel) {
        guard let index = data.firstIndex(of: post) else { return }
        data[index] = post
    }
    
    public func showEmptyView() {
        // TODO:
    }
    
    public func removePreviousResults() {
        data.removeAll(keepingCapacity: true)
        applySnapshot()
    }
    
    public func navigateToDeleteScreen(for postID: String) {
        guard let viewcontroller = LMFeedDeleteViewModel.createModule(postID: postID) else { return }
        viewcontroller.modalPresentationStyle = .overFullScreen
        present(viewcontroller, animated: false)
    }
    
    public func navigateToReportScreen(for postID: String, creatorUUID: String) {
        do {
            let viewcontroller = try LMFeedReportViewModel.createModule(creatorUUID: creatorUUID, postID: postID)
            navigationController?.pushViewController(viewcontroller, animated: true)
        } catch let error {
            print(error.localizedDescription)
        }
    }
}


// MARK: LMFeedAddOptionProtocol
extension LMFeedSearchPostScreen: LMFeedAddOptionProtocol {
    public func onAddOptionResponse(postID: String, success: Bool, errorMessage: String?) {
        if !success {
            showError(with: errorMessage ?? "Something went wrong", isPopVC: false)
        } else {
            viewModel?.getPost(for: postID)
        }
    }
}
