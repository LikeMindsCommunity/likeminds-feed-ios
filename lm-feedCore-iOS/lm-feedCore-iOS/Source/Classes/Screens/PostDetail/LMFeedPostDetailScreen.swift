//
//  LMFeedPostDetailScreen.swift
//  LMFramework
//
//  Created by Devansh Mohata on 15/12/23.
//

import LikeMindsFeedUI
import UIKit

open class LMFeedPostDetailScreen: LMFeedBasePostDetailScreen {
    open override func setupTableView(_ table: UITableView) {
        table.register(LMUIComponents.shared.postDetailMediaCell)
        table.register(LMUIComponents.shared.postDetailLinkCell)
        table.register(LMUIComponents.shared.postDetailDocumentCell)
        table.register(LMUIComponents.shared.postDetailPollCell)
        table.register(LMUIComponents.shared.replyView)
        table.registerHeaderFooter(LMUIComponents.shared.loadMoreReplies)
        table.registerHeaderFooter(LMUIComponents.shared.commentView)
        table.registerHeaderFooter(LMUIComponents.shared.postDetailHeaderView)
        table.registerHeaderFooter(LMUIComponents.shared.postDetailFooterView)
    }
    
    open override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0,
           let postData {
            switch postData.postType {
            case .text, .media:
                if let cell = tableView.dequeueReusableCell(LMUIComponents.shared.postDetailMediaCell) {
                    cell.configure(with: postData, delegate: self)
                    return cell
                }
            case .link:
                if let cell = tableView.dequeueReusableCell(LMUIComponents.shared.postDetailLinkCell) {
                    cell.configure(with: postData, delegate: self)
                    return cell
                }
            case .documents:
                if let cell = tableView.dequeueReusableCell(LMUIComponents.shared.postDetailDocumentCell) {
                    cell.configure(for: indexPath, with: postData, delegate: self)
                    return cell
                }
            case .poll:
                if let cell = tableView.dequeueReusableCell(LMUIComponents.shared.postDetailPollCell) {
                    cell.configure(with: postData, delegate: self)
                    return cell
                }
            default:
                break
            }
        } else if let data = commentsData[safe: indexPath.section - 1],
                  let cell = tableView.dequeueReusableCell(LMUIComponents.shared.replyView) {
            let comment = data.replies[indexPath.row]
            cell.configure(with: comment, delegate: self, indexPath: indexPath)
            return cell
        }
        
        return UITableViewCell()
    }
    
    open override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section == 0,
           let postData,
           let footer = tableView.dequeueReusableHeaderFooterView(LMUIComponents.shared.postDetailFooterView) {
            footer.configure(with: postData.footerData, postID: postData.postID, delegate: self, commentCount: postData.totalCommentCount)
            return footer
        } else if let data = commentsData[safe: section - 1],
                  data.repliesCount != 0,
                  data.repliesCount < data.totalReplyCount,
                  let footer = tableView.dequeueReusableHeaderFooterView(LMUIComponents.shared.loadMoreReplies) {
            footer.configure(with: data.totalReplyCount, visibleComments: data.repliesCount) { [weak self] in
                guard let commentID = data.commentId else { return }
                self?.viewModel?.getCommentReplies(commentId: commentID, isClose: false)
            }
            
            return footer
        }
        return nil
    }
}
