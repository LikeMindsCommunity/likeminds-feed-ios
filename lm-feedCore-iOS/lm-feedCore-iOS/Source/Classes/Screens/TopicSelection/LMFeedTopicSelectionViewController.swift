//
//  LMFeedTopicSelectionViewController.swift
//  likeminds-feed-iOS
//
//  Created by Devansh Mohata on 23/12/23.
//

import UIKit
import LikeMindsFeedUI

public protocol LMFeedTopicSelectionViewProtocol: AnyObject {
    func updateTopicFeed(with topics: [LMFeedTopicDataModel])
}

@IBDesignable
open class LMFeedTopicSelectionViewController: LMViewController {
    // MARK: UI Elements
    open private(set) lazy var containerView: LMView = {
        let view = LMView().translatesAutoresizingMaskIntoConstraints()
        view.backgroundColor = Appearance.shared.colors.clear
        return view
    }()
    
    open private(set) lazy var tableView: LMTableView = {
        let table = LMTableView(frame: .zero, style: .grouped).translatesAutoresizingMaskIntoConstraints()
        table.backgroundColor = Appearance.shared.colors.clear
        table.dataSource = self
        table.delegate = self
        table.register(LMFeedTopicSelectionCell.self)
        table.rowHeight = UITableView.automaticDimension
        table.estimatedRowHeight = 50
        table.estimatedSectionFooterHeight = .zero
        table.estimatedSectionHeaderHeight = .leastNonzeroMagnitude
        table.separatorStyle = .none
        return table
    }()
    
    open private(set) lazy var searchController: UISearchController = {
        let search = UISearchController(searchResultsController: nil)
        search.searchBar.placeholder = "Search Topic"
        search.delegate = self
        search.searchBar.delegate = self
        return search
    }()
    
    open private(set) lazy var rightBarButton: LMButton = {
        let button = LMButton().translatesAutoresizingMaskIntoConstraints()
        button.setTitle("Done", for: .normal)
        return button
    }()
    
    // MARK: Data Variables
    public var topicList: [[LMFeedTopicSelectionCell.ViewModel]] = []
    public var viewModel: LMFeedTopicSelectionViewModel?
    public var searchTimer: Timer?
    public weak var delegate: LMFeedTopicSelectionViewProtocol?
    
    // MARK: viewDidLoad
    open override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Appearance.shared.colors.backgroundColor
        setNavigationTitleAndSubtitle(with: "Select Topic", subtitle: nil, alignment: .center)
        viewModel?.getTopics(for: searchController.searchBar.text, isFreshSearch: true)
    }
    
    // MARK: setupViews
    open override func setupViews() {
        super.setupViews()
        view.addSubview(containerView)
        containerView.addSubview(tableView)
        
        navigationItem.searchController = searchController
    }
    
    
    // MARK: setupLayouts
    open override func setupLayouts() {
        super.setupLayouts()
        
        containerView.addConstraint(top: (view.safeAreaLayoutGuide.topAnchor, 0),
                                    bottom: (view.safeAreaLayoutGuide.bottomAnchor, 0),
                                    leading: (view.safeAreaLayoutGuide.leadingAnchor, 0),
                                    trailing: (view.safeAreaLayoutGuide.trailingAnchor, 0))
        containerView.pinSubView(subView: tableView)
    }
    
    
    // MARK: setupActions
    open override func setupActions() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(didTapDoneButton))
    }
    
    @objc
    open func didTapDoneButton() {
        viewModel?.didTapDoneButton()
    }
}


// MARK: UITableView
@objc
extension LMFeedTopicSelectionViewController: UITableViewDataSource, UITableViewDelegate {
    open func numberOfSections(in tableView: UITableView) -> Int {
        topicList.count
    }
    
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        topicList[safe: section]?.count ?? .zero
    }
    
    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(LMFeedTopicSelectionCell.self),
           let data = topicList[safe: indexPath.section]?[safe: indexPath.row] {
            cell.configure(with: data)
            return cell
        }
        
        return LMTableViewCell()
    }
    
    open func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? { .none }
    
    open func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat { .leastNonzeroMagnitude }
    
    open func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        section == .zero ? .init(frame: .init(x: .zero, y: .zero, width: tableView.frame.width, height: 2)) : nil
    }
    open func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        section == .zero ? 2 : .leastNonzeroMagnitude
    }
    
    open func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == topicList.count - 1 {
            viewModel?.getTopics(for: searchController.searchBar.text)
        }
    }
    
    open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel?.didSelectTopic(at: indexPath)
    }
    
    open func scrollViewDidScroll(_ scrollView: UIScrollView) {
        searchController.searchBar.endEditing(true)
    }
}


// MARK: LMFeedTopicSelectionViewModelProtocol
extension LMFeedTopicSelectionViewController: LMFeedTopicSelectionViewModelProtocol {
    public func updateTopicList(with data: [[LMFeedTopicSelectionCell.ViewModel]], selectedCount: Int) {
        self.topicList = data
        tableView.reloadData()
        
        if selectedCount == .zero {
            setNavigationTitleAndSubtitle(with: "Select Topic", subtitle: nil, alignment: .center)
        } else {
            setNavigationTitleAndSubtitle(with: "Select Topic", subtitle: "\(selectedCount) Selected", alignment: .center)
        }
    }
    
    public func updateTopicFeed(with topics: [LMFeedTopicDataModel]) {
        delegate?.updateTopicFeed(with: topics)
        navigationController?.popViewController(animated: true)
    }
}


// MARK: UISearchControllerDelegate
@objc
extension LMFeedTopicSelectionViewController: UISearchControllerDelegate, UISearchBarDelegate {
    open func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchTimer?.invalidate()
        
        searchTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { [weak self] _ in
            self?.viewModel?.getTopics(for: searchBar.text, isFreshSearch: true)
        }
    }
    
    public func willDismissSearchController(_ searchController: UISearchController) {
        searchTimer?.invalidate()
        viewModel?.getTopics(isFreshSearch: true)
    }
}
