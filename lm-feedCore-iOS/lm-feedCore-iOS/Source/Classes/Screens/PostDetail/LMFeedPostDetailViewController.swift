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
        table.estimatedRowHeight = 50
        table.rowHeight = UITableView.automaticDimension
        table.estimatedSectionHeaderHeight = 1
        table.sectionHeaderHeight = UITableView.automaticDimension
        table.sectionFooterHeight = .zero
        table.contentInset = .init(top: -20, left: .zero, bottom: .zero, right: .zero)
        table.dataSource = self
        table.delegate = self
        table.register(LMUIComponents.shared.postCell)
        table.register(LMUIComponents.shared.linkCell)
        table.register(LMUIComponents.shared.documentCell)
        table.register(LMUIComponents.shared.commentCell)
        table.register(LMUIComponents.shared.totalCommentCell)
        table.register(LMUIComponents.shared.loadMoreReplies)
        table.registerHeaderFooter(LMUIComponents.shared.commentHeaderView)
        return table
    }()
    
    open private(set) lazy var refreshControl: UIRefreshControl = {
        let refresh = UIRefreshControl()
        return refresh
    }()
    
    open private(set) lazy var containerView: LMView = {
        let view = LMView().translatesAutoresizingMaskIntoConstraints()
        view.backgroundColor = Appearance.shared.colors.white
        return view
    }()
    
    open private(set) lazy var containerStackView: LMStackView = {
        let stack = LMStackView().translatesAutoresizingMaskIntoConstraints()
        stack.axis = .vertical
        stack.alignment = .center
        stack.distribution = .fill
        stack.spacing = .zero
        return stack
    }()
    
    open private(set) lazy var taggingView: LMFeedTaggingListView = {
        let view = LMFeedTaggingListViewModel.createModule(delegate: self)
        view.backgroundColor = Appearance.shared.colors.clear
        view.isUserInteractionEnabled = true
        return view
    }()
    
    open private(set) lazy var replyView: LMView = {
        let view = LMView().translatesAutoresizingMaskIntoConstraints()
        return view
    }()
    
    open private(set) lazy var replyNameLabel: LMLabel = {
        let label = LMLabel().translatesAutoresizingMaskIntoConstraints()
        label.text = "Replying To XYZ"
        label.font = Appearance.shared.fonts.textFont1
        label.textColor = Appearance.shared.colors.gray3
        return label
    }()
    
    open private(set) lazy var replyCross: LMButton = {
        let button = LMButton().translatesAutoresizingMaskIntoConstraints()
        button.setTitle(nil, for: .normal)
        button.setImage(Constants.shared.images.xmarkIcon, for: .normal)
        button.tintColor = Appearance.shared.colors.gray3
        return button
    }()
    
    open private(set) lazy var stackView: LMStackView = {
        let stack = LMStackView().translatesAutoresizingMaskIntoConstraints()
        stack.axis = .horizontal
        stack.alignment = .center
        stack.distribution = .fill
        stack.backgroundColor = Appearance.shared.colors.clear
        return stack
    }()
    
    open private(set) lazy var inputTextView: LMFeedTaggingTextView = {
        let textView = LMFeedTaggingTextView().translatesAutoresizingMaskIntoConstraints()
        textView.isEditable = true
        textView.isScrollEnabled = false
        textView.backgroundColor = Appearance.shared.colors.clear
        textView.textColor = Appearance.shared.colors.textColor
        textView.contentMode = .center
        textView.font = Appearance.shared.fonts.textFont1
        return textView
    }()
    
    open private(set) lazy var sendButton: LMButton = {
        let button = LMButton().translatesAutoresizingMaskIntoConstraints()
        button.setTitle(nil, for: .normal)
        button.setImage(Constants.shared.images.planeIconFilled, for: .normal)
        button.tintColor = Appearance.shared.colors.appTintColor
        button.isEnabled = false
        return button
    }()
    
    open var inputTextViewHeightConstraint: NSLayoutConstraint?
    open var inputTextViewBottomConstraint: NSLayoutConstraint?
    open var tagsTableViewHeightConstraint: NSLayoutConstraint?
    
    
    // MARK: Data Variables
    public var postData: LMFeedPostTableCellProtocol?
    public var cellsData: [LMFeedPostCommentCellProtocol] = []
    public var textInputMaximumHeight: CGFloat = 100
    public var viewModel: LMFeedPostDetailViewModel?
    public var isCommentingEnabled: Bool = LocalPreferences.memberState?.memberRights?.contains(where: { $0.state == .commentOrReplyOnPost }) ?? false
    
    // MARK: setupViews
    open override func setupViews() {
        super.setupViews()
        
        view.addSubview(tableView)
        view.addSubview(containerView)
        
        containerView.addSubview(containerStackView)
        
        containerStackView.addArrangedSubview(taggingView)
        containerStackView.addArrangedSubview(replyView)
        containerStackView.addArrangedSubview(stackView)
        
        replyView.addSubview(replyNameLabel)
        replyView.addSubview(replyCross)
        
        stackView.addArrangedSubview(inputTextView)
        stackView.addArrangedSubview(sendButton)
    }
    
    
    // MARK: setupLayouts
    open override func setupLayouts() {
        super.setupLayouts()
        
        tableView.addConstraint(top: (view.topAnchor, 0),
                                leading: (view.leadingAnchor, 0),
                                trailing: (view.trailingAnchor, 0))
        
        containerView.addConstraint(top: (tableView.bottomAnchor, 0),
                                    bottom: (view.bottomAnchor, 0),
                                    leading: (view.leadingAnchor, 0),
                                    trailing: (view.trailingAnchor, 0))
        containerView.pinSubView(subView: containerStackView)
        
        taggingView.addConstraint(leading: (containerStackView.leadingAnchor, 0),
                                  trailing: (containerStackView.trailingAnchor, 0))
        
        replyView.addConstraint(leading: (containerStackView.leadingAnchor, 0),
                                  trailing: (containerStackView.trailingAnchor, 0))
        
        replyNameLabel.addConstraint(top: (replyView.topAnchor, 16),
                                     bottom: (replyView.bottomAnchor, -16),
                                     leading: (replyView.leadingAnchor, 16))
        
        replyCross.addConstraint( leading: (replyNameLabel.trailingAnchor, 16),
                                  trailing: (replyView.trailingAnchor, -16),
                                  centerY: (replyNameLabel.centerYAnchor, 0))
        
        stackView.addConstraint(leading: (containerView.leadingAnchor, 16),
                                trailing: (containerView.trailingAnchor, -16))
        
        inputTextView.addConstraint(top: (stackView.topAnchor, 0),
                                    bottom: (stackView.bottomAnchor, 0))
                
        NSLayoutConstraint.activate([
            sendButton.topAnchor.constraint(greaterThanOrEqualTo: stackView.topAnchor),
            sendButton.bottomAnchor.constraint(lessThanOrEqualTo: stackView.bottomAnchor),
            sendButton.widthAnchor.constraint(equalTo: sendButton.heightAnchor, multiplier: 1)
        ])
        
        inputTextViewBottomConstraint = NSLayoutConstraint(item: containerView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0)
        inputTextViewBottomConstraint?.isActive = true
        
        inputTextViewHeightConstraint = NSLayoutConstraint(item: inputTextView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 40)
        inputTextViewHeightConstraint?.isActive = true
        
        tagsTableViewHeightConstraint = NSLayoutConstraint(item: taggingView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 0)
        tagsTableViewHeightConstraint?.isActive = true
    }
    
    
    // MARK: setupActions
    open override func setupActions() {
        super.setupActions()
        inputTextView.mentionDelegate = self
        
        replyCross.addTarget(self, action: #selector(didTapReplyCrossButton), for: .touchUpInside)
        sendButton.addTarget(self, action: #selector(didTapSendCommentButton), for: .touchUpInside)
        
        tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(pullToRefresh), for: .valueChanged)
    }
    
    @objc
    open func didTapReplyCrossButton() {
        replyView.isHidden = true
        viewModel?.replyToComment(having: nil)
    }
    
    @objc
    open func didTapSendCommentButton() {
        let commentText = inputTextView.getText()
        viewModel?.postReply(with: commentText)
        inputTextView.resignFirstResponder()
        inputTextView.attributedText = nil
        inputTextView.text = nil
        replyView.isHidden = true
    }
    
    @objc
    open func pullToRefresh(_ refreshControl: UIRefreshControl) {
        refreshControl.endRefreshing()
        viewModel?.getPost(isInitialFetch: true)
    }
    
    // MARK: setupAppearance
    open override func setupAppearance() {
        super.setupAppearance()
        
        tableView.backgroundColor = Appearance.shared.colors.clear
        view.backgroundColor = Appearance.shared.colors.backgroundColor
    }
    
    
    // MARK: setupObservers
    open override func setupObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(postUpdated), name: .LMPostEdited, object: LMFeedPostDataModel.self)
        NotificationCenter.default.addObserver(self, selector: #selector(postError), name: .LMPostEditError, object: LMFeedError.self)
        NotificationCenter.default.addObserver(self, selector: #selector(postDeleted), name: .LMPostDeleted, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(commentDeleted), name: .LMCommentDeleted, object: nil)
    }
    
    @objc
    open func postUpdated(notification: Notification) {
        if let data = notification.object as? LMFeedPostDataModel {
            viewModel?.updatePostData(with: data)
        }
    }
    
    @objc
    open func postError(notification: Notification) {
        if let error = notification.object as? LMFeedError {
            showError(with: error.errorMessage)
        }
    }
    
    @objc
    open func postDeleted(notification: Notification) {
        if let postID = notification.object as? String {
            viewModel?.checkIfCurrentPost(postID: postID)
        }
    }
    
    @objc
    open func commentDeleted(notification: Notification) {
        if let (postID, commentID) = notification.object as? (String, String) {
            viewModel?.checkIfCurrentPost(postID: postID, commentID: commentID)
        }
    }
    
    // MARK: viewDidLoad
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        updateCommentStatus(isEnabled: LocalPreferences.memberState?.memberRights?.contains(where: { $0.state == .commentOrReplyOnPost }) ?? false)
        
        replyView.isHidden = true
        viewModel?.getMemberState()
        viewModel?.getPost(isInitialFetch: true)
        showHideLoaderView(isShow: true)
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
    
    open func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        0.5
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
    
    open func didTapDocument(with url: String) {
        guard let url = URL(string: url) else { return }
        UIApplication.shared.open(url)
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
    
    open func didTapLikeCountButton(for commentId: String) {
        if let viewModel,
           viewModel.allowCommentLikeView(for: commentId) {
            let viewcontroller = LMFeedLikeViewModel.createModule(postID: viewModel.postID, commentID: commentId)
            navigationController?.pushViewController(viewcontroller, animated: true)
        }
    }
    
    open func didTapReplyButton(for commentId: String) { 
        guard isCommentingEnabled else { return }
        viewModel?.replyToComment(having: commentId)
    }
    
    open func didTapReplyCountButton(for commentId: String) {
        viewModel?.getCommentReplies(commentId: commentId, isClose: true)
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
    
    open func didTapLikeTextButton(for postID: String) { 
        if viewModel?.allowPostLikeView() == true {
            let viewcontroller = LMFeedLikeViewModel.createModule(postID: postID)
            navigationController?.pushViewController(viewcontroller, animated: true)
        }
    }
    
    open func didTapCommentButton(for postID: String) { 
        guard isCommentingEnabled else { return }
        inputTextView.becomeFirstResponder()
    }
    
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
        viewModel?.getCommentReplies(commentId: commentID, isClose: false)
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
    public func navigateToEditPost(for postID: String) {
        guard let viewcontroller = LMFeedEditPostViewModel.createModule(for: postID) else { return }
        navigationController?.pushViewController(viewcontroller, animated: true)
    }
    
    public func showPostDetails(with post: LMFeedPostTableCellProtocol, comments: [LMFeedPostCommentCellProtocol], indexPath: IndexPath?, openCommentSection: Bool) {
        showHideLoaderView(isShow: false)
        
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
        
        if openCommentSection,
           isCommentingEnabled{
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                self?.inputTextView.becomeFirstResponder()
            }
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
    
    public func replyToComment(userName: String) {
        let replyLabelText = NSMutableAttributedString(string: "Replying To ", attributes: [.font: Appearance.shared.fonts.textFont2,
                                                                                           .foregroundColor: Appearance.shared.colors.gray51])
        
        replyLabelText.append(NSAttributedString(string: userName, attributes: [.font: Appearance.shared.fonts.textFont2,
                                                                                .foregroundColor: Appearance.shared.colors.appTintColor]))
        
        replyNameLabel.attributedText = replyLabelText
        replyView.isHidden = false
        inputTextView.becomeFirstResponder()
    }
    
    public func showNoPostError(with message: String, isPop: Bool) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        
        alert.addAction(.init(title: "OK", style: .default) { [weak self] _ in
            if isPop {
                self?.navigationController?.popViewController(animated: true)
            }
        })
        
        presentAlert(with: alert)
    }
    
    public func updateCommentStatus(isEnabled: Bool) {
        isCommentingEnabled = isEnabled
        
        inputTextView.placeHolderText = isCommentingEnabled ? "Write a Comment" : "You do not have permission to comment."
        inputTextView.setAttributedText(from: "")
        inputTextView.isUserInteractionEnabled = isCommentingEnabled
        sendButton.isHidden = !isCommentingEnabled
    }
    
    public func navigateToDeleteScreen(for postID: String, commentID: String?) {
        guard let viewcontroller = LMFeedDeleteReviewViewModel.createModule(postID: postID, commentID: commentID) else { return }
        viewcontroller.modalPresentationStyle = .overFullScreen
        viewcontroller.modalTransitionStyle = .coverVertical
        present(viewcontroller, animated: false)
    }
}


// MARK: LMFeedTaggingTextViewProtocol
@objc
extension LMFeedPostDetailViewController: LMFeedTaggingTextViewProtocol {
    open func mentionStarted(with text: String) {
        taggingView.getUsers(for: text)
    }
    
    open func mentionStopped() {
        taggingView.stopFetchingUsers()
    }
    
    open func contentHeightChanged() {
        let width = inputTextView.frame.size.width
        
        let newSize = inputTextView.sizeThatFits(CGSize(width: width, height: .greatestFiniteMagnitude))
        
        inputTextView.isScrollEnabled = newSize.height > textInputMaximumHeight
        inputTextViewHeightConstraint?.constant = min(newSize.height, textInputMaximumHeight)
        
        sendButton.isEnabled = !inputTextView.attributedText.string.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && inputTextView.text.trimmingCharacters(in: .whitespacesAndNewlines) != inputTextView.placeHolderText
    }
}


// MARK: LMFeedTaggedUserFoundProtocol
extension LMFeedPostDetailViewController: LMFeedTaggedUserFoundProtocol {
    public func userSelected(with route: String, and userName: String) {
        inputTextView.addTaggedUser(with: userName, route: route)
        mentionStopped()
    }
    
    public func updateHeight(with height: CGFloat) {
        tagsTableViewHeightConstraint?.constant = height
    }
}
