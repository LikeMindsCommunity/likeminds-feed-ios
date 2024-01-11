//
//  LMFeedTaggingListView.swift
//  lm-feedCore-iOS
//
//  Created by Devansh Mohata on 11/01/24.
//

import lm_feedUI_iOS
import UIKit

public protocol LMFeedTaggedUserFoundProtocol: AnyObject {
    func userSelected(with route: String)
    func updateHeight(with height: CGFloat)
}

public protocol LMFeedTaggingProtocol: AnyObject {
    func fetchUsers(for searchString: String)
}

@IBDesignable
open class LMFeedTaggingListView: LMViewController {
    // MARK: UI Elements
    open private(set) lazy var tableView: LMTableView = {
        let table = LMTableView().translatesAutoresizingMaskIntoConstraints()
        table.dataSource = self
        table.delegate = self
        table.showsVerticalScrollIndicator = false
        table.clipsToBounds = true
        table.register(LMUIComponents.shared.taggingTableViewCell)
        return table
    }()
    
    
    // MARK: Data Variables
    public let cellHeight: CGFloat = 64
    public var taggingCellsData: [LMFeedTaggingUserTableCell.ViewModel] = []
    public var viewModel: LMFeedTaggingListViewModel?
    public weak var delegate: LMFeedTaggedUserFoundProtocol?
    
    
    // MARK: setupViews
    open override func setupViews() {
        super.setupViews()
        
        view.addSubview(tableView)
    }
    
    
    // MARK: setupLayouts
    open override func setupLayouts() {
        super.setupLayouts()
        
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    
    // MARK: Get Users
    public func getUsers(for searchString: String) {
        viewModel?.fetchUsers(with: searchString)
    }
    
    public func stopFetchingUsers() {
        
    }
}


// MARK: UITableView
extension LMFeedTaggingListView: UITableViewDataSource, UITableViewDelegate {
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        taggingCellsData.count
    }
    
    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(LMUIComponents.shared.taggingTableViewCell),
           let data = taggingCellsData[safe: indexPath.row] {
            cell.configure(with: data) { [weak self] route in
                self?.delegate?.userSelected(with: route)
            }
        }
        
        return UITableViewCell()
    }
    
    open func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { cellHeight }
    
    open func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if taggingCellsData.count - 1 == indexPath.row {
            viewModel?.fetchMoreUsers()
        }
    }
}


// MARK: LMFeedTaggingListViewModelProtocol
extension LMFeedTaggingListView: LMFeedTaggingListViewModelProtocol {
    public func updateList(with users: [LMFeedTaggingUserTableCell.ViewModel]) {
        taggingCellsData.removeAll()
        taggingCellsData.append(contentsOf: users)
        tableView.reloadData()
        delegate?.updateHeight(with: min(tableView.tableViewHeight, cellHeight * 5))
    }
}


// MARK: LMFeedTaggingProtocol
extension LMFeedTaggingListView: LMFeedTaggingProtocol {
    public func fetchUsers(for searchString: String) {
        viewModel?.fetchUsers(with: searchString)
    }
}
