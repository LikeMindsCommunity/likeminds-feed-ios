//
//  LMFeedLikeViewController.swift
//  Pods
//
//  Created by Devansh Mohata on 21/01/24.
//

import LikeMindsFeedUI
import UIKit

@IBDesignable
open class LMFeedLikeViewController: LMViewController {
    // MARK: UI Elements
    open private(set) lazy var tableView: LMTableView = {
        let table = LMTableView().translatesAutoresizingMaskIntoConstraints()
        table.dataSource = self
        table.delegate = self
        table.backgroundColor = Appearance.shared.colors.clear
        table.showsVerticalScrollIndicator = false
        table.showsHorizontalScrollIndicator = false
        table.bounces = false
        table.register(LMUIComponents.shared.likedUserView)
        table.separatorStyle = .none
        return table
    }()
    
    // MARK: Data Variables
    public var viewModel: LMFeedLikeViewModel?
    public var cellsData: [LMFeedLikeUserView.ContentModel] = []
    public var cellHeight: CGFloat = 72
    public var totalLikes: Int = 0
    
    
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
    
    
    // MARK: viewDidLoad
    open override func viewDidLoad() {
        super.viewDidLoad()
        viewModel?.getLikes()
        setNavigationTitleAndSubtitle(with: "Likes", subtitle: "0 Likes", alignment: .center)
        
        view.backgroundColor = Appearance.shared.colors.white
        
        // Analytics
        LMFeedCore.analytics?.trackEvent(for: .postLikeListOpened, eventProperties: ["post_id": viewModel?.postID ?? ""])
    }
    
    open func didTapUser(uuid: String) {
        showError(with: "Tapped user with uuid: \(uuid)", isPopVC: false)
    }
}


// MARK: UITableView
extension LMFeedLikeViewController: UITableViewDataSource, UITableViewDelegate {
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        cellsData.count
    }
    
    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let data = cellsData[safe: indexPath.row],
           let cell = tableView.dequeueReusableCell(LMUIComponents.shared.likedUserView.self) {
            cell.configure(with: data) { [weak self] in
                self?.didTapUser(uuid: data.uuid)
            }
            return cell
        }
        return UITableViewCell()
    }
    
    open func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == cellsData.count - 1 {
            viewModel?.getLikes()
        }
    }
    
    open func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { cellHeight }
}


// MARK: LMFeedLikeViewModelProtocol
extension LMFeedLikeViewController: LMFeedLikeViewModelProtocol {
    public func reloadTableView(with data: [LMFeedLikeUserView.ContentModel], totalCount: Int) {
        cellsData = data
        tableView.reloadData()
        totalLikes = totalCount
        setNavigationTitleAndSubtitle(with: "Likes",
                                      subtitle: "\(totalLikes) Like\(totalLikes == 1 ? "" : "s")",
                                      alignment: .center)
    }
    
    public func showHideTableLoader(isShow: Bool) {
        tableView.showHideFooterLoader(isShow: isShow)
    }
}
