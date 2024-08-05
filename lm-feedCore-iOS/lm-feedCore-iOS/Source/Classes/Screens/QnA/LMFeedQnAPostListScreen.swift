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
        tableView.register(LMUIComponents.shared.qnaPostCell)
        tableView.register(LMUIComponents.shared.qnaDocumentCell)
        tableView.register(LMUIComponents.shared.qnaLinkCell)
        tableView.register(LMUIComponents.shared.qnaPollCell)
        tableView.registerHeaderFooter(LMUIComponents.shared.headerView)
        tableView.registerHeaderFooter(LMUIComponents.shared.qnaFooterView)
    }
    
    open override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = data[indexPath.section]
        
        switch item.postType {
        case .text, .media:
            if let cell = tableView.dequeueReusableCell(LMUIComponents.shared.qnaPostCell, for: indexPath) {
                cell.configure(with: item, delegate: self)
                return cell
            }
        case .documents:
            if let cell = tableView.dequeueReusableCell(LMUIComponents.shared.qnaDocumentCell, for: indexPath) {
                cell.configure(for: indexPath, with: item, delegate: self)
                return cell
            }
        case .link:
            if let cell = tableView.dequeueReusableCell(LMUIComponents.shared.qnaLinkCell, for: indexPath) {
                cell.configure(with: item, delegate: self)
                return cell
            }
        case .poll:
            if let cell = tableView.dequeueReusableCell(LMUIComponents.shared.qnaPollCell) {
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
            footer.configure(with: cellData.footerData, postID: cellData.postID, delegate: self)
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
