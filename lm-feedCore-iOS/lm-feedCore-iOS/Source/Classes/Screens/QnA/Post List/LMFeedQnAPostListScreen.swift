//
//  LMFeedQnAPostListScreen.swift
//  LikeMindsFeedCore
//
//  Created by Devansh Mohata on 21/07/24.
//

import UIKit
import LikeMindsFeedUI

open class LMFeedQnAPostListScreen: LMFeedBasePostListScreen {
    // MARK: - Overridden Methods
    open override func configureTableViewCells(_ tableView: LMTableView) {
        tableView.register(LMUIComponents.shared.topicCell)
        tableView.register(LMUIComponents.shared.textCell)
        tableView.register(LMUIComponents.shared.mediaCell)
        tableView.register(LMUIComponents.shared.documentCell)
        tableView.register(LMUIComponents.shared.linkCell)
        tableView.register(LMUIComponents.shared.pollCell)
        tableView.registerHeaderFooter(LMUIComponents.shared.headerView)
        tableView.registerHeaderFooter(LMUIComponents.shared.qnaFooterView)
    }
    
    open override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = data[indexPath.section]
        let rowType = getRowType(for: indexPath.row, in: item)
        
        switch rowType {
        case .topic:
            // If the row is for text, dequeue a reusable text cell
            if let cell = tableView.dequeueReusableCell(LMUIComponents.shared.topicCell, for: indexPath) {
                // Configure the cell with the post's text data
                cell.configure(data: item)
                return cell
            }
        case .text:
            if let cell = tableView.dequeueReusableCell(LMUIComponents.shared.textCell, for: indexPath) {
                cell.configure(data: item)
                return cell
            }
        case   .media:
            if let cell = tableView.dequeueReusableCell(LMUIComponents.shared.mediaCell, for: indexPath) {
                cell.configure(with: item, delegate: self)
                return cell
            }
        case .documents:
            if let cell = tableView.dequeueReusableCell(LMUIComponents.shared.documentCell, for: indexPath) {
                cell.configure(for: indexPath, with: item, delegate: self)
                return cell
            }
        case .link:
            if let cell = tableView.dequeueReusableCell(LMUIComponents.shared.linkCell, for: indexPath) {
                cell.configure(with: item, delegate: self)
                return cell
            }
        case .poll:
            if let cell = tableView.dequeueReusableCell(LMUIComponents.shared.pollCell) {
                cell.configure(with: item, delegate: self)
                return cell
            }
        default:
            return handleCustomWidget(with: item)
        }
        
        return UITableViewCell()
    }
    
    open override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if let cellData = data[safe: section],
           let footer = tableView.dequeueReusableHeaderFooterView(LMUIComponents.shared.qnaFooterView) {
            footer.configure(with: cellData.footerData, topResponse: cellData.topResponse, postID: cellData.postID, delegate: self)
            return footer
        }
        return nil
    }
    
    public override func didTapPost(postID: String) {
        guard let viewController = LMFeedQnAPostDetailViewModel.createModule(for: postID, openCommentSection: false) else { return }
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    public override func didTapCommentButton(for postID: String) {
        guard let viewController = LMFeedQnAPostDetailViewModel.createModule(for: postID, openCommentSection: true) else { return }
        navigationController?.pushViewController(viewController, animated: true)
    }
}
