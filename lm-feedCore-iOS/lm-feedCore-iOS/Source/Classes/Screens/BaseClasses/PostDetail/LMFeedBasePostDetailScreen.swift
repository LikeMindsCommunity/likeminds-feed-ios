//
//  LMFeedBasePostDetailScreen.swift
//  LikeMindsFeedCore
//
//  Created by Devansh Mohata on 31/07/24.
//

import LikeMindsFeedUI
import UIKit

public protocol LMFeedBasePostDetailViewModelProtocol:
    LMBaseViewControllerProtocol
{
    func showPostDetails(
        with post: LMFeedPostContentModel,
        comments: [LMFeedCommentContentModel], isInitialPage: Bool)
    func updatePost(
        post: LMFeedPostContentModel, onlyHeader: Bool, onlyFooter: Bool)
    func updateComment(comment: LMFeedCommentContentModel)

    func deleteComment(commentID: String)
    func deleteReply(commentID: String, parentCommentID: String)

    func insertComment(comment: LMFeedCommentContentModel, index: Int)

    func replyToComment(userName: String)

    func updateCommentStatus(isEnabled: Bool)

    func setEditCommentText(with text: String)

    func navigateToEditPost(for postID: String)
    func navigateToDeleteScreen(for postID: String, commentID: String?)
    func navigateToReportScreen(
        for postID: String, creatorUUID: String, commentID: String?,
        replyCommentID: String?)

    func handleCommentScroll(
        openCommentSection: Bool, scrollToCommentSection: Bool)

    func navigateToPollResultScreen(
        with pollID: String, optionList: [LMFeedPollDataModel.Option],
        selectedOption: String?)
    func navigateToAddOptionPoll(
        with postID: String, pollID: String, options: [String])
}

open class LMFeedBasePostDetailScreen: LMViewController {
    // MARK: UI Elements
    open private(set) lazy var postDetailListView: LMTableView = {
        let table = LMTableView(frame: .zero, style: .grouped)
            .translatesAutoresizingMaskIntoConstraints()
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
        return table
    }()

    open private(set) lazy var refreshControl: UIRefreshControl = {
        let refresh = UIRefreshControl()
        return refresh
    }()

    open private(set) lazy var containerView: LMView = {
        let view = LMView().translatesAutoresizingMaskIntoConstraints()
        view.backgroundColor = LMFeedAppearance.shared.colors.white
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
        view.backgroundColor = LMFeedAppearance.shared.colors.clear
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
        label.font = LMFeedAppearance.shared.fonts.textFont1
        label.textColor = LMFeedAppearance.shared.colors.gray3
        return label
    }()

    open private(set) lazy var removeReplyButton: LMButton = {
        let button = LMButton().translatesAutoresizingMaskIntoConstraints()
        button.setTitle(nil, for: .normal)
        button.setImage(LMFeedConstants.shared.images.xmarkIcon, for: .normal)
        button.tintColor = LMFeedAppearance.shared.colors.gray3
        return button
    }()

    open private(set) lazy var stackView: LMStackView = {
        let stack = LMStackView().translatesAutoresizingMaskIntoConstraints()
        stack.axis = .horizontal
        stack.alignment = .center
        stack.distribution = .fill
        stack.backgroundColor = LMFeedAppearance.shared.colors.clear
        return stack
    }()

    open private(set) lazy var inputTextView: LMFeedTaggingTextView = {
        let textView = LMFeedTaggingTextView()
            .translatesAutoresizingMaskIntoConstraints()
        textView.isEditable = true
        textView.isScrollEnabled = false
        textView.backgroundColor = LMFeedAppearance.shared.colors.clear
        textView.textColor = LMFeedAppearance.shared.colors.textColor
        textView.contentMode = .center
        textView.font = LMFeedAppearance.shared.fonts.textFont1
        textView.placeHolderText = LMStringConstants.shared.writeComment
        return textView
    }()

    open private(set) lazy var sendButton: LMButton = {
        let button = LMButton().translatesAutoresizingMaskIntoConstraints()
        button.setTitle(nil, for: .normal)
        button.setImage(
            LMFeedConstants.shared.images.planeIconFilled, for: .normal)
        button.tintColor = LMFeedAppearance.shared.colors.appTintColor
        button.isEnabled = false
        return button
    }()

    open private(set) lazy var replySepratorView: LMView = {
        let view = LMView().translatesAutoresizingMaskIntoConstraints()
        view.backgroundColor = LMFeedAppearance.shared.colors.sepratorColor
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
    public var isCommentingEnabled: Bool =
        LocalPreferences.memberState?.memberRights?.contains(where: {
            $0.state == .commentOrReplyOnPost
        }) ?? false
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

        postDetailListView.addConstraint(
            top: (view.safeAreaLayoutGuide.topAnchor, 0),
            leading: (view.safeAreaLayoutGuide.leadingAnchor, 0),
            trailing: (view.safeAreaLayoutGuide.trailingAnchor, 0))

        containerView.addConstraint(
            top: (postDetailListView.bottomAnchor, 0),
            leading: (view.safeAreaLayoutGuide.leadingAnchor, 0),
            trailing: (view.safeAreaLayoutGuide.trailingAnchor, 0))
        containerView.pinSubView(subView: containerStackView)

        taggingView.addConstraint(
            leading: (containerStackView.leadingAnchor, 0),
            trailing: (containerStackView.trailingAnchor, 0))

        replySepratorView.addConstraint(
            leading: (containerStackView.leadingAnchor, 0),
            trailing: (containerStackView.trailingAnchor, 0))

        replyView.addConstraint(
            leading: (containerStackView.leadingAnchor, 0),
            trailing: (containerStackView.trailingAnchor, 0))

        replyNameLabel.addConstraint(
            top: (replyView.topAnchor, 16),
            bottom: (replyView.bottomAnchor, -16),
            leading: (replyView.leadingAnchor, 16))

        removeReplyButton.addConstraint(
            leading: (replyNameLabel.trailingAnchor, 16),
            trailing: (replyView.trailingAnchor, -16),
            centerY: (replyNameLabel.centerYAnchor, 0))

        removeReplyButton.setWidthConstraint(
            with: removeReplyButton.heightAnchor)

        stackView.addConstraint(
            leading: (containerView.leadingAnchor, 16),
            trailing: (containerView.trailingAnchor, -16))

        inputTextView.addConstraint(
            top: (stackView.topAnchor, 0),
            bottom: (stackView.bottomAnchor, 0))

        sendButton.setWidthConstraint(with: sendButton.heightAnchor)

        NSLayoutConstraint.activate([
            sendButton.topAnchor.constraint(
                greaterThanOrEqualTo: stackView.topAnchor),
            sendButton.bottomAnchor.constraint(
                lessThanOrEqualTo: stackView.bottomAnchor),
        ])

        inputTextViewBottomConstraint = containerView.bottomAnchor.constraint(
            equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        inputTextViewBottomConstraint?.isActive = true

        inputTextViewHeightConstraint = inputTextView.setHeightConstraint(
            with: 40)
        tagsTableViewHeightConstraint = taggingView.setHeightConstraint(with: 0)
        replySepratorView.setHeightConstraint(with: 1)
    }

    // MARK: setupActions
    open override func setupActions() {
        super.setupActions()
        inputTextView.mentionDelegate = self

        removeReplyButton.addTarget(
            self, action: #selector(didTapReplyCrossButton), for: .touchUpInside
        )
        sendButton.addTarget(
            self, action: #selector(didTapSendCommentButton),
            for: .touchUpInside)

        postDetailListView.refreshControl = refreshControl
        refreshControl.addTarget(
            self, action: #selector(pullToRefresh), for: .valueChanged)
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

        postDetailListView.backgroundColor =
            LMFeedAppearance.shared.colors.backgroundColor
        view.backgroundColor = LMFeedAppearance.shared.colors.white
    }

    // MARK: setupObservers
    open override func setupObservers() {
        super.setupObservers()

        NotificationCenter.default.addObserver(
            self, selector: #selector(postUpdated), name: .LMPostEdited,
            object: nil)
        NotificationCenter.default.addObserver(
            self, selector: #selector(postError), name: .LMPostEditError,
            object: nil)
        NotificationCenter.default.addObserver(
            self, selector: #selector(postDeleted), name: .LMPostDeleted,
            object: nil)
        NotificationCenter.default.addObserver(
            self, selector: #selector(commentDeleted), name: .LMCommentDeleted,
            object: nil)
        NotificationCenter.default.addObserver(
            self, selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(
            self, selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc
    open func postUpdated(notification: Notification) {
        if let data = notification.object as? LMFeedPostDataModel {
            viewModel?.updatePostData(data: data)
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

        setupTableView(postDetailListView)
        updateCommentStatus(
            isEnabled: LocalPreferences.memberState?.memberRights?.contains(
                where: { $0.state == .commentOrReplyOnPost }) ?? false)

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
        setNavigationTitleAndSubtitle(
            with: LMStringConstants.shared.postDetailTitle,
            subtitle:
                "\(commentCount) \(LMStringConstants.shared.commentVariable.pluralize(count: commentCount > 1 ? commentCount : 1))",
            alignment: .center)
    }

    open func setupTableView(_ table: UITableView) {}
}

// MARK: Keyboard Extension
@objc
extension LMFeedBasePostDetailScreen {
    open func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize =
            (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey]
            as? NSValue)?.cgRectValue
        {
            inputTextViewBottomConstraint?.constant = -keyboardSize.size.height
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
            }
        }
    }

    open func keyboardWillHide(notification: NSNotification) {
        inputTextViewBottomConstraint?.constant = .zero
        containerView.layoutIfNeeded()
    }
}

// MARK: UITableViewDataSource, UITableViewDelegate
@objc
extension LMFeedBasePostDetailScreen: UITableViewDataSource, UITableViewDelegate
{
    open func numberOfSections(in tableView: UITableView) -> Int {
        guard postData != nil else { return .zero }
        return commentsData.count + 1
    }

    open func tableView(
        _ tableView: UITableView, numberOfRowsInSection section: Int
    ) -> Int {
        if let comment = commentsData[safe: section - 1] {
            return comment.replies.count
        }

        if section == 0 {
            guard let item = postData else { return 1 }
            // Each post can have multiple rows: one for text and others for attachments

            var numberOfRows = 0

            if !item.topics.topics.isEmpty {
                numberOfRows += 1
            }

            if !item.postText.isEmpty || !item.postQuestion.isEmpty {
                numberOfRows += 1
            }

            if item.postType != .text && item.postType != .topic {
                numberOfRows += 1
            }

            return numberOfRows
        }
        return 1
    }

    open func tableView(
        _ tableView: UITableView, cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        fatalError("Needs to be implemented by subclass")
    }

    open func tableView(
        _ tableView: UITableView, viewForHeaderInSection section: Int
    ) -> UIView? {
        if section == 0,
            let postData,
            let header = tableView.dequeueReusableHeaderFooterView(
                LMUIComponents.shared.postDetailHeaderView)
        {
            header.configure(
                with: postData.headerData, postID: postData.postID,
                userUUID: postData.userUUID, delegate: self)
            return header
        } else if var data = commentsData[safe: section - 1],
            let header = tableView.dequeueReusableHeaderFooterView(
                LMUIComponents.shared.commentView)
        {
            header.configure(
                with: data, delegate: self,
                indexPath: .init(row: NSNotFound, section: section)
            ) { [weak self] in
                data.isShowMore.toggle()
                self?.commentsData[section - 1] = data
                self?.reloadTable(
                    for: IndexPath(row: NSNotFound, section: section))
            }
            return header
        }
        return nil
    }

    open func tableView(
        _ tableView: UITableView, heightForHeaderInSection section: Int
    ) -> CGFloat {
        if section == 0 {
            return LMFeedConstants.shared.number.postHeaderSize
        } else if (commentsData[safe: section - 1]) != nil {
            return UITableView.automaticDimension
        }
        return .leastNormalMagnitude
    }

    open func tableView(
        _ tableView: UITableView, viewForFooterInSection section: Int
    ) -> UIView? {
        if section == 0,
            let postData,
            let footer = tableView.dequeueReusableHeaderFooterView(
                LMUIComponents.shared.postDetailFooterView)
        {
            footer.configure(
                with: postData.footerData, topResponse: postData.topResponse,
                postID: postData.postID, delegate: self,
                commentCount: postData.totalCommentCount)
            return footer
        } else if let data = commentsData[safe: section - 1],
            data.repliesCount != 0,
            data.repliesCount < data.totalReplyCount,
            let footer = tableView.dequeueReusableHeaderFooterView(
                LMUIComponents.shared.loadMoreReplies)
        {
            footer.configure(
                with: data.totalReplyCount, visibleComments: data.repliesCount
            ) { [weak self] in
                guard let commentID = data.commentId else { return }
                self?.viewModel?.getCommentReplies(
                    commentId: commentID, isClose: false)
            }

            return footer
        }
        return nil
    }

    open func tableView(
        _ tableView: UITableView, heightForFooterInSection section: Int
    ) -> CGFloat {
        if section == 0 {
            return UITableView.automaticDimension
        } else if commentsData[section - 1].repliesCount != 0,
            commentsData[section - 1].repliesCount
                < commentsData[section - 1].totalReplyCount
        {
            return UITableView.automaticDimension
        }
        return 1
    }

    open func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if let frozenContentOffsetForRowAnimation,
            postDetailListView.contentOffset
                != frozenContentOffsetForRowAnimation
        {
            postDetailListView.setContentOffset(
                frozenContentOffsetForRowAnimation, animated: false)
        }
    }

    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        frozenContentOffsetForRowAnimation = nil
        postDetailListView.visibleCells.forEach { cell in
            (cell as? LMFeedPostMediaCell)?.tableViewScrolled()
        }
    }

    open func tableView(
        _ tableView: UITableView, heightForRowAt indexPath: IndexPath
    ) -> CGFloat {
        UITableView.automaticDimension
    }

    open func tableView(
        _ tableView: UITableView, willDisplayHeaderView view: UIView,
        forSection section: Int
    ) {
        if section == commentsData.count - 1 {
            viewModel?.getPost(isInitialFetch: false)
        }
    }

    open func scrollViewDidEndDragging(
        _ scrollView: UIScrollView, willDecelerate decelerate: Bool
    ) {
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
                postDetailListView.percentVisibility(of: cell) >= 0.8
            {
                (cell as? LMFeedPostMediaCell)?.tableViewScrolled(isPlay: true)
            }
        }
    }

}

// MARK: LMFeedPostCommentProtocol
@objc
extension LMFeedBasePostDetailScreen: LMFeedPostCommentProtocol {
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
            viewModel.allowCommentLikeView(for: commentId)
        else { return }
        do {
            let viewcontroller = try LMFeedLikeViewModel.createModule(
                postID: viewModel.postID, commentID: commentId)
            navigationController?.pushViewController(
                viewcontroller, animated: true)
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
extension LMFeedBasePostDetailScreen: LMFeedBasePostDetailViewModelProtocol {

    /// Using this function to show post detail, fetch paginated comments
    public func showPostDetails(
        with post: LMFeedPostContentModel,
        comments: [LMFeedCommentContentModel], isInitialPage: Bool
    ) {
        setNavigationTitle(with: post.totalCommentCount)
        showHideLoaderView(isShow: false)

        if isInitialPage {
            commentsData.removeAll(keepingCapacity: true)
        }

        self.postData = post
        self.commentsData.append(contentsOf: comments)

        if isInitialPage {

            postDetailListView.reloadData()

        } else {
            insertNewComments(commentCount: comments.count)
            (postDetailListView.footerView(forSection: 0)
                as? LMFeedBasePostFooterView)?.configure(
                    with: post.footerData, topResponse: post.topResponse,
                    postID: post.postID, delegate: self)
        }
    }

    public func insertNewComments(commentCount: Int) {
        guard commentCount > 0 else { return }

        let startIndex = commentsData.count
        let endIndex = commentsData.count + commentCount - 1

        postDetailListView.beginUpdates()
        postDetailListView.insertSections(
            IndexSet(integersIn: startIndex...endIndex), with: .none)
        postDetailListView.endUpdates()
    }

    public func updatePost(
        post: LMFeedPostContentModel, onlyHeader: Bool, onlyFooter: Bool
    ) {
        postData = post

        setNavigationTitle(with: post.totalCommentCount)

        if onlyFooter {
            (postDetailListView.footerView(forSection: 0)
                as? LMFeedBasePostFooterView)?.configure(
                    with: post.footerData, topResponse: post.topResponse,
                    postID: post.postID, delegate: self)
        } else if onlyHeader {
            (postDetailListView.headerView(forSection: 0)
                as? LMFeedPostHeaderView)?.togglePinStatus(
                    isPinned: post.headerData.isPinned)
        } else {
            postDetailListView.reloadSections(.init(integer: 0), with: .none)
        }
    }

    /// Updates a comment or reply in the `commentsData` structure.
    ///
    /// This function is used for various operations including:
    /// - Inserting new replies.
    /// - Fetching and updating existing replies.
    /// - Updating comments or replies based on their unique identifiers.
    ///
    /// - Parameter comment: An `LMFeedCommentContentModel` object that represents the comment or reply to be updated.
    ///   It must contain at least one valid identifier (`commentId` or `tempCommentId`).
    ///
    /// - Functionality:
    ///   - If the provided comment matches an existing reply, it updates the reply at the appropriate index.
    ///   - If the provided comment matches a top-level comment, it updates the comment.
    ///   - Reloads the relevant section in the `postDetailListView` to reflect the changes.
    ///   - If no match is found, the function exits without making any changes.
    public func updateComment(comment: LMFeedCommentContentModel) {
        // Ensure the comment has a valid `commentId`; otherwise, exit early
        guard let commentId = comment.commentId else { return }

        // Use `findCommentOrReplyIndex` to locate the index and innerIndex for the comment or reply
        if let (index, innerIndex) = findCommentOrReplyIndex(
            for: comment.commentId ?? "",  // Primary identifier
            temporaryCommentID: comment.tempCommentId ?? ""  // Temporary identifier
        ) {
            // If `innerIndex` is not -1, it indicates the comment is a reply
            if innerIndex != -1 {
                commentsData[index].replies[innerIndex] = comment  // Update the reply
            } else {
                // Otherwise, it's a top-level comment, update the comment at `index`
                commentsData[index] = comment
            }

            // Reload the section in `postDetailListView` corresponding to the updated comment or reply
            postDetailListView.reloadSections(
                .init(integer: index + 1),  // Adjust index for section numbering
                with: .none  // No animation for reloading
            )
        } else {
            // If no match is found, exit the function
            return
        }
    }

    /// Finds the index and inner index of a comment or its reply within a nested comments structure.
    ///
    /// - Parameters:
    ///   - commentID: The unique identifier of the comment to search for.
    ///   - temporaryCommentID: An alternate identifier for the comment, often used for temporary data.
    /// - Returns:
    ///   A tuple `(index: Int, innerIndex: Int)`:
    ///     - `index`: Represents the position of the comment in the top-level comments array.
    ///     - `innerIndex`: Represents the position of the reply within the `replies` array of the parent comment.
    ///       If the found item is a top-level comment, `innerIndex` is `-1`.
    ///     - Returns `nil` if no comment or reply matches the provided IDs.
    func findCommentOrReplyIndex(
        for commentID: String, temporaryCommentID: String
    ) -> (index: Int, innerIndex: Int)? {

        // Iterate over the top-level comments array with their indices
        for (idx, comment) in commentsData.enumerated() {
            // Check if the comment matches the provided `commentID` or `temporaryCommentID`
            if comment.commentId == commentID
                || comment.tempCommentId == temporaryCommentID
            {
                return (idx, -1)  // Return the index with innerIndex as -1 since it's a top-level comment
            }

            // Iterate over the replies of the current comment with their indices
            for (innerIdx, innerComment) in comment.replies.enumerated() {
                // Check if the reply matches the provided `commentID` or `temporaryCommentID`
                if innerComment.commentId == commentID
                    || innerComment.tempCommentId == temporaryCommentID
                {
                    return (idx, innerIdx)  // Return both the top-level index and reply index
                }
            }
        }

        // Return nil if no matching comment or reply is found
        return nil
    }

    /// Deletes a reply from a specific parent comment in the `commentsData` structure.
    ///
    /// - Parameters:
    ///   - commentID: The unique identifier of the reply to be deleted.
    ///   - parentCommentID: The unique identifier of the parent comment containing the reply.
    ///
    /// - Functionality:
    ///   - Locates the parent comment using the `parentCommentID`.
    ///   - Searches for the reply within the parent comment's replies using the `commentID`.
    ///   - If both the parent and the reply are found, the reply is removed from the `commentsData`.
    ///   - Updates the UI by removing the corresponding row from `postDetailListView`.
    ///
    /// - Behavior:
    ///   - If either the parent comment or the reply is not found, the function exits without making changes.
    public func deleteReply(commentID: String, parentCommentID: String) {
        // Locate the index of the parent comment in `commentsData`
        guard
            let parentIndex = commentsData.firstIndex(where: {
                $0.commentId == parentCommentID  // Match parentCommentID
            }),
            // Locate the index of the reply within the parent's replies
            let commentIndex = commentsData[parentIndex].replies.firstIndex(
                where: {
                    $0.commentId == commentID  // Match reply commentID
                })
        else {
            return  // Exit if parent comment or reply is not found
        }

        // Remove the reply at `commentIndex` from the parent's replies
        commentsData[parentIndex].replies.remove(at: commentIndex)

        // Begin updates to the `postDetailListView`
        postDetailListView.beginUpdates()

        // Remove the corresponding row in the UI
        postDetailListView.deleteRows(
            at: [.init(row: commentIndex, section: parentIndex + 1)],  // Adjust section for display
            with: .none  // Perform deletion without animation
        )

        // End updates to finalize changes in the UI
        postDetailListView.endUpdates()
    }

    /// Deletes a top-level comment from the `commentsData` structure.
    ///
    /// - Parameter commentID: The unique identifier of the comment to be deleted.
    ///
    /// - Functionality:
    ///   - Locates the comment in the `commentsData` array using the provided `commentID`.
    ///   - Removes the comment from the data structure if found.
    ///   - Updates the UI by removing the corresponding section in the `postDetailListView`.
    ///   - Updates the footer view to reflect the new comment count.
    ///
    /// - Behavior:
    ///   - If the comment is not found, the function exits without making any changes.
    public func deleteComment(commentID: String) {
        // Locate the index of the comment in `commentsData`
        guard
            let index = commentsData.firstIndex(where: {
                $0.commentId == commentID  // Match the provided commentID
            })
        else {
            return  // Exit if the comment is not found
        }

        // Remove the comment from the data structure
        commentsData.remove(at: index)

        // Begin updates to the `postDetailListView`
        postDetailListView.beginUpdates()

        // Remove the corresponding section from the UI
        postDetailListView.deleteSections(
            .init(integer: index + 1),  // Adjust section for display
            with: .none  // Perform deletion without animation
        )

        // Update the footer view to reflect the new comment count
        let footerView =
            (postDetailListView.footerView(forSection: 0)
                as? LMFeedPostDetailFooterView)  // Cast to the specific footer view type
        footerView?.updateCommentCount(with: commentsData.count)

        // End updates to finalize changes in the UI
        postDetailListView.endUpdates()
    }

    /// Inserts a new comment into the `commentsData` structure and updates the UI.
    ///
    /// - Parameters:
    ///   - comment: The `LMFeedCommentContentModel` object representing the new comment to be inserted.
    ///   - index: The position in the `commentsData` array where the comment should be inserted.
    ///            Must be between 0 and the current count of `commentsData`.
    ///
    /// - Functionality:
    ///   - Validates the index to ensure it's within bounds.
    ///   - Inserts the new comment into the `commentsData` array at the specified index.
    ///   - Updates the `postDetailListView` to display the newly inserted comment as a new section.
    ///   - Adjusts subsequent sections in the view to maintain the correct order.
    ///   - Updates the footer view to reflect the new comment count.
    ///
    /// - Behavior:
    ///   - If the index is invalid, the function prints an error message and exits without making changes.
    public func insertComment(comment: LMFeedCommentContentModel, index: Int) {
        // Validate the index to ensure it's within bounds
        guard index >= 0 && index <= commentsData.count else {
            print("Invalid index for comment insertion")  // Print error if index is out of bounds
            return
        }

        // Insert the new comment into the `commentsData` array
        commentsData.insert(comment, at: index)

        // Calculate the section index in the `postDetailListView`
        let sectionIndex = index + 1  // Adjust for section 0 being the post

        // Perform batch updates to add the new comment to the UI
        postDetailListView.performBatchUpdates(
            {
                // Insert a new section for the new comment
                let newSectionIndex = IndexSet(integer: sectionIndex)
                self.postDetailListView.insertSections(
                    newSectionIndex, with: .none)

                // Shift all subsequent sections down by 1 to maintain correct order
                if sectionIndex < self.postDetailListView.numberOfSections - 1 {
                    for i
                        in (sectionIndex
                        + 1..<self.postDetailListView.numberOfSections)
                        .reversed()
                    {
                        self.postDetailListView.moveSection(i, toSection: i + 1)
                    }
                }
            }, completion: nil)

        // Update the footer view to reflect the new comment count
        let footerView =
            (postDetailListView.footerView(forSection: 0)
                as? LMFeedPostDetailFooterView)  // Cast to specific footer view type
        footerView?.updateCommentCount(with: commentsData.count)
    }

    /// Handles scrolling and opening the comment input section based on the provided flags.
    ///
    /// - Parameters:
    ///   - openCommentSection: A boolean flag indicating whether to open the comment input section and focus on the input field.
    ///   - scrollToCommentSection: A boolean flag indicating whether to scroll to the comments section in the `postDetailListView`.
    ///
    /// - Functionality:
    ///   - If `openCommentSection` is `true` and commenting is enabled, it focuses on the comment input field with a slight delay to ensure the UI is ready.
    ///   - If `scrollToCommentSection` is `true`, it scrolls to the comments section in the `postDetailListView` if there is at least one section.
    ///
    /// - Behavior:
    ///   - Ensures the input field is properly activated when opening the comment section.
    ///   - Scrolls smoothly to the comments section, aligning to the bottom of the section for better visibility.
    public func handleCommentScroll(
        openCommentSection: Bool, scrollToCommentSection: Bool
    ) {
        // Check if the comment section should be opened and commenting is enabled
        if openCommentSection,
            isCommentingEnabled
        {
            // Delay focusing on the input field to ensure the UI is fully loaded
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                [weak self] in
                self?.inputTextView.becomeFirstResponder()  // Activate the input field
            }
        }

        // Check if there are sections and scrolling to the comment section is required
        if postDetailListView.numberOfSections >= 1,
            scrollToCommentSection
        {
            // Scroll to the comments section (section 1) and align to the bottom
            postDetailListView.scrollToRow(
                at: IndexPath(row: NSNotFound, section: 1),  // Scroll to the first row in section 1
                at: .bottom,  // Align to the bottom of the section
                animated: true  // Enable smooth scrolling
            )
        }
    }

    /// Toggles the "like" state of a comment or reply and updates the corresponding like count.
    ///
    /// - Parameter indexPath: The `IndexPath` representing the location of the comment or reply to update.
    ///   - `indexPath.section`: Identifies the top-level comment in the `commentsData` array. Adjusted by `-1` since section 0 represents the post.
    ///   - `indexPath.row`: Specifies the reply within the top-level comment's `replies` array. If `NSNotFound`, the top-level comment is targeted.
    ///
    /// - Functionality:
    ///   - Checks if the provided `indexPath` is valid within the `commentsData` structure.
    ///   - Toggles the `isLiked` state for the targeted comment or reply.
    ///   - Increments or decrements the `likeCount` accordingly.
    ///   - Updates the `commentsData` structure to reflect the changes.
    ///
    /// - Behavior:
    ///   - If the `indexPath.row` is `NSNotFound`, it targets a top-level comment.
    ///   - If `indexPath.row` specifies a valid index, it targets a reply within the top-level comment.
    ///   - Safely handles invalid indices using array bounds checks.
    public func changeCommentLike(for indexPath: IndexPath) {
        // Safely access the top-level comment in `commentsData` corresponding to the provided section
        if var sectionData = commentsData[safe: indexPath.section - 1] {

            // Check if the target is a top-level comment
            if indexPath.row == NSNotFound {
                let isLiked = sectionData.isLiked  // Get the current like state
                sectionData.isLiked = !isLiked  // Toggle the like state
                sectionData.likeCount += !isLiked ? 1 : -1  // Adjust the like count accordingly
            }
            // Check if the target is a reply within the top-level comment's replies
            else if var reply = sectionData.replies[safe: indexPath.row] {
                let isLiked = reply.isLiked  // Get the current like state
                reply.isLiked = !isLiked  // Toggle the like state
                reply.likeCount += !isLiked ? 1 : -1  // Adjust the like count accordingly
                sectionData.replies[indexPath.row] = reply  // Update the reply in the array
            }

            // Update the top-level comment in `commentsData` to reflect changes
            commentsData[indexPath.section - 1] = sectionData
        }
    }

    /// Prepares the UI for replying to a comment by displaying the "Replying To" label
    /// and focusing on the input text view.
    ///
    /// - Parameter userName: The name of the user whose comment is being replied to.
    ///
    /// - Functionality:
    ///   - Constructs an attributed string with "Replying To" and the user's name, applying different styles to each part.
    ///   - Updates the `replyNameLabel` with the constructed attributed string.
    ///   - Displays the `replyView` and focuses on the `inputTextView` to allow the user to type their reply.
    ///
    /// - Behavior:
    ///   - Ensures the reply view is visible and the input field is activated for a seamless user experience.
    public func replyToComment(userName: String) {
        // Create an attributed string for the "Replying To" text with gray color and specific font
        let replyLabelText = NSMutableAttributedString(
            string: "Replying To ",
            attributes: [
                .font: LMFeedAppearance.shared.fonts.textFont2,  // Set the font for the label
                .foregroundColor: LMFeedAppearance.shared.colors.gray51,  // Set the text color to gray
            ]
        )

        // Append the user's name with a different color and the same font
        replyLabelText.append(
            NSAttributedString(
                string: userName,
                attributes: [
                    .font: LMFeedAppearance.shared.fonts.textFont2,  // Set the font for the user name
                    .foregroundColor: LMFeedAppearance.shared.colors
                        .appTintColor,  // Set the text color to app tint color
                ]
            )
        )

        // Update the reply name label with the constructed attributed string
        replyNameLabel.attributedText = replyLabelText

        // Make the reply view visible
        replyView.isHidden = false

        // Activate the input text view to allow the user to type their reply
        inputTextView.becomeFirstResponder()
    }

    /// Updates the comment input field and its related UI elements based on the commenting status.
    ///
    /// - Parameter isEnabled: A boolean value that determines whether commenting is enabled.
    ///   - `true`: Enables commenting and allows interaction with the input field.
    ///   - `false`: Disables commenting and displays a placeholder indicating no permission.
    public func updateCommentStatus(isEnabled: Bool) {
        isCommentingEnabled = isEnabled

        // Update the placeholder text in the input text view
        inputTextView.placeHolderText =
            isCommentingEnabled
            ? LMStringConstants.shared.writeComment
            : LMStringConstants.shared.noCommentPermission

        // Clear the input text view and update interaction state
        inputTextView.setAttributedText(from: "")
        inputTextView.isUserInteractionEnabled = isCommentingEnabled

        // Show or hide the send button based on the commenting status
        sendButton.isHidden = !isCommentingEnabled
    }

    /// Navigates to the delete confirmation screen for a post or comment.
    ///
    /// - Parameters:
    ///   - postID: The unique identifier of the post to delete.
    ///   - commentID: (Optional) The unique identifier of the comment to delete.
    public func navigateToDeleteScreen(for postID: String, commentID: String?) {
        guard
            let viewcontroller = LMFeedDeleteViewModel.createModule(
                postID: postID, commentID: commentID)
        else { return }

        // Present the delete confirmation screen as a modal
        viewcontroller.modalPresentationStyle = .overFullScreen
        present(viewcontroller, animated: false)
    }

    /// Navigates to the report screen for a post, comment, or reply.
    ///
    /// - Parameters:
    ///   - postID: The unique identifier of the post to report.
    ///   - creatorUUID: The unique identifier of the post creator.
    ///   - commentID: (Optional) The unique identifier of the comment to report.
    ///   - replyCommentID: (Optional) The unique identifier of the reply to report.
    public func navigateToReportScreen(
        for postID: String, creatorUUID: String, commentID: String?,
        replyCommentID: String?
    ) {
        do {
            // Create the report screen view controller
            let viewcontroller = try LMFeedReportViewModel.createModule(
                creatorUUID: creatorUUID, postID: postID, commentID: commentID,
                replyCommentID: replyCommentID)

            // Push the report screen onto the navigation stack
            navigationController?.pushViewController(
                viewcontroller, animated: true)
        } catch let error {
            print(error.localizedDescription)  // Log any error that occurs during creation
        }
    }

    /// Sets the input text view for editing a comment with pre-filled text.
    ///
    /// - Parameter text: The initial text to populate in the input text view.
    public func setEditCommentText(with text: String) {
        // Set the input text with a prefix
        inputTextView.setAttributedText(from: text, prefix: "@")

        // Focus the input text view
        inputTextView.becomeFirstResponder()

        // Notify that the content height has changed
        contentHeightChanged()
    }

    /// Navigates to the poll results screen for a specific poll.
    ///
    /// - Parameters:
    ///   - pollID: The unique identifier of the poll.
    ///   - optionList: A list of available options in the poll.
    ///   - selectedOption: (Optional) The option selected by the user.
    public func navigateToPollResultScreen(
        with pollID: String, optionList: [LMFeedPollDataModel.Option],
        selectedOption: String?
    ) {
        do {
            // Create the poll results view controller
            let viewcontroller = try LMFeedPollResultViewModel.createModule(
                with: pollID, optionList: optionList,
                selectedOption: selectedOption)

            // Push the poll results screen onto the navigation stack
            navigationController?.pushViewController(
                viewcontroller, animated: true)
        } catch {
            print("Error in \(#function)")  // Log any error that occurs during creation
        }
    }

    /// Navigates to the screen for adding options to a poll.
    ///
    /// - Parameters:
    ///   - postID: The unique identifier of the post containing the poll.
    ///   - pollID: The unique identifier of the poll.
    ///   - options: A list of existing poll options.
    public func navigateToAddOptionPoll(
        with postID: String, pollID: String, options: [String]
    ) {
        do {
            // Create the add option view controller
            let viewcontroller = try LMFeedPollAddOptionViewModel.createModule(
                for: postID, pollID: pollID, options: options, delegate: self)

            // Present the screen as a modal
            viewcontroller.modalPresentationStyle = .overFullScreen
            present(viewcontroller, animated: false)
        } catch let error {
            print(error.localizedDescription)  // Log any error that occurs during creation
        }
    }

    /// Navigates to the edit post screen for a specific post.
    ///
    /// - Parameter postID: The unique identifier of the post to edit.
    public func navigateToEditPost(for postID: String) {
        guard
            let viewcontroller = LMFeedEditPostViewModel.createModule(
                for: postID)
        else { return }

        // Push the edit post screen onto the navigation stack
        navigationController?.pushViewController(viewcontroller, animated: true)
    }

}

// MARK: LMFeedTaggingTextViewProtocol
@objc
extension LMFeedBasePostDetailScreen: LMFeedTaggingTextViewProtocol {
    open func mentionStarted(with text: String) {
        taggingView.getUsers(for: text)
    }

    open func mentionStopped() {
        taggingView.stopFetchingUsers()
    }

    open func contentHeightChanged() {
        let width = inputTextView.frame.size.width

        let newSize = inputTextView.sizeThatFits(
            CGSize(width: width, height: .greatestFiniteMagnitude))

        inputTextView.isScrollEnabled = newSize.height > textInputMaximumHeight
        inputTextViewHeightConstraint?.constant = min(
            max(40, newSize.height), textInputMaximumHeight)

        sendButton.isEnabled =
            !inputTextView.attributedText.string.trimmingCharacters(
                in: .whitespacesAndNewlines
            ).isEmpty
            && inputTextView.text.trimmingCharacters(
                in: .whitespacesAndNewlines) != inputTextView.placeHolderText
    }
}

// MARK: LMFeedTaggedUserFoundProtocol
extension LMFeedBasePostDetailScreen: LMFeedTaggedUserFoundProtocol {
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
extension LMFeedBasePostDetailScreen: LMFeedPostHeaderViewProtocol,
    LMFeedPostFooterViewProtocol
{
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
            let viewcontroller = try LMFeedLikeViewModel.createModule(
                postID: postID)
            navigationController?.pushViewController(
                viewcontroller, animated: true)
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
        showError(
            with: "Tapped User Profile having uuid: \(uuid)", isPopVC: false)
    }
}

// MARK: LMFeedLinkProtocol, LMFeedPostDocumentCellProtocol, LMFeedPostMediaCellProtocol
@objc
extension LMFeedBasePostDetailScreen: LMFeedLinkProtocol,
    LMFeedPostDocumentCellProtocol, LMFeedPostMediaCellProtocol
{
    public func didTapMedia(postID: String, index: Int) {
        guard let postData else {
            return
        }
        do {
            let viewcontroller = try LMFeedMediaPreviewViewModel.createModule(
                with: postData, postID: postData.postID, startIndex: index)
            navigationController?.pushViewController(
                viewcontroller, animated: true)
        } catch let error {
            print(error.localizedDescription)
        }
    }

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
extension LMFeedBasePostDetailScreen: LMFeedPostPollCellProtocol {
    public func didTapVoteCountButton(
        for postID: String, pollID: String, optionID: String?
    ) {
        viewModel?.didTapVoteCountButton(
            for: postID, pollID: pollID, optionID: optionID)
    }

    public func didTapToVote(
        for postID: String, pollID: String, optionID: String
    ) {
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
extension LMFeedBasePostDetailScreen: LMFeedAddOptionProtocol {
    public func onAddOptionResponse(
        postID: String, success: Bool, errorMessage: String?
    ) {
        if !success {
            showError(
                with: errorMessage ?? "Something went wrong", isPopVC: false)
        } else {
            viewModel?.getPost(isInitialFetch: true)
        }
    }
}

public func getRowType(for row: Int, in item: LMFeedPostContentModel)
    -> LMFeedPostType
{
    // First row is for text, subsequent rows are for attachments
    let isTopicsEmpty = item.topics.topics.isEmpty
    let isTextAndHeadingEmpty =
        item.postText.isEmpty && item.postQuestion.isEmpty

    if row == 0, !isTopicsEmpty {
        return .topic
    }

    if row == 0, isTopicsEmpty,
        !isTextAndHeadingEmpty
    {
        return .text
    }

    if row == 1, !isTopicsEmpty, !isTextAndHeadingEmpty {
        return .text
    }

    return item.postType
}
