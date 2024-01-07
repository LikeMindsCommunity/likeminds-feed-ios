//
//  LMFeedPostDetailViewController.swift
//  LMFramework
//
//  Created by Devansh Mohata on 15/12/23.
//

import lm_feedUI_iOS
import UIKit

@IBDesignable
open class LMFeedPostDetailViewController: LMViewController {
    // MARK: UI Elements
    open private(set) lazy var tableView: LMTableView = {
        let table = LMTableView(frame: .zero, style: .grouped).translatesAutoresizingMaskIntoConstraints()
        table.separatorStyle = .none
        table.showsVerticalScrollIndicator = false
        table.showsHorizontalScrollIndicator = false
        table.bounces = false
        table.estimatedRowHeight = 50
        table.rowHeight = UITableView.automaticDimension
        table.estimatedSectionHeaderHeight = 1
        table.sectionHeaderHeight = UITableView.automaticDimension
        table.sectionFooterHeight = .zero
        table.contentInset = .init(top: -20, left: .zero, bottom: .zero, right: .zero)
        return table
    }()
        
    let containerView: LMView = {
        let view = LMView().translatesAutoresizingMaskIntoConstraints()
        view.backgroundColor = Appearance.shared.colors.white
        return view
    }()
    
    let stackView: LMStackView = {
        let stack = LMStackView().translatesAutoresizingMaskIntoConstraints()
        stack.axis = .horizontal
        stack.alignment = .center
        stack.distribution = .fill
        stack.backgroundColor = Appearance.shared.colors.clear
        return stack
    }()
    
    let inputTextView: LMTextView = {
        let textView = LMTextView().translatesAutoresizingMaskIntoConstraints()
        textView.isEditable = true
        textView.isScrollEnabled = false
        textView.backgroundColor = Appearance.shared.colors.clear
        textView.textColor = Appearance.shared.colors.textColor
        textView.contentMode = .center
        textView.font = Appearance.shared.fonts.textFont1
        return textView
    }()
    
    let sendButton: LMButton = {
        let button = LMButton().translatesAutoresizingMaskIntoConstraints()
        button.setTitle(nil, for: .normal)
        button.setImage(Constants.shared.images.planeIconFilled, for: .normal)
        button.tintColor = Appearance.shared.colors.appTintColor
        button.isEnabled = false
        return button
    }()

    open var inputTextViewHeightConstraint: NSLayoutConstraint?
    open var inputTextViewBottomConstraint: NSLayoutConstraint?
    
    
    // MARK: Data Variables
    var postData: LMFeedPostTableCellProtocol?
    var cellsData: [LMFeedPostCommentCellProtocol] = []
    open private(set) var textInputMaximumHeight: CGFloat = 100
    public var viewModel: LMFeedPostDetailViewModel?
    
    
    // MARK: setupViews
    open override func setupViews() {
        super.setupViews()
        
        view.addSubview(tableView)
        view.addSubview(containerView)
        
        containerView.addSubview(stackView)
        
        stackView.addArrangedSubview(inputTextView)
        stackView.addArrangedSubview(sendButton)
    }
    
    
    // MARK: setupLayouts
    open override func setupLayouts() {
        super.setupLayouts()
        
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            
            containerView.topAnchor.constraint(equalTo: tableView.bottomAnchor),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            stackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            stackView.topAnchor.constraint(equalTo: containerView.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            
            inputTextView.topAnchor.constraint(equalTo: stackView.topAnchor),
            inputTextView.bottomAnchor.constraint(equalTo: stackView.bottomAnchor),
            
            sendButton.topAnchor.constraint(greaterThanOrEqualTo: stackView.topAnchor),
            sendButton.bottomAnchor.constraint(lessThanOrEqualTo: stackView.bottomAnchor),
            sendButton.widthAnchor.constraint(equalTo: sendButton.heightAnchor, multiplier: 1)
        ])
        
        inputTextViewBottomConstraint = NSLayoutConstraint(item: containerView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0)
        inputTextViewBottomConstraint?.isActive = true
        
        inputTextViewHeightConstraint = NSLayoutConstraint(item: inputTextView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 40)
        inputTextViewHeightConstraint?.isActive = true
    }
    
    
    // MARK: setupActions
    open override func setupActions() {
        super.setupActions()
        
        // Setting up Table View
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(LMUIComponents.shared.postCell)
        tableView.register(LMUIComponents.shared.linkCell)
        tableView.register(LMUIComponents.shared.documentCell)
        tableView.register(LMUIComponents.shared.commentCell)
        tableView.register(LMUIComponents.shared.totalCommentCell)
        tableView.register(LMUIComponents.shared.loadMoreReplies)
        tableView.registerHeaderFooter(LMUIComponents.shared.commentHeaderView)
        
        inputTextView.delegate = self
    }
    
    
    // MARK: setupAppearance
    open override func setupAppearance() {
        super.setupAppearance()
        
        tableView.backgroundColor = .clear
        view.backgroundColor = Appearance.shared.colors.backgroundColor
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        viewModel?.getPost(isInitialFetch: true)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: Keyboard Extension
@objc
extension LMFeedPostDetailViewController {
    open func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            inputTextViewBottomConstraint?.constant = -keyboardSize.size.height
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
            }
        }
    }
    
    open func keyboardWillHide(notification: NSNotification){
        inputTextViewBottomConstraint?.constant = .zero
        containerView.layoutIfNeeded()
    }
}

// MARK: UITableViewDataSource, UITableViewDelegate
@objc
extension LMFeedPostDetailViewController: UITableViewDataSource,
                                          UITableViewDelegate {
    open func numberOfSections(in tableView: UITableView) -> Int {
        guard postData != nil else { return .zero }
        return cellsData.count + 1
    }
    
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let comment = cellsData[safe: section - 1] as? LMFeedPostDetailCommentCellViewModel {
            return comment.replies.count
        }
        return 1
    }
    
    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0,
           let postData {
            if let cell = tableView.dequeueReusableCell(LMUIComponents.shared.postCell),
               let data = postData as? LMFeedPostMediaCell.ViewModel {
                cell.configure(with: data, delegate: self)
                return cell
            } else if let cell = tableView.dequeueReusableCell(LMUIComponents.shared.linkCell),
                      let data = postData as? LMFeedPostLinkCell.ViewModel {
                cell.configure(with: data, delegate: self)
                return cell
            } else if let cell = tableView.dequeueReusableCell(LMUIComponents.shared.documentCell),
                      let data = postData as? LMFeedPostDocumentCell.ViewModel {
                cell.configure(for: indexPath, with: data, delegate: self)
                return cell
            }
        } else if let cell = tableView.dequeueReusableCell(LMUIComponents.shared.totalCommentCell),
                  let data = cellsData[safe: indexPath.section - 1] as? LMFeedPostDetailTotalCommentCell.ViewModel {
            cell.configure(with: data)
            return cell
        } else if let cell = tableView.dequeueReusableCell(LMUIComponents.shared.commentCell),
                  let data = cellsData[safe: indexPath.section - 1] as? LMFeedPostDetailCommentCellViewModel {
            let comment = data.replies[indexPath.row]
            cell.configure(with: comment, delegate: self, isShowSeprator: (data.replies.count - 1) == indexPath.row, indexPath: indexPath)
            return cell
        } else if let cell = tableView.dequeueReusableCell(LMUIComponents.shared.loadMoreReplies),
                  let data = cellsData[safe: indexPath.section - 1] as? LMFeedPostMoreRepliesCell.ViewModel {
            cell.configure(with: data, delegate: self)
            return cell
        }
        
        return UITableViewCell()
    }
    
    open func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if let header = tableView.dequeueReusableHeaderFooterView(LMUIComponents.shared.commentHeaderView),
           let data = cellsData[safe: section - 1] as? LMFeedPostDetailCommentCellViewModel {
            header.configure(with: data, delegate: self, indexPath: .init(row: NSNotFound, section: section))
            return header
        }
        return nil
    }
    
    open func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return nil
    }
    
    open func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if type(of: scrollView) is UITableView.Type {
            view.endEditing(true)
            inputTextViewHeightConstraint?.constant = 40
        }
    }
    
    open func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }
}


// MARK: LMChatLinkProtocol
@objc
extension LMFeedPostDetailViewController: LMChatLinkProtocol {
    open func didTapLinkPreview(with url: String) {
        UIApplication.shared.open(URL(string: url)!)
    }
}

// MARK: LMFeedPostDocumentCellProtocol
@objc
extension LMFeedPostDetailViewController: LMFeedPostDocumentCellProtocol {
    open func didTapShowMoreDocuments(for indexPath: IndexPath) {
        if var data = postData as? LMFeedPostDocumentCell.ViewModel {
            data.isShowAllDocuments.toggle()
            tableView.reloadRows(at: [.init(row: 0, section: 0)], with: .automatic)
        }
    }
}


// MARK: LMChatPostCommentProtocol
@objc
extension LMFeedPostDetailViewController: LMChatPostCommentProtocol {
    open func didTapUserName(for uuid: String) { }
    
    open func didTapMenuButton(for commentId: String) {
        viewModel?.showMenu(for: commentId)
    }
    
    open func didTapLikeButton(for commentId: String, indexPath: IndexPath) {
        changeCommentLike(for: indexPath)
        viewModel?.likeComment(for: commentId, indexPath: indexPath)
    }
    
    open func didTapLikeCountButton(for commentId: String) { }
    
    open func didTapReplyButton(for commentId: String) { }
    
    open func didTapReplyCountButton(for commentId: String) { 
        viewModel?.getCommentReplies(commentId: commentId)
    }
}


// MARK: LMFeedTableCellToViewControllerProtocol
@objc
extension LMFeedPostDetailViewController: LMFeedTableCellToViewControllerProtocol {
    open func didTapLikeButton(for postID: String) {
        changePostLike()
        viewModel?.likePost(for: postID)
    }
    
    open func didTapProfilePicture(for uuid: String) { }
    
    open func didTapLikeTextButton(for postID: String) { }
    
    open func didTapCommentButton(for postID: String) { }
    
    open func didTapShareButton(for postID: String) { }
    
    open func didTapSaveButton(for postID: String) {
        changePostSave()
        viewModel?.savePost(for: postID)
    }
    
    open func didTapMenuButton(postID: String) {
        viewModel?.showMenu(postID: postID)
    }
}


// MARK: LMFeedPostMoreRepliesCellProtocol
@objc
extension LMFeedPostDetailViewController: LMFeedPostMoreRepliesCellProtocol {
    open func didTapMoreComments(for commentID: String) {
        print(#function)
    }
}


// MARK: UITextViewDelegate
@objc
extension LMFeedPostDetailViewController: UITextViewDelegate {
    open func textViewDidChange(_ textView: UITextView) {
        sendButton.isEnabled = !textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        
        textView.isScrollEnabled = false
        
        if textView.intrinsicContentSize.height > textInputMaximumHeight {
            inputTextViewHeightConstraint?.constant = textInputMaximumHeight
            textView.isScrollEnabled = true
        } else if textView.intrinsicContentSize.height > 40 {
            inputTextViewHeightConstraint?.constant = textView.intrinsicContentSize.height
        } else {
            inputTextViewHeightConstraint?.constant = 40
        }
        
        UIView.animate(withDuration: 0.1) { [weak self] in
            self?.containerView.layoutIfNeeded()
        }
    }
    
    open func textViewDidBeginEditing(_ textView: UITextView) {
        let newPosition = textView.endOfDocument
        textView.selectedTextRange = textView.textRange(from: newPosition, to: newPosition)
    }
    
    open func textViewDidEndEditing(_ textView: UITextView) {
        textView.text = textView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        inputTextViewHeightConstraint?.constant = 40
    }
}


// MARK: LMFeedPostDetailViewModelProtocol
extension LMFeedPostDetailViewController: LMFeedPostDetailViewModelProtocol {
    public func showPostDetails(with post: LMFeedPostTableCellProtocol, comments: [LMFeedPostCommentCellProtocol], indexPath: IndexPath?) {
        self.postData = post
        self.cellsData = comments
        
        if let indexPath {
            if indexPath.row == NSNotFound {
                tableView.reloadSections(.init(integer: indexPath.section), with: .automatic)
            } else {
                tableView.reloadRows(at: [indexPath], with: .none)
            }
        } else {
            tableView.reloadData()
        }
    }
    
    public func changePostLike() {
        let isLiked = postData?.footerData.isLiked ?? true
        postData?.footerData.isLiked = !isLiked
        postData?.footerData.likeCount += !isLiked ? 1 : -1
        tableView.reloadRows(at: [.init(row: 0, section: 0)], with: .none)
    }
    
    public func changePostSave() {
        postData?.footerData.isSaved.toggle()
        tableView.reloadRows(at: [.init(row: 0, section: 0)], with: .none)
    }
    
    public func changeCommentLike(for indexPath: IndexPath) {
        if var sectionData = cellsData[safe: indexPath.section - 1] as? LMFeedPostDetailCommentCellViewModel {
            if indexPath.row == NSNotFound {
                let isLiked = sectionData.isLiked
                sectionData.isLiked = !isLiked
                sectionData.likeCount += !isLiked ? 1 : -1
            } else if var reply = sectionData.replies[safe: indexPath.row] {
                let isLiked = reply.isLiked
                reply.isLiked = !isLiked
                reply.likeCount += !isLiked ? 1 : -1
                sectionData.replies[indexPath.row] = reply
            }
            
            cellsData[indexPath.section - 1] = sectionData
            tableView.reloadRows(at: [indexPath], with: .none)
        }
    }
}
