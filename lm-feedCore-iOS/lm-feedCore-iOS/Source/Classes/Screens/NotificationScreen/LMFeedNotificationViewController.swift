//
//  LMFeedNotificationViewController.swift
//  lm-feedCore-iOS
//
//  Created by Devansh Mohata on 21/01/24.
//

import LikeMindsFeedUI
import UIKit

@IBDesignable
open class LMFeedNotificationViewController: LMViewController {
    // MARK: UI Elements
    open private(set) lazy var tableView: LMTableView = {
        let table = LMTableView().translatesAutoresizingMaskIntoConstraints()
        table.showsVerticalScrollIndicator = false
        table.showsHorizontalScrollIndicator = false
        table.register(LMUIComponents.shared.notificationItem)
        table.estimatedRowHeight = 50
        table.rowHeight = UITableView.automaticDimension
        table.dataSource = self
        table.delegate = self
        table.prefetchDataSource = self
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
    public var cellsData: [LMFeedNotificationItem.ContentModel] = []
    
    
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
        viewModel?.getNotifications(isInitialFetch: true)
    }
    
    
    // MARK: viewDidLoad
    open override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationTitleAndSubtitle(with: "Notifications", subtitle: nil, alignment: .center)
        tableView.refreshControl = refreshControl
        viewModel?.getNotifications(isInitialFetch: true)
        
        LMFeedCore.analytics?.trackEvent(for: .notificationPageOpened, eventProperties: [:])
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
    
    open override func showHideLoaderView(isShow: Bool, backgroundColor: UIColor) {
        if isShow {
            refreshControl.beginRefreshing()
        } else {
            refreshControl.endRefreshing()
        }
    }
}


// MARK: UITableView
extension LMFeedNotificationViewController: UITableViewDataSource, UITableViewDelegate, UITableViewDataSourcePrefetching {
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        cellsData.count
    }
    
    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let data = cellsData[safe: indexPath.row],
           let cell = tableView.dequeueReusableCell(LMUIComponents.shared.notificationItem) {
            cell.configure(with: data) { [weak self] in
                self?.viewModel?.markReadNotification(activityId: data.notificationID)
                self?.navigateToPost(from: data.route)
            }
            return cell
        }
        return UITableViewCell()
    }
    
    open func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        let count = cellsData.count
        if !indexPaths.filter({ $0.row > count }).isEmpty {
            viewModel?.getNotifications(isInitialFetch: false)
        }
    }
    
    open func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }
}

// MARK: LMFeedNotificationViewModelProtocol
extension LMFeedNotificationViewController: LMFeedNotificationViewModelProtocol {
    public func showNotifications(with data: [LMFeedNotificationItem.ContentModel], indexPath: IndexPath?) {
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
