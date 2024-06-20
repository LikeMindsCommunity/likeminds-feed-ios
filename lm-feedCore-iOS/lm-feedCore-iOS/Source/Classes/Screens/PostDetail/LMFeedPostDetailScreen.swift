//
//  LMFeedPostDetailScreen.swift
//  LMFramework
//
//  Created by Devansh Mohata on 15/12/23.
//

import LikeMindsFeedUI
import UIKit

public protocol LMFeedPostDetailViewModelProtocol: LMBaseViewControllerProtocol {
    func showPostDetails(with post: LMFeedPostContentModel, comments: [LMFeedCommentContentModel], indexPath: IndexPath?, openCommentSection: Bool, scrollToCommentSection: Bool)
    func reloadComments(with comments: [LMFeedCommentContentModel], index: IndexSet?)
    func insertComment(at index: IndexSet, with comments: [LMFeedCommentContentModel], totalCommentCount: Int)
    func deleteComment(at index: Int, with comments: [LMFeedCommentContentModel], totalCommentCount: Int)
    func deleteRows(for section: Int, comments: [LMFeedCommentContentModel])
    
    func resetHeaderData()
    func resetFooterData(isSaved: Bool, isLiked: Bool)
    
    func changeCommentLike(for indexPath: IndexPath)
    func replyToComment(userName: String)
    
    func updateCommentStatus(isEnabled: Bool)
    
    func setEditCommentText(with text: String)
    
    func navigateToEditPost(for postID: String)
    func navigateToDeleteScreen(for postID: String, commentID: String?)
    func navigateToReportScreen(for postID: String, creatorUUID: String, commentID: String?, replyCommentID: String?)
    
    func navigateToPollResultScreen(with pollID: String, optionList: [LMFeedPollDataModel.Option], selectedOption: String?)
    func navigateToAddOptionPoll(with postID: String, pollID: String, options: [String])
}

@IBDesignable
open class LMFeedPostDetailScreen: LMViewController {
    // MARK: UI Elements
    open private(set) lazy var postDetailListView: LMTableView = {
        let table = LMTableView(frame: .zero, style: .grouped).translatesAutoresizingMaskIntoConstraints()
        table.separatorStyle = .none
        table.showsVerticalScrollIndicator = false
        table.showsHorizontalScrollIndicator = false
        table.estimatedRowHeight = 1
        table.rowHeight = UITableView.automaticDimension
        table.estimatedSectionHeaderHeight = 1
        table.sectionHeaderHeight = UITableView.automaticDimension
        table.estimatedSectionFooterHeight = 1
        table.sectionFooterHeight = UITableView.automaticDimension
        table.dataSource = self
        table.delegate = self
        table.register(LMUIComponents.shared.postDetailMediaCell)
        table.register(LMUIComponents.shared.postDetailLinkCell)
        table.register(LMUIComponents.shared.postDetailDocumentCell)
        table.register(LMUIComponents.shared.postDetailPollCell)
        table.register(LMUIComponents.shared.replyView)
        table.registerHeaderFooter(LMUIComponents.shared.loadMoreReplies)
        table.registerHeaderFooter(LMUIComponents.shared.commentView)
        table.registerHeaderFooter(LMUIComponents.shared.postDetailHeaderView)
        table.registerHeaderFooter(LMUIComponents.shared.postDetailFooterView)
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
    
    open private(set) lazy var removeReplyButton: LMButton = {
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
    public var postData: LMFeedPostContentModel?
    public var commentsData: [LMFeedCommentContentModel] = []
    public var textInputMaximumHeight: CGFloat = 100
    public var viewModel: LMFeedPostDetailViewModel?
    public var isCommentingEnabled: Bool = LocalPreferences.memberState?.memberRights?.contains(where: { $0.state == .commentOrReplyOnPost }) ?? false
    public var frozenContentOffsetForRowAnimation: CGPoint?
    
    // MARK: setupViews
    open override func setupViews() {
        super.setupViews()
        
        view.addSubview(postDetailListView)
        view.addSubview(containerView)
        
        containerView.addSubview(containerStackView)
        
        containerStackView.addArrangedSubview(taggingView)
        containerStackView.addArrangedSubview(replySepratorView)
        containerStackView.addArrangedSubview(replyView)
        containerStackView.addArrangedSubview(stackView)
        
        replyView.addSubview(replyNameLabel)
        replyView.addSubview(removeReplyButton)
        
        stackView.addArrangedSubview(inputTextView)
        stackView.addArrangedSubview(sendButton)
    }
    
    
    // MARK: setupLayouts
    open override func setupLayouts() {
        super.setupLayouts()
        
        postDetailListView.addConstraint(top: (view.safeAreaLayoutGuide.topAnchor, 0),
                                leading: (view.safeAreaLayoutGuide.leadingAnchor, 0),
                                trailing: (view.safeAreaLayoutGuide.trailingAnchor, 0))
        
        containerView.addConstraint(top: (postDetailListView.bottomAnchor, 0),
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
        
        removeReplyButton.addConstraint( leading: (replyNameLabel.trailingAnchor, 16),
                                  trailing: (replyView.trailingAnchor, -16),
                                  centerY: (replyNameLabel.centerYAnchor, 0))
        
        removeReplyButton.setWidthConstraint(with: removeReplyButton.heightAnchor)
        
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
        
        removeReplyButton.addTarget(self, action: #selector(didTapReplyCrossButton), for: .touchUpInside)
        sendButton.addTarget(self, action: #selector(didTapSendCommentButton), for: .touchUpInside)
        
        postDetailListView.refreshControl = refreshControl
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
        
        postDetailListView.visibleCells.forEach { cell in
            (cell as? LMFeedPostMediaCell)?.tableViewScrolled()
        }
        
        viewModel?.getPost(isInitialFetch: true)
    }
    
    // MARK: setupAppearance
    open override func setupAppearance() {
        super.setupAppearance()
        
        postDetailListView.backgroundColor = Appearance.shared.colors.backgroundColor
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
        inputTextView.addDoneButtonOnKeyboard()
        showHideLoaderView(isShow: true)
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        scrollingFinished()
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        postDetailListView.visibleCells.forEach { cell in
            (cell as? LMFeedPostMediaCell)?.tableViewScrolled()
        }
    }
    
    open func reloadTable(for index: IndexPath? = nil) {
        postDetailListView.reloadTable(for: index)
        scrollingFinished()
    }
    
    public func setNavigationTitle(with commentCount: Int) {
        setNavigationTitleAndSubtitle(with: "Post",
                                      subtitle: "\(commentCount) comment\(commentCount == 1 ? "" : "s")",
                                      alignment: .center)
    }
}

// MARK: Keyboard Extension
@objc
extension LMFeedPostDetailScreen {
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
extension LMFeedPostDetailScreen: UITableViewDataSource, UITableViewDelegate {
    open func numberOfSections(in tableView: UITableView) -> Int {
        guard postData != nil else { return .zero }
        return commentsData.count + 1
    }
    
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let comment = commentsData[safe: section - 1] {
            return comment.replies.count
        }
        return 1
    }
    
    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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
    
    open func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0,
        let postData,
           let header = tableView.dequeueReusableHeaderFooterView(LMUIComponents.shared.postDetailHeaderView) {
            header.configure(with: postData.headerData, postID: postData.postID, userUUID: postData.userUUID, delegate: self)
            return header
        } else if var data = commentsData[safe: section - 1],
            let header = tableView.dequeueReusableHeaderFooterView(LMUIComponents.shared.commentView) {
            header.configure(with: data, delegate: self, indexPath: .init(row: NSNotFound, section: section)) { [weak self] in
                data.isShowMore.toggle()
                self?.commentsData[section - 1] = data
                self?.reloadTable(for: IndexPath(row: NSNotFound, section: section))
            }
            return header
        }
        return nil
    }
    
    open func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return Constants.shared.number.postHeaderSize
        } else if (commentsData[safe: section - 1]) != nil {
            return UITableView.automaticDimension
        }
        return .leastNormalMagnitude
    }
    
    open func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
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
    
    open func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 0 {
            return UITableView.automaticDimension
        } else if commentsData[section - 1].repliesCount != 0,
                  commentsData[section - 1].repliesCount < commentsData[section - 1].totalReplyCount {
            return UITableView.automaticDimension
        }
        return 1
    }
    
    open func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if let frozenContentOffsetForRowAnimation,
            postDetailListView.contentOffset != frozenContentOffsetForRowAnimation {
            postDetailListView.setContentOffset(frozenContentOffsetForRowAnimation, animated: false)
        }
    }
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        frozenContentOffsetForRowAnimation = nil
        postDetailListView.visibleCells.forEach { cell in
            (cell as? LMFeedPostMediaCell)?.tableViewScrolled()
        }
    }
    
    open func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }
    
    open func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if section == commentsData.count - 1 {
            viewModel?.getPost(isInitialFetch: false)
        }
    }
    
    open func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if decelerate {
            scrollingFinished()
        }
    }

    open func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        scrollingFinished()
    }

    func scrollingFinished() {
        postDetailListView.visibleCells.forEach { cell in
            if type(of: cell) == LMFeedPostDetailMediaCell.self,
               postDetailListView.percentVisibility(of: cell) >= 0.8 {
                (cell as? LMFeedPostMediaCell)?.tableViewScrolled(isPlay: true)
            }
        }
    }
}


// MARK: LMFeedPostCommentProtocol
@objc
extension LMFeedPostDetailScreen: LMFeedPostCommentProtocol {
    public func didTapURL(url: URL) {
        openURL(with: url)
    }
    
    open func didTapUserName(for uuid: String) { 
        showError(with: "Tapped User with uuid: \(uuid)", isPopVC: false)
    }
    
    open func didTapCommentMenuButton(for commentId: String) {
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


// MARK: LMFeedPostDetailViewModelProtocol
extension LMFeedPostDetailScreen: LMFeedPostDetailViewModelProtocol {
    public func deleteRows(for section: Int, comments: [LMFeedCommentContentModel]) {
        commentsData = comments
        if section < postDetailListView.numberOfSections {
            var rows: [IndexPath] = []
            for i in 0..<postDetailListView.numberOfRows(inSection: section) {
                rows.append(.init(row: i, section: section))
            }
            
            UIView.performWithoutAnimation { [weak self] in
                self?.postDetailListView.beginUpdates()
                self?.postDetailListView.deleteRows(at: rows, with: .none)
                self?.postDetailListView.endUpdates()
            }
            
            frozenContentOffsetForRowAnimation = postDetailListView.contentOffset
        }
    }
    
    public func insertComment(at index: IndexSet, with comments: [LikeMindsFeedUI.LMFeedCommentContentModel], totalCommentCount: Int) {
        commentsData = comments
        setNavigationTitle(with: totalCommentCount)
        postData?.totalCommentCount = totalCommentCount
        (postDetailListView.footerView(forSection: 0) as? LMFeedPostDetailFooterView)?.updateCommentCount(with: totalCommentCount)
        UIView.performWithoutAnimation { [weak self] in
            self?.postDetailListView.beginUpdates()
            self?.postDetailListView.setContentOffset(self?.postDetailListView.contentOffset ?? .zero, animated: false)
            self?.postDetailListView.insertSections(index, with: .none)
            self?.postDetailListView.endUpdates()
        }
        
        for idx in index {
            postDetailListView.scrollToRow(at: IndexPath(row: NSNotFound, section: idx), at: .top, animated: true)
        }
    }
    
    public func deleteComment(at index: Int, with comments: [LikeMindsFeedUI.LMFeedCommentContentModel], totalCommentCount: Int) {
        commentsData = comments
        setNavigationTitle(with: totalCommentCount)
        (postDetailListView.footerView(forSection: 0) as? LMFeedPostDetailFooterView)?.updateCommentCount(with: totalCommentCount)
        UIView.performWithoutAnimation { [weak self] in
            self?.postDetailListView.beginUpdates()
            self?.postDetailListView.deleteSections(IndexSet(integer: index), with: .none)
            self?.postDetailListView.endUpdates()
        }
    }
    
    public func reloadComments(with comments: [LMFeedCommentContentModel], index: IndexSet?) {
        commentsData = comments
        let originalContentOffset = postDetailListView.contentOffset
        if let index {
            UIView.performWithoutAnimation { [weak self] in
                self?.postDetailListView.reloadSections(index, with: .none)
            }
        } else {
            let indexSet = IndexSet(integersIn: 1..<postDetailListView.numberOfSections)
            UIView.performWithoutAnimation { [weak self] in
                self?.postDetailListView.beginUpdates()
                self?.postDetailListView.setContentOffset(self?.postDetailListView.contentOffset ?? .zero, animated: false)
                self?.postDetailListView.reloadSections(indexSet, with: .none)
                self?.postDetailListView.endUpdates()
            }
        }
        
        if postDetailListView.contentOffset != originalContentOffset {
            frozenContentOffsetForRowAnimation = originalContentOffset
        }
    }
    
    public func navigateToEditPost(for postID: String) {
        guard let viewcontroller = LMFeedEditPostViewModel.createModule(for: postID) else { return }
        navigationController?.pushViewController(viewcontroller, animated: true)
    }
    
    public func showPostDetails(with post: LMFeedPostContentModel, comments: [LMFeedCommentContentModel], indexPath: IndexPath?, openCommentSection: Bool, scrollToCommentSection: Bool) {
        setNavigationTitle(with: post.totalCommentCount)
        showHideLoaderView(isShow: false)
        
        self.postData = post
        self.commentsData = comments
        
        reloadTable(for: indexPath)
        
        if openCommentSection,
           isCommentingEnabled {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                self?.inputTextView.becomeFirstResponder()
            }
        }
        
        if postDetailListView.numberOfSections >= 1,
           scrollToCommentSection {
            postDetailListView.scrollToRow(at: IndexPath(row: NSNotFound, section: 1), at: .bottom, animated: true)
        }
    }
    
    public func resetHeaderData() {
        postData?.headerData.isPinned.toggle()
        (postDetailListView.headerView(forSection: 0) as? LMFeedPostDetailHeaderView)?.togglePinStatus()
    }
    
    public func resetFooterData(isSaved: Bool, isLiked: Bool) {
        if isSaved {
            postData?.footerData.isSaved.toggle()
        }
        
        if isLiked {
            postData?.footerData.isLiked.toggle()
            let newStatus = postData?.footerData.isLiked == true
            postData?.footerData.likeCount += newStatus ? 1 : -1
        }
        
        guard let postData else { return }
        
        (postDetailListView.footerView(forSection: 0) as? LMFeedPostDetailFooterView)?.configure(with: postData.footerData, postID: postData.postID, delegate: self, commentCount: postData.totalCommentCount)
    }
    
    public func changeCommentLike(for indexPath: IndexPath) {
        if var sectionData = commentsData[safe: indexPath.section - 1] {
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
            
            commentsData[indexPath.section - 1] = sectionData
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
    
    public func updateCommentStatus(isEnabled: Bool) {
        isCommentingEnabled = isEnabled
        
        inputTextView.placeHolderText = isCommentingEnabled ? "Write a Comment" : "You do not have permission to comment."
        inputTextView.setAttributedText(from: "")
        inputTextView.isUserInteractionEnabled = isCommentingEnabled
        sendButton.isHidden = !isCommentingEnabled
    }
    
    public func navigateToDeleteScreen(for postID: String, commentID: String?) {
        guard let viewcontroller = LMFeedDeleteViewModel.createModule(postID: postID, commentID: commentID) else { return }
        viewcontroller.modalPresentationStyle = .overFullScreen
        present(viewcontroller, animated: false)
    }
    
    public func navigateToReportScreen(for postID: String, creatorUUID: String, commentID: String?, replyCommentID: String?) {
        do {
            let viewcontroller = try LMFeedReportViewModel.createModule(creatorUUID: creatorUUID, postID: postID, commentID: commentID, replyCommentID: replyCommentID)
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
    
    public func navigateToPollResultScreen(with pollID: String, optionList: [LMFeedPollDataModel.Option], selectedOption: String?) {
        do {
            let viewcontroller = try LMFeedPollResultViewModel.createModule(with: pollID, optionList: optionList, selectedOption: selectedOption)
            navigationController?.pushViewController(viewcontroller, animated: true)
        } catch {
            print("Error in \(#function)")
        }
    }
    
    public func navigateToAddOptionPoll(with postID: String, pollID: String, options: [String]) {
        do {
            let viewcontroller = try LMFeedPollAddOptionViewModel.createModule(for: postID, pollID: pollID, options: options, delegate: self)
            viewcontroller.modalPresentationStyle = .overFullScreen
            present(viewcontroller, animated: false)
        } catch let error {
            print(error.localizedDescription)
        }
    }
}


// MARK: LMFeedTaggingTextViewProtocol
@objc
extension LMFeedPostDetailScreen: LMFeedTaggingTextViewProtocol {
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
extension LMFeedPostDetailScreen: LMFeedTaggedUserFoundProtocol {
    public func userSelected(with route: String, and userName: String) {
        inputTextView.addTaggedUser(with: userName, route: route)
        mentionStopped()
    }
    
    public func updateHeight(with height: CGFloat) {
        tagsTableViewHeightConstraint?.constant = height
    }
}


// MARK: LMFeedPostHeaderViewProtocol, LMFeedPostFooterViewProtocol
@objc
extension LMFeedPostDetailScreen: LMFeedPostHeaderViewProtocol, LMFeedPostFooterViewProtocol {
    open func didTapPostMenuButton(for postID: String) {
        viewModel?.showMenu(postID: postID)
    }
    
    open func didTapLikeButton(for postID: String) {
        postData?.footerData.isLiked.toggle()
        let isLiked = postData?.footerData.isLiked == true
        postData?.footerData.likeCount += isLiked ? 1 : -1
        viewModel?.likePost(for: postID)
    }
    
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
        postData?.footerData.isSaved.toggle()
        viewModel?.savePost(for: postID)
    }
    
    open func didTapProfilePicture(having uuid: String) {
        showError(with: "Tapped User Profile having uuid: \(uuid)", isPopVC: false)
    }
}


// MARK: LMFeedLinkProtocol, LMFeedPostDocumentCellProtocol
@objc
extension LMFeedPostDetailScreen: LMFeedLinkProtocol, LMFeedPostDocumentCellProtocol {
    open func didTapShowMoreDocuments(for indexPath: IndexPath) {
        if var data = postData {
            data.isShowMoreDocuments.toggle()
            self.postData = data
            reloadTable(for: IndexPath(row: NSNotFound, section: 0))
        }
    }
    
    open func didTapDocument(with url: URL) {
        openURL(with: url)
    }
    
    open func didTapRoute(route: String) {
        showError(with: "Tapped User having Route: \(route)", isPopVC: false)
    }
    
    open func didTapLinkPreview(with url: String) {
        guard let url = URL(string: url) else { return }
        openURL(with: url)
    }
}


// MARK: LMFeedPostPollCellProtocol
extension LMFeedPostDetailScreen: LMFeedPostPollCellProtocol {
    public func didTapVoteCountButton(for postID: String, pollID: String, optionID: String?) {
        viewModel?.didTapVoteCountButton(for: postID, pollID: pollID, optionID: optionID)
    }
    
    public func didTapToVote(for postID: String, pollID: String, optionID: String) {
        viewModel?.optionSelected(for: postID, pollID: pollID, option: optionID)
    }
    
    public func didTapSubmitVote(for postID: String, pollID: String) {
        viewModel?.pollSubmitButtonTapped(for: postID, pollID: pollID)
    }
    
    public func editVoteTapped(for postID: String, pollID: String) {
        viewModel?.editPoll(for: postID)
    }
    
    public func didTapAddOption(for postID: String, pollID: String) {
        viewModel?.didTapAddOption(for: postID, pollID: pollID)
    }
}


// MARK: LMFeedAddOptionProtocol
extension LMFeedPostDetailScreen: LMFeedAddOptionProtocol {
    public func onAddOptionResponse(postID: String, success: Bool, errorMessage: String?) {
        if !success {
            showError(with: errorMessage ?? "Something went wrong", isPopVC: false)
        } else {
            viewModel?.getPost(isInitialFetch: true)
        }
    }
}
