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
    func openPostDetail(for postID: String)
    func openUserDetail(for uuid: String)
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
        return table
    }()
    
    open private(set) lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        return refreshControl
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
    
    open override func setupLayouts() {
        super.setupLayouts()
        
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    open override func setupActions() {
        super.setupActions()
        
        // Setting Table View
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false
        tableView.rowHeight = UITableView.automaticDimension
        tableView.register(LMUIComponents.shared.postCell)
        tableView.register(LMUIComponents.shared.documentCell)
        tableView.register(LMUIComponents.shared.linkCell)
        tableView.refreshControl = refreshControl
        
        refreshControl.addTarget(self, action: #selector(pullToRefresh), for: .valueChanged)
    }
    
    @objc
    open func pullToRefresh() {
        refreshControl.endRefreshing()
        viewModel?.getFeed(fetchInitialPage: true)
    }
    
    open override func setupAppearance() {
        super.setupAppearance()
        view.backgroundColor = Appearance.shared.colors.backgroundColor
        tableView.backgroundColor = Appearance.shared.colors.clear
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        viewModel?.getFeed()
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tableView.visibleCells.forEach { cell in
            (cell as? LMFeedPostMediaCell)?.resetPlayerInstance()
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
        if data.count == indexPath.row - 1 {
            viewModel?.getFeed()
        }
    }
}


// MARK: LMFeedTableCellToViewControllerProtocol
@objc
extension LMFeedPostListViewController: LMFeedTableCellToViewControllerProtocol {
    open func didTapProfilePicture(for uuid: String) {
        delegate?.openUserDetail(for: uuid)
    }
    
    open func didTapMenuButton(postID: String) {
        print(#function)
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
        print(#function)
    }
    
    open func didTapCommentButton(for postID: String) {
        print(#function)
    }
    
    open func didTapShareButton(for postID: String) {
        print(#function)
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
        delegate?.openPostDetail(for: postID)
    }
}


// MARK: LMFeedPostDocumentCellProtocol
@objc
extension LMFeedPostListViewController: LMFeedPostDocumentCellProtocol {
    open func didTapShowMoreDocuments(for indexPath: IndexPath) {
        print(#function)
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
    public func loadPosts(with data: [LMFeedPostTableCellProtocol]) {
        self.data = data
        tableView.refreshControl?.endRefreshing()
        tableView.reloadData()
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
}


// MARK: LMFeedPostListVCToProtocol
@objc
extension LMFeedPostListViewController: LMFeedPostListVCToProtocol {
    open func loadPostsWithTopics(_ topics: [String]) {
        viewModel?.updateTopics(with: topics)
    }
}
