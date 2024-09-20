//
//  LMFeedQnASearchPostScreen.swift
//  LikeMindsFeedCore
//
//  Created by Devansh Mohata on 06/08/24.
//

import LikeMindsFeedUI
import UIKit

open class LMFeedQnASearchPostScreen: LMFeedBaseSearchPostScreen {
    open override func setupTableView(_ tableView: LMTableView) {
        super.setupTableView(tableView)
        tableView.register(LMUIComponents.shared.topicCell)
        tableView.register(LMUIComponents.shared.textCell)
        tableView.register(LMUIComponents.shared.mediaCell)
        tableView.register(LMUIComponents.shared.documentCell)
        tableView.register(LMUIComponents.shared.linkCell)
        tableView.register(LMUIComponents.shared.pollCell)
        tableView.registerHeaderFooter(LMUIComponents.shared.headerView)
        tableView.registerHeaderFooter(LMUIComponents.shared.qnaFooterView)
    }
    
    open override func cellForItem(tableView: UITableView, indexPath: IndexPath, item: LMFeedPostContentModel) -> UITableViewCell {
        // Fetch the item (post) corresponding to the section
        let item = data[indexPath.section]
        
        // Determine the type of row (text, media, documents, link, or poll) based on its position within the section
        let rowType = getRowType(for: indexPath.row, in: item)
        
        // Switch based on the type of content to return the appropriate cell
        switch rowType {
        case .topic:
                   // If the row is for text, dequeue a reusable text cell
                   if let cell = tableView.dequeueReusableCell(LMUIComponents.shared.topicCell, for: indexPath) {
                       // Configure the cell with the post's text data
                       cell.configure(data: item)
                       return cell
                   }
        case .text:
            if let cell = tableView.dequeueReusableCell(LMUIComponents.shared.textCell) {
                cell.configure(data: item)
                return cell
            }
        case .media:
            if let cell = tableView.dequeueReusableCell(LMUIComponents.shared.mediaCell) {
                cell.configure(with: item, delegate: self)
                return cell
            }
        case .documents:
            if let cell = tableView.dequeueReusableCell(LMUIComponents.shared.documentCell) {
                cell.configure(for: indexPath, with: item, delegate: self)
                return cell
            }
        case .link:
            if let cell = tableView.dequeueReusableCell(LMUIComponents.shared.linkCell) {
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
