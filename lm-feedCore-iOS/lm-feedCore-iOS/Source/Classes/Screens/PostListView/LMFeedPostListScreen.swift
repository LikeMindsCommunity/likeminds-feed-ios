//
//  LMFeedPostListScreen.swift
//  likeminds-feed-iOS
//
//  Created by Devansh Mohata on 02/01/24.
//

import UIKit
import LikeMindsFeedUI

open class LMFeedPostListScreen: LMFeedBasePostListScreen {
    // MARK: - Overridden Methods
    open override func configureTableViewCells(_ tableView: LMTableView) {
        tableView.register(LMUIComponents.shared.topicCell)
        tableView.register(LMUIComponents.shared.textCell)
        tableView.register(LMUIComponents.shared.mediaCell)
        tableView.register(LMUIComponents.shared.documentCell)
        tableView.register(LMUIComponents.shared.linkCell)
        tableView.register(LMUIComponents.shared.pollCell)
        tableView.registerHeaderFooter(LMUIComponents.shared.headerView)
        tableView.registerHeaderFooter(LMUIComponents.shared.footerView)
    }
    
    open override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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
            // If the row is for text, dequeue a reusable text cell
            if let cell = tableView.dequeueReusableCell(LMUIComponents.shared.textCell, for: indexPath) {
                // Configure the cell with the post's text data
                cell.configure(data: item)
                return cell
            }
        case .media:
            // If the row is for media, dequeue a reusable media cell
            if let cell = tableView.dequeueReusableCell(LMUIComponents.shared.mediaCell, for: indexPath) {
                // Configure the cell with the media data and assign a delegate (usually the view controller)
                cell.configure(with: item, delegate: self)
                return cell
            }
        case .documents:
            // If the row is for documents, dequeue a reusable document cell
            if let cell = tableView.dequeueReusableCell(LMUIComponents.shared.documentCell, for: indexPath) {
                // Configure the cell with the document data and assign a delegate
                cell.configure(for: indexPath, with: item, delegate: self)
                return cell
            }
        case .link:
            // If the row is for a link, dequeue a reusable link cell
            if let cell = tableView.dequeueReusableCell(LMUIComponents.shared.linkCell, for: indexPath) {
                // Configure the cell with the link data and assign a delegate
                cell.configure(with: item, delegate: self)
                return cell
            }
        case .poll:
            // If the row is for a poll, dequeue a reusable poll cell
            if let cell = tableView.dequeueReusableCell(LMUIComponents.shared.pollCell) {
                // Configure the cell with the poll data and assign a delegate
                cell.configure(with: item, delegate: self)
                return cell
            }
        default:
            // For any other type of content, handle it with a custom widget
            return handleCustomWidget(with: item)
        }
        
        // Return an empty cell in case no valid cell is dequeued (this should rarely happen)
        return UITableViewCell()
    }
    
    
    open override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if let cellData = data[safe: section],
           let footer = tableView.dequeueReusableHeaderFooterView(LMUIComponents.shared.footerView) {
            footer.configure(with: cellData.footerData, topResponse: cellData.topResponse, postID: cellData.postID, delegate: self)
            return footer
        }
        return nil
    }
    
    public override func didTapPost(postID: String) {
        guard let viewController = LMFeedPostDetailViewModel.createModule(for: postID, openCommentSection: false) else { return }
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    public override func didTapCommentButton(for postID: String) {
        guard let viewController = LMFeedPostDetailViewModel.createModule(for: postID, openCommentSection: true) else { return }
        navigationController?.pushViewController(viewController, animated: true)
    }
    
}
