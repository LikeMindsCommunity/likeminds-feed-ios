//
//  LMFeedSearchPostScreen.swift
//  LikeMindsFeedCore
//
//  Created by Devansh Mohata on 29/06/24.
//

import LikeMindsFeedUI
import UIKit

open class LMFeedSearchPostScreen: LMFeedBaseSearchPostScreen {
    
    open override func setupTableView(_ tableView: LMTableView) {
        super.setupTableView(tableView)
        
        tableView.register(LMUIComponents.shared.mediaCell)
        tableView.register(LMUIComponents.shared.documentCell)
        tableView.register(LMUIComponents.shared.linkCell)
        tableView.register(LMUIComponents.shared.pollCell)
        tableView.registerHeaderFooter(LMUIComponents.shared.headerView)
        tableView.registerHeaderFooter(LMUIComponents.shared.footerView)
    }
    
    open override func cellForItem(tableView: UITableView, indexPath: IndexPath, item: LMFeedPostContentModel) -> UITableViewCell {
        switch item.postType {
        case .text, .media:
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
           let footer = tableView.dequeueReusableHeaderFooterView(LMUIComponents.shared.footerView) {
            footer.configure(with: cellData.footerData, postID: cellData.postID, delegate: self)
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
