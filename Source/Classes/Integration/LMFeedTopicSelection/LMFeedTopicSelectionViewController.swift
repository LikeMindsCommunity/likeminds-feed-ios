//
//  LMFeedTopicSelectionViewController.swift
//  likeminds-feed-iOS
//
//  Created by Devansh Mohata on 23/12/23.
//

import UIKit

@IBDesignable
open class LMFeedTopicSelectionViewController: LMViewController {
    // MARK: UI Elements
    open private(set) lazy var containerView: LMView = {
        let view = LMView().translatesAutoresizingMaskIntoConstraints()
        view.backgroundColor = Appearance.shared.colors.backgroundColor
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
    
    
    // MARK: Data Variables
    public var topicList: [[LMFeedTopicSelectionCell.ViewModel]] = []
    
    
    // MARK: viewDidLoad
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        topicList.append([.init(topic: "All Topics", topicID: nil, isSelected: true)])
        
        topicList.append([.init(topic: "Topic #1", topicID: "Topic#1", isSelected: false),
                          .init(topic: "Topic #2", topicID: "Topic#2", isSelected: false),
                          .init(topic: "Topic #3", topicID: "Topic#3", isSelected: false)])
        
        tableView.reloadData()
    }
    
    // MARK: setupViews
    open override func setupViews() {
        super.setupViews()
        view.addSubview(containerView)
        containerView.addSubview(tableView)
    }
    
    
    // MARK: setupLayouts
    open override func setupLayouts() {
        super.setupLayouts()
        
        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            containerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            containerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            tableView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: containerView.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
    }
    
    
    // MARK: configure
    open func configure(with topicList: [[LMFeedTopicSelectionCell.ViewModel]]) {
        self.topicList = topicList
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
}
