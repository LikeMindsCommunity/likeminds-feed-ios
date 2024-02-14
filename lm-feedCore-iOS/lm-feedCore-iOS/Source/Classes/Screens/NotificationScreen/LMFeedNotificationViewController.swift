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
    
    open private(set) lazy var refreshControl: UIRefreshControl = UIRefreshControl()
    
    open private(set) lazy var emptyNotificationView: LMFeedEmptyNotificationView = {
        let view = LMFeedEmptyNotificationView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // MARK: Data Variables
    public var viewModel: LMFeedNotificationViewModel?
    public var cellsData: [LMFeedNotificationView.ViewModel] = []
    
    
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
        refreshControl.addTarget(self, action: #selector(pullToRefresh), for: .valueChanged)
    }
    
    @objc
    open func pullToRefresh(_ refreshControl: UIRefreshControl) {
        refreshControl.endRefreshing()
        viewModel?.getNotifications(isInitialFetch: true)
    }
    
    
    // MARK: viewDidLoad
    open override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationTitleAndSubtitle(with: "Notifications", subtitle: nil, alignment: .center)
        tableView.refreshControl = refreshControl
        viewModel?.getNotifications(isInitialFetch: true)
        
        LMFeedMain.analytics?.trackEvent(for: .notificationPageOpened, eventProperties: [:])
    }
    
    public func navigateToPost(from route: String) {
        LMFeedRouter.fetchRoute(from: route) { result in
            switch result {
            case .success(let viewcontroller):
                navigationController?.pushViewController(viewcontroller, animated: true)
            case .failure(let error):
                print(error)
            }
        }
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
            cell.configure(with: data) { [weak self] in
                self?.viewModel?.markReadNotification(activityId: data.notificationID)
                self?.navigateToPost(from: data.route)
            }
            return cell
        }
        return UITableViewCell()
    }
    
    open func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == cellsData.count - 1 {
            viewModel?.getNotifications(isInitialFetch: false)
        }
    }
}

// MARK: LMFeedNotificationViewModelProtocol
extension LMFeedNotificationViewController: LMFeedNotificationViewModelProtocol {
    public func showNotifications(with data: [LMFeedNotificationView.ViewModel], indexPath: IndexPath?) {
        tableView.backgroundView = nil
        cellsData = data
        
        if let indexPath {
            tableView.reloadRows(at: [indexPath], with: .none)
        } else {
            tableView.reloadData()
        }
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
    
    public func showEmptyNotificationView() {
        tableView.backgroundView = emptyNotificationView
        emptyNotificationView.heightAnchor.constraint(equalTo: tableView.heightAnchor, multiplier: 1).isActive = true
        emptyNotificationView.widthAnchor.constraint(equalTo: tableView.widthAnchor, multiplier: 1).isActive = true
    }
}
