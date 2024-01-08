//
//  LMFeedTaggingView.swift
//  lm-feedUI-iOS
//
//  Created by Devansh Mohata on 07/01/24.
//

import UIKit

@IBDesignable
open class LMFeedTaggingView: LMView {
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
        table.register(LMUIComponents.shared.taggingTableViewCell)
        return table
    }()
    
    // MARK: Data Variables
    public var cellHeight: CGFloat = 64
    public var taggingCellsData: [LMFeedTaggingUserTableCell.ViewModel] = []
    
    open override func setupViews() {
        super.setupViews()
        
        addSubview(containerView)
        containerView.addSubview(tableView)
    }
    
    open override func setupLayouts() {
        super.setupLayouts()
        
        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            tableView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: containerView.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
    }
    
    open override func setupAppearance() {
        super.setupAppearance()
        
        containerView.roundCorners([.layerMinXMinYCorner, .layerMaxXMinYCorner], with: 16)
    }
}


extension LMFeedTaggingView: UITableViewDataSource, UITableViewDelegate {
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        taggingCellsData.count
    }
    
    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(LMUIComponents.shared.taggingTableViewCell),
           let data = taggingCellsData[safe: indexPath.row] {
            cell.configure(with: data) { route in
                print(route)
            }
        }
        
        return UITableViewCell()
    }
    
    open func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { cellHeight }
}
