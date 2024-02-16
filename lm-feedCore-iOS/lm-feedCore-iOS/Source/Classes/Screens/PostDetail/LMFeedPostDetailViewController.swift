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
        table.estimatedRowHeight = 100
        table.rowHeight = UITableView.automaticDimension
        table.estimatedSectionHeaderHeight = 1
        table.sectionHeaderHeight = UITableView.automaticDimension
        table.sectionFooterHeight = .zero
        table.dataSource = self
        table.delegate = self
        table.register(LMUIComponents.shared.postDetailMediaCell)
        table.register(LMUIComponents.shared.postDetailLinkCell)
        table.register(LMUIComponents.shared.postDetailDocumentCell)
        table.register(LMUIComponents.shared.commentCell)
        table.registerHeaderFooter(LMUIComponents.shared.loadMoreReplies)
        table.registerHeaderFooter(LMUIComponents.shared.commentHeaderView)
        table.registerHeaderFooter(LMUIComponents.shared.totalCommentFooter)
        table.registerHeaderFooter(LMUIComponents.shared.noCommentFooter)
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
        textView.placeHolderText = "Write a Comment"
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
    
    open private(set) lazy var replySepratorView: LMView = {
        let view = LMView().translatesAutoresizingMaskIntoConstraints()
        view.backgroundColor = Appearance.shared.colors.sepratorColor
        return view
    }()
    
    open var inputTextViewBottomConstraint: NSLayoutConstraint?
    open var inputTextViewHeightConstraint: NSLayoutConstraint?
    open var tagsTableViewHeightConstraint: NSLayoutConstraint?
    
    
    // MARK: Data Variables
    public var postData: LMFeedPostTableCellProtocol?
    public var cellsData: [LMFeedPostDetailCommentCellViewModel] = []
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
        containerStackView.addArrangedSubview(replySepratorView)
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
        
        tableView.addConstraint(top: (view.safeAreaLayoutGuide.topAnchor, 0),
                                leading: (view.safeAreaLayoutGuide.leadingAnchor, 0),
                                trailing: (view.safeAreaLayoutGuide.trailingAnchor, 0))
        
        containerView.addConstraint(top: (tableView.bottomAnchor, 0),
                                    leading: (view.safeAreaLayoutGuide.leadingAnchor, 0),
                                    trailing: (view.safeAreaLayoutGuide.trailingAnchor, 0))
        containerView.pinSubView(subView: containerStackView)
        
        taggingView.addConstraint(leading: (containerStackView.leadingAnchor, 0),
                                  trailing: (containerStackView.trailingAnchor, 0))
        
        replySepratorView.addConstraint(leading: (containerStackView.leadingAnchor, 0),
                                  trailing: (containerStackView.trailingAnchor, 0))
        
        replyView.addConstraint(leading: (containerStackView.leadingAnchor, 0),
                                  trailing: (containerStackView.trailingAnchor, 0))
        
        replyNameLabel.addConstraint(top: (replyView.topAnchor, 16),
                                     bottom: (replyView.bottomAnchor, -16),
                                     leading: (replyView.leadingAnchor, 16))
        
        replyCross.addConstraint( leading: (replyNameLabel.trailingAnchor, 16),
                                  trailing: (replyView.trailingAnchor, -16),
                                  centerY: (replyNameLabel.centerYAnchor, 0))
        
        replyCross.setWidthConstraint(with: replyCross.heightAnchor)
        
        stackView.addConstraint(leading: (containerView.leadingAnchor, 16),
                                trailing: (containerView.trailingAnchor, -16))
        
        inputTextView.addConstraint(top: (stackView.topAnchor, 0),
                                    bottom: (stackView.bottomAnchor, 0))
                
        sendButton.setWidthConstraint(with: sendButton.heightAnchor)
        
        NSLayoutConstraint.activate([
            sendButton.topAnchor.constraint(greaterThanOrEqualTo: stackView.topAnchor),
            sendButton.bottomAnchor.constraint(lessThanOrEqualTo: stackView.bottomAnchor)
        ])
        
        inputTextViewBottomConstraint = containerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        inputTextViewBottomConstraint?.isActive = true
        
        inputTextViewHeightConstraint = inputTextView.setHeightConstraint(with: 40)
        tagsTableViewHeightConstraint = taggingView.setHeightConstraint(with: 0)
        replySepratorView.setHeightConstraint(with: 1)
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
        viewModel?.sendButtonTapped(with: commentText)
        inputTextView.resignFirstResponder()
        inputTextView.setAttributedText(from: "")
        contentHeightChanged()
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
        
        tableView.backgroundColor = Appearance.shared.colors.backgroundColor
        view.backgroundColor = Appearance.shared.colors.white
    }
    
    
    // MARK: setupObservers
    open override func setupObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(postUpdated), name: .LMPostEdited, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(postError), name: .LMPostEditError, object: nil)
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
            showError(with: error.localizedDescription)
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
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tableView.visibleCells.forEach { cell in
            (cell as? LMFeedPostMediaCell)?.tableViewScrolled()
        }
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
        if let comment = cellsData[safe: section - 1] {
            return comment.replies.count
        }
        return 1
    }
    
    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0,
           let postData {
            if let cell = tableView.dequeueReusableCell(LMUIComponents.shared.postDetailMediaCell),
               let data = postData as? LMFeedPostMediaCell.ViewModel {
                cell.configure(with: data, delegate: self)
                return cell
            } else if let cell = tableView.dequeueReusableCell(LMUIComponents.shared.postDetailLinkCell),
                      let data = postData as? LMFeedPostLinkCell.ViewModel {
                cell.configure(with: data, delegate: self)
                return cell
            } else if let cell = tableView.dequeueReusableCell(LMUIComponents.shared.postDetailDocumentCell),
                      let data = postData as? LMFeedPostDocumentCell.ViewModel {
                cell.configure(for: indexPath, with: data, delegate: self)
                return cell
            }
        } else if let cell = tableView.dequeueReusableCell(LMUIComponents.shared.commentCell),
                  var data = cellsData[safe: indexPath.section - 1] {
            let comment = data.replies[indexPath.row]
            cell.configure(with: comment, delegate: self, indexPath: indexPath) { [weak self] in
                data.replies[indexPath.row].isShowMore.toggle()
                self?.cellsData[indexPath.section - 1] = data
                self?.tableView.reloadTable(for: indexPath)
            }
            return cell
        }
        
        return UITableViewCell()
    }
        
    open func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if let header = tableView.dequeueReusableHeaderFooterView(LMUIComponents.shared.commentHeaderView),
           var data = cellsData[safe: section - 1] {
            header.configure(with: data, delegate: self, indexPath: .init(row: NSNotFound, section: section)) { [weak self] in
                data.isShowMore.toggle()
                self?.cellsData[section - 1] = data
                self?.tableView.reloadTable(for: IndexPath(row: NSNotFound, section: section))
            }
            return header
        }
        return nil
    }
    
    open func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if (cellsData[safe: section - 1]) != nil {
            return UITableView.automaticDimension
        }
        return .leastNormalMagnitude
    }
    
    open func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section == 0,
           let postData {
            if postData.totalCommentCount == 0,
               let footer = tableView.dequeueReusableHeaderFooterView(LMUIComponents.shared.noCommentFooter) {
                return footer
            } else if let footer = tableView.dequeueReusableHeaderFooterView(LMUIComponents.shared.totalCommentFooter) {
                footer.configure(with: postData.totalCommentCount)
                return footer
            }
        } else if let data = cellsData[safe: section - 1],
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
    
    open func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 0 {
            return UITableView.automaticDimension
        } else if cellsData[section - 1].repliesCount != 0,
                  cellsData[section - 1].repliesCount < cellsData[section - 1].totalReplyCount {
            return UITableView.automaticDimension
        }
        return 1
    }
    
    open func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if type(of: scrollView) is UITableView.Type {
            view.endEditing(true)
        }
    }
    
    open func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }
    
    open func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if section == cellsData.count - 1 {
            viewModel?.getPost(isInitialFetch: false)
        }
    }
}


// MARK: LMChatLinkProtocol
@objc
extension LMFeedPostDetailViewController: LMChatLinkProtocol {
    open func didTapLinkPreview(with url: String) {
        guard let urlLink = url.convertIntoURL() else { return }
        openURL(with: urlLink)
    }
}

// MARK: LMFeedPostDocumentCellProtocol
@objc
extension LMFeedPostDetailViewController: LMFeedPostDocumentCellProtocol {
    open func didTapShowMoreDocuments(for indexPath: IndexPath) {
        if var data = postData as? LMFeedPostDocumentCell.ViewModel {
            data.isShowAllDocuments.toggle()
            self.postData = data
            tableView.reloadTable(for: IndexPath(row: NSNotFound, section: 0))
        }
    }
    
    open func didTapDocument(with url: String) {
        guard let urlLink = url.convertIntoURL() else { return }
        openURL(with: urlLink)
    }
}


// MARK: LMChatPostCommentProtocol
@objc
extension LMFeedPostDetailViewController: LMChatPostCommentProtocol {
    open func didTapUserName(for uuid: String) { 
        showError(with: "Tapped User with uuid: \(uuid)", isPopVC: false)
    }
    
    open func didTapMenuButton(for commentId: String) {
        viewModel?.showMenu(for: commentId)
    }
    
    open func didTapLikeButton(for commentId: String, indexPath: IndexPath) {
        changeCommentLike(for: indexPath)
        viewModel?.likeComment(for: commentId, indexPath: indexPath)
    }
    
    open func didTapLikeCountButton(for commentId: String) {
        guard let viewModel,
            viewModel.allowCommentLikeView(for: commentId) else { return }
        do {
            let viewcontroller = try LMFeedLikeViewModel.createModule(postID: viewModel.postID, commentID: commentId)
            navigationController?.pushViewController(viewcontroller, animated: true)
        } catch let error {
            print(error.localizedDescription)
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
    open func didTapSeeMoreButton(for postID: String) {
        postData?.isShowMore.toggle()
        tableView.reloadTable(for: IndexPath(row: 0, section: 0))
    }
    
    open func didTapRoute(route: String) {
        showError(with: "Tapped Route: \(route)", isPopVC: false)
    }
    
    open func didTapURL(url: URL) {
        openURL(with: url)
    }
    
    open func didTapLikeButton(for postID: String) {
        changePostLike()
        viewModel?.likePost(for: postID)
    }
    
    open func didTapProfilePicture(for uuid: String) { }
    
    open func didTapLikeTextButton(for postID: String) {
        guard viewModel?.allowPostLikeView() == true else { return }
        
        do {
            let viewcontroller = try LMFeedLikeViewModel.createModule(postID: postID)
            navigationController?.pushViewController(viewcontroller, animated: true)
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    open func didTapCommentButton(for postID: String) { 
        guard isCommentingEnabled else { return }
        inputTextView.becomeFirstResponder()
    }
    
    open func didTapShareButton(for postID: String) {
        LMFeedShareUtility.sharePost(from: self, postID: postID)
    }
    
    open func didTapSaveButton(for postID: String) {
        changePostSave()
        viewModel?.savePost(for: postID)
    }
    
    open func didTapMenuButton(postID: String) {
        viewModel?.showMenu(postID: postID)
    }
}


// MARK: LMFeedPostDetailViewModelProtocol
extension LMFeedPostDetailViewController: LMFeedPostDetailViewModelProtocol {
    public func navigateToEditPost(for postID: String) {
        guard let viewcontroller = LMFeedEditPostViewModel.createModule(for: postID) else { return }
        navigationController?.pushViewController(viewcontroller, animated: true)
    }
    
    public func showPostDetails(with post: LMFeedPostTableCellProtocol, comments: [LMFeedPostDetailCommentCellViewModel], indexPath: IndexPath?, openCommentSection: Bool, scrollToCommentSection: Bool) {
        setNavigationTitleAndSubtitle(with: "Post",
                                      subtitle: "\(comments.count) comment\(comments.count == 1 ? "" : "s")",
                                      alignment: .center)
        showHideLoaderView(isShow: false)
        
        self.postData = post
        self.cellsData = comments
        
        tableView.reloadTable(for: indexPath)
        
        if openCommentSection,
           isCommentingEnabled {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                self?.inputTextView.becomeFirstResponder()
            }
        }
        
        if tableView.numberOfSections >= 1,
           scrollToCommentSection {
            tableView.scrollToRow(at: IndexPath(row: NSNotFound, section: 1), at: .bottom, animated: true)
        }
    }
    
    public func changePostLike() {
        let isLiked = postData?.footerData.isLiked ?? true
        postData?.footerData.isLiked = !isLiked
        postData?.footerData.likeCount += !isLiked ? 1 : -1
        tableView.reloadTable(for: IndexPath(row: 0, section: 0))
    }
    
    public func changePostSave() {
        postData?.footerData.isSaved.toggle()
        tableView.reloadTable(for: IndexPath(row: 0, section: 0))
    }
    
    public func changeCommentLike(for indexPath: IndexPath) {
        if var sectionData = cellsData[safe: indexPath.section - 1] {
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
            tableView.reloadTable(for: indexPath)
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
    
    public func navigateToReportScreen(for postID: String, creatorUUID: String, commentID: String?, replyCommentID: String?) {
        do {
            let viewcontroller = try LMFeedReportContentViewModel.createModule(creatorUUID: creatorUUID, postID: postID, commentID: commentID, replyCommentID: replyCommentID)
            navigationController?.pushViewController(viewcontroller, animated: true)
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    public func setEditCommentText(with text: String) {
        inputTextView.setAttributedText(from: text, prefix: "@")
        inputTextView.becomeFirstResponder()
        contentHeightChanged()
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
        inputTextViewHeightConstraint?.constant = min(max(40, newSize.height), textInputMaximumHeight)
        
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
