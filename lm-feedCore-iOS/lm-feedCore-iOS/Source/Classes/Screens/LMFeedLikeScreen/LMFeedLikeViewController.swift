//
//  LMFeedLikeViewController.swift
//  Pods
//
//  Created by Devansh Mohata on 21/01/24.
//

import lm_feedUI_iOS
import UIKit

@IBDesignable
open class LMFeedLikeViewController: LMViewController {
    // MARK: UI Elements
    open private(set) lazy var tableView: LMTableView = {
        let table = LMTableView().translatesAutoresizingMaskIntoConstraints()
        table.dataSource = self
        table.delegate = self
        table.showsVerticalScrollIndicator = false
        table.showsHorizontalScrollIndicator = false
        table.bounces = false
        table.register(LMUIComponents.shared.likedUserTableCell)
        table.separatorStyle = .none
        return table
    }()
    
    // MARK: Data Variables
    public var viewModel: LMFeedLikeViewModel?
    public var cellsData: [LMFeedLikeUserTableCell.ViewModel] = []
    public var cellHeight: CGFloat = 72
    public var totalLikes: Int = 0 {
        didSet {
            setNavigationTitleAndSubtitle(with: "Likes", subtitle: "\(totalLikes) Likes")
        }
    }
    
    
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
        setNavigationTitleAndSubtitle(with: "Likes", subtitle: "0 Likes")
    }
    
    open func didTapUser(uuid: String) {
        print(uuid)
    }
}


// MARK: UITableView
extension LMFeedLikeViewController: UITableViewDataSource, UITableViewDelegate {
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        cellsData.count
    }
    
    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(LMUIComponents.shared.likedUserTableCell.self),
           let data = cellsData[safe: indexPath.row] {
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
    public func reloadTableView(with data: [LMFeedLikeUserTableCell.ViewModel], totalCount: Int) {
        cellsData = data
        tableView.reloadData()
        totalLikes = totalCount
    }
    
    public func showHideTableLoader(isShow: Bool) {
        tableView.showHideFooterLoader(isShow: isShow)
    }
    
    public func showError(with message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        
        alert.addAction(.init(title: "OK", style: .default) { _ in
            self.navigationController?.popViewController(animated: true)
        })
        
        presentAlert(with: alert)
    }
}
