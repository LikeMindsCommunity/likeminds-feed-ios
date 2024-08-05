//
//  LMFeedQnAPostDetailScreen.swift
//  LikeMindsFeedCore
//
//  Created by Devansh Mohata on 31/07/24.
//

import LikeMindsFeedUI
import UIKit

open class LMFeedQnAPostDetailScreen: LMFeedBasePostDetailScreen {
    open override func setupTableView(_ table: UITableView) {
        table.register(LMUIComponents.shared.qnaPostCell)
        table.register(LMUIComponents.shared.qnaLinkCell)
        table.register(LMUIComponents.shared.qnaDocumentCell)
        table.register(LMUIComponents.shared.qnaPollCell)
        table.register(LMUIComponents.shared.replyView)
        table.registerHeaderFooter(LMUIComponents.shared.loadMoreReplies)
        table.registerHeaderFooter(LMUIComponents.shared.commentView)
        table.registerHeaderFooter(LMUIComponents.shared.postDetailHeaderView)
        table.registerHeaderFooter(LMUIComponents.shared.qnaFooterDetailView)
    }
    
    open override func cellForPost(tableView: UITableView, indexPath: IndexPath, post: LMFeedPostContentModel) -> UITableViewCell {
        switch post.postType {
        case .text, .media:
            if let cell = tableView.dequeueReusableCell(LMUIComponents.shared.qnaPostCell) {
                cell.configure(with: postData, delegate: self)
                return cell
            }
        case .link:
            if let cell = tableView.dequeueReusableCell(LMUIComponents.shared.qnaLinkCell) {
                cell.configure(with: postData, delegate: self)
                return cell
            }
        case .documents:
            if let cell = tableView.dequeueReusableCell(LMUIComponents.shared.qnaDocumentCell) {
                cell.configure(for: indexPath, with: postData, delegate: self)
                return cell
            }
        case .poll:
            if let cell = tableView.dequeueReusableCell(LMUIComponents.shared.qnaPollCell) {
                cell.configure(with: postData, delegate: self)
                return cell
            }
        default:
            return handleCustomCell(tableView: tableView, indexPath: indexPath, post: post)
        }
        
        return UITableViewCell()
    }
    
    open override func cellForReply(tableView: UITableView, indexPath: IndexPath, reply: LMFeedCommentContentModel) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(LMUIComponents.shared.replyView) {
            cell.configure(with: reply, delegate: self, indexPath: indexPath)
            return cell
        }
        
        return UITableViewCell()
    }
    
    open override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section == 0,
           let postData,
           let footer = tableView.dequeueReusableHeaderFooterView(LMUIComponents.shared.qnaFooterDetailView) {
            footer.configure(with: postData.footerData, postID: postData.postID, delegate: self)
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
