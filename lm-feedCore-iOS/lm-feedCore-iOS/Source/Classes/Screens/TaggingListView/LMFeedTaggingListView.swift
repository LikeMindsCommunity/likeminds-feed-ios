//
//  LMFeedTaggingListView.swift
//  lm-feedCore-iOS
//
//  Created by Devansh Mohata on 11/01/24.
//

import LikeMindsFeedUI
import UIKit

public protocol LMFeedTaggedUserFoundProtocol: AnyObject {
    func userSelected(with route: String, and userName: String)
    func updateHeight(with height: CGFloat)
}

public protocol LMFeedTaggingProtocol: AnyObject {
    func fetchUsers(for searchString: String)
}

@IBDesignable
open class LMFeedTaggingListView: LMView {
    // MARK: UI Elements
    open private(set) lazy var containerView: LMView = {
        let view = LMView().translatesAutoresizingMaskIntoConstraints()
        return view
    }()
    
    open private(set) lazy var tableView: LMTableView = {
        let table = LMTableView().translatesAutoresizingMaskIntoConstraints()
        table.dataSource = self
        table.delegate = self
        table.showsVerticalScrollIndicator = false
        table.clipsToBounds = true
        table.separatorStyle = .none
        table.rowHeight = UITableView.automaticDimension
        table.register(LMUIComponents.shared.taggingUserView)
        return table
    }()
    
    
    // MARK: Data Variables
    public let cellHeight: CGFloat = 60
    public var taggingCellsData: [LMFeedTaggingUserView.ContentModel] = []
    public var viewModel: LMFeedTaggingListViewModel?
    public weak var delegate: LMFeedTaggedUserFoundProtocol?
    
    
    // MARK: setupViews
    open override func setupViews() {
        super.setupViews()
        addSubview(containerView)
        containerView.addSubview(tableView)
    }
    
    
    // MARK: setupLayouts
    open override func setupLayouts() {
        super.setupLayouts()
        pinSubView(subView: containerView)
        containerView.pinSubView(subView: tableView)
    }
    
    
    // MARK: setupAppearance
    open override func setupAppearance() {
        super.setupAppearance()
        backgroundColor = Appearance.shared.colors.clear
        containerView.backgroundColor = Appearance.shared.colors.clear
        containerView.layer.borderColor = Appearance.shared.colors.gray4.cgColor
        containerView.layer.borderWidth = 1
        tableView.backgroundColor = Appearance.shared.colors.white
    }
    
    
    // MARK: Get Users
    public func getUsers(for searchString: String) {
        viewModel?.fetchUsers(with: searchString)
    }
    
    public func stopFetchingUsers() {
        viewModel?.stopFetchingUsers()
    }
}


// MARK: UITableView
extension LMFeedTaggingListView: UITableViewDataSource, UITableViewDelegate {
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        taggingCellsData.count
    }
    
    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(LMUIComponents.shared.taggingUserView),
           let data = taggingCellsData[safe: indexPath.row] {
            cell.configure(with: data)
            return cell
        }
        
        return UITableViewCell()
    }
    
    open func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { cellHeight }
    
    open func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if taggingCellsData.count - 1 == indexPath.row {
            viewModel?.fetchMoreUsers()
        }
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let user = taggingCellsData[safe: indexPath.row] {
            delegate?.userSelected(with: user.route, and: user.userName)
        }
    }
}


// MARK: LMFeedTaggingListViewModelProtocol
extension LMFeedTaggingListView: LMFeedTaggingListViewModelProtocol {
    public func updateList(with users: [LMFeedTaggingUserView.ContentModel]) {
        taggingCellsData.removeAll(keepingCapacity: true)
        taggingCellsData.append(contentsOf: users)
        tableView.reloadData()
        delegate?.updateHeight(with: min(tableView.tableViewHeight, cellHeight * 4))
    }
}


// MARK: LMFeedTaggingProtocol
extension LMFeedTaggingListView: LMFeedTaggingProtocol {
    public func fetchUsers(for searchString: String) {
        viewModel?.fetchUsers(with: searchString)
    }
}
