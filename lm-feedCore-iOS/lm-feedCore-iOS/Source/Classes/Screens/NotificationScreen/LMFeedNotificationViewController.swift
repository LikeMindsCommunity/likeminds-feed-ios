//
//  LMFeedNotificationViewController.swift
//  lm-feedCore-iOS
//
//  Created by Devansh Mohata on 21/01/24.
//

import lm_feedUI_iOS
import UIKit

@IBDesignable
open class LMFeedNotificationViewController: LMViewController {
    // MARK: UI Elements
    open private(set) lazy var tableView: LMTableView = {
        let table = LMTableView().translatesAutoresizingMaskIntoConstraints()
        table.showsVerticalScrollIndicator = false
        table.showsHorizontalScrollIndicator = false
        table.register(LMUIComponents.shared.notificationTableCell)
        table.estimatedRowHeight = 50
        table.rowHeight = UITableView.automaticDimension
        table.dataSource = self
        table.delegate = self
        table.separatorStyle = .none
        return table
    }()
    
    
    // MARK: Data Variables
    public var viewModel: LMFeedNotificationViewModel?
    public var cellsData: [LMFeedNotificationView.ViewModel] = []
    
    open override func setupViews() {
        super.setupViews()
        view.addSubview(tableView)
    }
    
    open override func setupLayouts() {
        super.setupLayouts()
        view.pinSubView(subView: tableView)
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationTitleAndSubtitle(with: "Notifications", subtitle: nil, alignment: .center)
        viewModel?.getNotifications(isInitialFetch: true)
    }
}


// MARK: UITableView
extension LMFeedNotificationViewController: UITableViewDataSource, UITableViewDelegate {
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        cellsData.count
    }
    
    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(LMUIComponents.shared.notificationTableCell),
           let data = cellsData[safe: indexPath.row] {
            cell.configure(with: data)
            return cell
        }
        return UITableViewCell()
    }
    
    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == cellsData.count - 1 {
            viewModel?.getNotifications(isInitialFetch: false)
        }
    }
}

// MARK: LMFeedNotificationViewModelProtocol
extension LMFeedNotificationViewController: LMFeedNotificationViewModelProtocol {
    public func showNotifications(with data: [LMFeedNotificationView.ViewModel]) {
        cellsData = data
        tableView.reloadData()
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
