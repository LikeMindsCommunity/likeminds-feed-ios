import UIKit
import LikeMindsFeedUI

open class LMFeedCommentBottomsheet: LMFeedViewController, LMFeedBasePostDetailViewModelProtocol {
    public func showPostDetails(with post: LMFeedPostContentModel, comments: [LMFeedCommentContentModel], isInitialPage: Bool) {
        if isInitialPage {
            commentsData.removeAll(keepingCapacity: true)
            isInitialLoad = false
        }
        
        // Update pagination state
        hasMoreData = !comments.isEmpty
        isLoadingMore = false
        
        commentsData.append(contentsOf: comments)
        
        // Show/hide no comments view based on comments count
        noCommentContainerView.isHidden = !commentsData.isEmpty
        commentTableView.isHidden = commentsData.isEmpty
        
        commentTableView.reloadData()
    }
    
    public func updatePost(post: LMFeedPostContentModel, onlyHeader: Bool, onlyFooter: Bool) {
        // Not needed for comment bottomsheet
    }
    
    public func updateComment(comment: LMFeedCommentContentModel) {
        if let (index, innerIndex) = findCommentOrReplyIndex(for: comment.commentId ?? "", temporaryCommentID: comment.tempCommentId ?? "") {
            if innerIndex != -1 {
                commentsData[index].replies[innerIndex] = comment
            } else {
                commentsData[index] = comment
            }
            commentTableView.reloadSections(.init(integer: index), with: .none)
        }
    }
    
    public func deleteComment(commentID: String) {
        if let index = commentsData.firstIndex(where: { $0.commentId == commentID }) {
            commentsData.remove(at: index)
            commentTableView.deleteSections(.init(integer: index), with: .none)
        }
    }
    
    public func deleteReply(commentID: String, parentCommentID: String) {
        if let parentIndex = commentsData.firstIndex(where: { $0.commentId == parentCommentID }),
           let commentIndex = commentsData[parentIndex].replies.firstIndex(where: { $0.commentId == commentID }) {
            commentsData[parentIndex].replies.remove(at: commentIndex)
            commentTableView.deleteRows(at: [.init(row: commentIndex, section: parentIndex)], with: .none)
        }
    }
    
    public func insertComment(comment: LMFeedCommentContentModel, index: Int) {
        commentsData.insert(comment, at: index)
//        commentTableView.insertSections(.init(integer: index), with: .none)
        noCommentContainerView.isHidden = true
        commentTableView.isHidden = false
            
            // Insert the new section
        commentTableView.insertSections(.init(integer: index), with: .none)
    }
    
    public func replyToComment(userName: String) {
        let replyLabelText = NSMutableAttributedString(
            string: "Replying To ",
            attributes: [
                .font: LMFeedAppearance.shared.fonts.textFont2,
                .foregroundColor: LMFeedAppearance.shared.colors.gray51,
            ]
        )

        replyLabelText.append(
            NSAttributedString(
                string: userName,
                attributes: [
                    .font: LMFeedAppearance.shared.fonts.textFont2,
                    .foregroundColor: LMFeedAppearance.shared.colors.appTintColor,
                ]
            )
        )

        replyNameLabel.attributedText = replyLabelText
        replyView.isHidden = false
        replySepratorView.isHidden = false
        inputTextView.becomeFirstResponder()
    }
    
    public func updateCommentStatus(isEnabled: Bool) {
        isCommentingEnabled = isEnabled
        inputTextView.placeHolderText = isCommentingEnabled ? LMStringConstants.shared.writeComment : LMStringConstants.shared.noCommentPermission
        inputTextView.setAttributedText(from: "")
        inputTextView.isUserInteractionEnabled = isCommentingEnabled
        sendButton.isHidden = !isCommentingEnabled
    }
    
    public func setEditCommentText(with text: String) {
        inputTextView.setAttributedText(from: text, prefix: "@")
        inputTextView.becomeFirstResponder()
        contentHeightChanged()
    }
    
    public func navigateToEditPost(for postID: String) {
        // Not needed for comment bottomsheet
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
    
    public func handleCommentScroll(openCommentSection: Bool, scrollToCommentSection: Bool) {
        if openCommentSection, isCommentingEnabled {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                self?.inputTextView.becomeFirstResponder()
            }
        }
        
        if commentTableView.numberOfSections >= 1, scrollToCommentSection {
            commentTableView.scrollToRow(at: IndexPath(row: NSNotFound, section: 1), at: .bottom, animated: true)
        }
    }
    
    public func navigateToPollResultScreen(with pollID: String, optionList: [LMFeedPollDataModel.Option], selectedOption: String?) {
        // Not needed for comment bottomsheet
    }
    
    public func navigateToAddOptionPoll(with postID: String, pollID: String, options: [String]) {
        // Not needed for comment bottomsheet
    }
    
    private func findCommentOrReplyIndex(for commentID: String, temporaryCommentID: String) -> (index: Int, innerIndex: Int)? {
        for (idx, comment) in commentsData.enumerated() {
            if comment.commentId == commentID || comment.tempCommentId == temporaryCommentID {
                return (idx, -1)
            }
            
            for (innerIdx, innerComment) in comment.replies.enumerated() {
                if innerComment.commentId == commentID || innerComment.tempCommentId == temporaryCommentID {
                    return (idx, innerIdx)
                }
            }
        }
        return nil
    }
    
    // MARK: UI Elements
    open private(set) lazy var contentView: LMFeedView = {
        let view = LMFeedView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        return view
    }()
    
    open private(set) lazy var headerView: LMFeedView = {
        let view = LMFeedView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = LMFeedAppearance.shared.colors.white
        return view
    }()
    
    open private(set) lazy var dragHandlerView: LMFeedView = {
        let view = LMFeedView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = LMFeedAppearance.shared.colors.gray155
        view.layer.cornerRadius = 2.5
        return view
    }()
    
    open private(set) lazy var headerTitleLabel: LMFeedLabel = {
        let label = LMFeedLabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Comments"
        label.font = LMFeedAppearance.shared.fonts.headingFont1
        label.textColor = LMFeedAppearance.shared.colors.gray1
        label.textAlignment = .center
        return label
    }()
    
    open private(set) lazy var commentTableView: LMFeedTableView = {
        let table = LMFeedTableView(frame: .zero, style: .grouped)
        table.translatesAutoresizingMaskIntoConstraints = false
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
    
    open private(set) lazy var containerView: LMFeedView = {
        let view = LMFeedView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = LMFeedAppearance.shared.colors.white
        return view
    }()
    
    open private(set) lazy var inputTextView: LMFeedTaggingTextView = {
        let textView = LMFeedTaggingTextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.isEditable = true
        textView.isScrollEnabled = false
        textView.backgroundColor = LMFeedAppearance.shared.colors.clear
        textView.textColor = LMFeedAppearance.shared.colors.textColor
        textView.contentMode = .center
        textView.font = LMFeedAppearance.shared.fonts.textFont1
        textView.placeHolderText = LMStringConstants.shared.writeComment
        textView.setAttributedText(from: "")
        return textView
    }()
    
    open private(set) lazy var sendButton: LMFeedButton = {
        let button = LMFeedButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(nil, for: .normal)
        button.setImage(LMFeedConstants.shared.images.planeIconFilled, for: .normal)
        button.tintColor = LMFeedAppearance.shared.colors.appTintColor
        button.isEnabled = false
        return button
    }()
    
    open private(set) lazy var stackView: LMFeedStackView = {
        let stack = LMFeedStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.alignment = .center
        stack.distribution = .fill
        stack.backgroundColor = LMFeedAppearance.shared.colors.clear
        return stack
    }()
    
    open private(set) lazy var replyView: LMFeedView = {
        let view = LMFeedView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = LMFeedAppearance.shared.colors.white
        return view
    }()

    open private(set) lazy var replyNameLabel: LMFeedLabel = {
        let label = LMFeedLabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Replying To XYZ"
        label.font = LMFeedAppearance.shared.fonts.textFont1
        label.textColor = LMFeedAppearance.shared.colors.gray3
        return label
    }()

    open private(set) lazy var removeReplyButton: LMFeedButton = {
        let button = LMFeedButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(nil, for: .normal)
        button.setImage(LMFeedConstants.shared.images.xmarkIcon, for: .normal)
        button.tintColor = LMFeedAppearance.shared.colors.gray3
        return button
    }()

    open private(set) lazy var replySepratorView: LMFeedView = {
        let view = LMFeedView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = LMFeedAppearance.shared.colors.sepratorColor
        return view
    }()
    
    open private(set) lazy var noCommentContainerView: LMFeedView = {
        let view = LMFeedView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = LMFeedAppearance.shared.colors.white
        return view
    }()
    
    open private(set) lazy var noCommentTitleLabel: LMFeedLabel = {
        let label = LMFeedLabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = LMStringConstants.shared.noCommentTitleLable
        label.textColor = LMFeedAppearance.shared.colors.gray51
        label.font = LMFeedAppearance.shared.fonts.headingFont3
        label.textAlignment = .center
        return label
    }()
    
    open private(set) lazy var noCommentSubtitleLabel: LMFeedLabel = {
        let label = LMFeedLabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = LMStringConstants.shared.noCommentSubTitleLable
        label.textColor = LMFeedAppearance.shared.colors.gray102
        label.font = LMFeedAppearance.shared.fonts.textFont1
        label.textAlignment = .center
        return label
    }()
    
    open private(set) lazy var taggingView: LMFeedTaggingListView = {
        let view = LMFeedTaggingListViewModel.createModule(delegate: self)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = LMFeedAppearance.shared.colors.clear
        view.isUserInteractionEnabled = true
        return view
    }()
    
    // MARK: Data Variables
    open private(set) var postID: String
    open private(set) var commentsData: [LMFeedCommentContentModel] = []
    open private(set) var isCommentingEnabled: Bool = LocalPreferences.memberState?.memberRights?.contains(where: { $0.state == .commentOrReplyOnPost }) ?? false
    open private(set) var inputTextViewHeightConstraint: NSLayoutConstraint?
    open private(set) var textInputMaximumHeight: CGFloat = 100
    open private(set) var viewModel: LMFeedPostDetailViewModel
    open private(set) var isInitialLoad = true
    open private(set) var isLoadingMore = false
    open private(set) var hasMoreData = true
    open private(set) var taggingViewHeightConstraint: NSLayoutConstraint?
    open private(set) var inputTextViewBottomConstraint: NSLayoutConstraint?
    
    // MARK: Initialization
    public init(postID: String, viewModel: LMFeedPostDetailViewModel) {
        self.postID = postID
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        self.viewModel.delegate = self
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Lifecycle Methods
    open override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        replyView.isHidden = true
        updateCommentStatus(
            isEnabled: LocalPreferences.memberState?.memberRights?.contains(
                where: { $0.state == .commentOrReplyOnPost }) ?? false)
        viewModel.getMemberState()
        if isInitialLoad {
            viewModel.getPost(isInitialFetch: true)
        }
    }
    
    open func setupTableView() {
        commentTableView.register(LMUIComponents.shared.replyView)
        commentTableView.registerHeaderFooter(LMUIComponents.shared.loadMoreReplies)
        commentTableView.registerHeaderFooter(LMUIComponents.shared.commentView)
    }
    
    // MARK: Setup Methods
    open override func setupViews() {
        super.setupViews()
        view.addSubview(contentView)
        contentView.addSubview(containerView)
        containerView.addSubview(headerView)
        containerView.addSubview(commentTableView)
        containerView.addSubview(noCommentContainerView)
        containerView.addSubview(replySepratorView)
        containerView.addSubview(replyView)
        containerView.addSubview(stackView)
        containerView.addSubview(taggingView)
        
        headerView.addSubview(dragHandlerView)
        headerView.addSubview(headerTitleLabel)
        
        noCommentContainerView.addSubview(noCommentTitleLabel)
        noCommentContainerView.addSubview(noCommentSubtitleLabel)
        
        replyView.addSubview(replyNameLabel)
        replyView.addSubview(removeReplyButton)
        
        stackView.addArrangedSubview(inputTextView)
        stackView.addArrangedSubview(sendButton)
    }
    
    open override func setupLayouts() {
        super.setupLayouts()
        contentView.pinSubView(subView: containerView)
        
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: view.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            headerView.topAnchor.constraint(equalTo: containerView.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 72),
            
            dragHandlerView.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 12),
            dragHandlerView.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            dragHandlerView.widthAnchor.constraint(equalToConstant: 40),
            dragHandlerView.heightAnchor.constraint(equalToConstant: 5),
            
            headerTitleLabel.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            headerTitleLabel.topAnchor.constraint(equalTo: dragHandlerView.bottomAnchor, constant: 16),
            
            commentTableView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            commentTableView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            commentTableView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            commentTableView.bottomAnchor.constraint(equalTo: replySepratorView.topAnchor),
            
            noCommentContainerView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            noCommentContainerView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            noCommentContainerView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            
            noCommentTitleLabel.topAnchor.constraint(equalTo: noCommentContainerView.topAnchor, constant: 16),
            noCommentTitleLabel.centerXAnchor.constraint(equalTo: noCommentContainerView.centerXAnchor),
            
            noCommentSubtitleLabel.topAnchor.constraint(equalTo: noCommentTitleLabel.bottomAnchor, constant: 2),
            noCommentSubtitleLabel.bottomAnchor.constraint(equalTo: noCommentContainerView.bottomAnchor, constant: -16),
            noCommentSubtitleLabel.centerXAnchor.constraint(equalTo: noCommentTitleLabel.centerXAnchor),
            
            replySepratorView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            replySepratorView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            replySepratorView.bottomAnchor.constraint(equalTo: replyView.topAnchor),
            replySepratorView.heightAnchor.constraint(equalToConstant: 1),
            
            replyView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            replyView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            replyView.bottomAnchor.constraint(equalTo: stackView.topAnchor),
            replyView.heightAnchor.constraint(equalToConstant: 52),
            
            replyNameLabel.topAnchor.constraint(equalTo: replyView.topAnchor, constant: 16),
            replyNameLabel.bottomAnchor.constraint(equalTo: replyView.bottomAnchor, constant: -16),
            replyNameLabel.leadingAnchor.constraint(equalTo: replyView.leadingAnchor, constant: 16),
            
            removeReplyButton.leadingAnchor.constraint(equalTo: replyNameLabel.trailingAnchor, constant: 16),
            removeReplyButton.trailingAnchor.constraint(equalTo: replyView.trailingAnchor, constant: -16),
            removeReplyButton.centerYAnchor.constraint(equalTo: replyNameLabel.centerYAnchor),
            removeReplyButton.widthAnchor.constraint(equalTo: removeReplyButton.heightAnchor),
            
            stackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16),
            
            inputTextView.topAnchor.constraint(equalTo: stackView.topAnchor),
            inputTextView.bottomAnchor.constraint(equalTo: stackView.bottomAnchor),
            
            sendButton.widthAnchor.constraint(equalTo: sendButton.heightAnchor),
            
            taggingView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            taggingView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            taggingView.bottomAnchor.constraint(equalTo: stackView.topAnchor)
        ])
        
        inputTextViewHeightConstraint = inputTextView.heightAnchor.constraint(equalToConstant: 30)
        inputTextViewHeightConstraint?.isActive = true
        
        taggingViewHeightConstraint = taggingView.heightAnchor.constraint(equalToConstant: 0)
        taggingViewHeightConstraint?.isActive = true
        
        inputTextViewBottomConstraint = containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        inputTextViewBottomConstraint?.isActive = true
    }
    
    open override func setupActions() {
        super.setupActions()
        inputTextView.mentionDelegate = self
        sendButton.addTarget(self, action: #selector(didTapSendCommentButton), for: .touchUpInside)
        inputTextView.addDoneButtonOnKeyboard()
        removeReplyButton.addTarget(self, action: #selector(didTapReplyCrossButton), for: .touchUpInside)
    }
    
    open override func setupAppearance() {
        super.setupAppearance()
        view.backgroundColor = .clear
        containerView.backgroundColor = LMFeedAppearance.shared.colors.white
        commentTableView.backgroundColor = LMFeedAppearance.shared.colors.backgroundColor
    }
    
    open override func setupObservers() {
        super.setupObservers()
        
        NotificationCenter.default.addObserver(
            self, selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(
            self, selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc
    open func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            inputTextViewBottomConstraint?.constant = -keyboardSize.size.height
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
            }
        }
    }
    
    @objc
    open func keyboardWillHide(notification: NSNotification) {
        inputTextViewBottomConstraint?.constant = .zero
        containerView.layoutIfNeeded()
    }
    
    // MARK: Action Methods
    @objc
    open func didTapReplyCrossButton() {
        replyView.isHidden = true
        replySepratorView.isHidden = true
        viewModel.replyToComment(having: nil)
    }

    @objc
    open func didTapSendCommentButton() {
        let commentText = inputTextView.getText()
        viewModel.sendButtonTapped(with: commentText)
        inputTextView.resignFirstResponder()
        inputTextView.setAttributedText(from: "")
        contentHeightChanged()
        replyView.isHidden = true
    }
}

// MARK: UITableViewDataSource, UITableViewDelegate
extension LMFeedCommentBottomsheet: UITableViewDataSource, UITableViewDelegate {
    public func numberOfSections(in tableView: UITableView) -> Int {
        return commentsData.count
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return commentsData[section].replies.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(LMUIComponents.shared.replyView) {
            let comment = commentsData[indexPath.section].replies[indexPath.row]
            cell.configure(with: comment, delegate: self, indexPath: indexPath)
            return cell
        }
        return UITableViewCell()
    }
    
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if let header = tableView.dequeueReusableHeaderFooterView(LMUIComponents.shared.commentView) {
            header.configure(with: commentsData[section], delegate: self, indexPath: IndexPath(row: NSNotFound, section: section)) { [weak self] in
                self?.commentsData[section].isShowMore.toggle()
                self?.commentTableView.reloadSections(IndexSet(integer: section), with: .none)
            }
            return header
        }
        return nil
    }
    
    public func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let data = commentsData[section]
        if data.repliesCount != 0,
           data.repliesCount < data.totalReplyCount,
           let footer = tableView.dequeueReusableHeaderFooterView(LMUIComponents.shared.loadMoreReplies) {
            footer.configure(with: data.totalReplyCount, visibleComments: data.repliesCount) { [weak self] in
                guard let commentID = data.commentId else { return }
                self?.viewModel.getCommentReplies(commentId: commentID, isClose: false)
            }
            return footer
        }
        return nil
    }
    
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    public func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        let data = commentsData[section]
        if data.repliesCount != 0,
           data.repliesCount < data.totalReplyCount {
            return UITableView.automaticDimension
        }
        return 1
    }
    
    public func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        // Only load more if we're not already loading, have more data, and not in initial load
        if !isLoadingMore && hasMoreData && !isInitialLoad && section == commentsData.count - 1 {
            isLoadingMore = true
            viewModel.getPost(isInitialFetch: false)
        }
    }
}

// MARK: LMFeedTaggingTextViewProtocol
extension LMFeedCommentBottomsheet: LMFeedTaggingTextViewProtocol {
    public func mentionStarted(with text: String) {
        taggingView.getUsers(for: text)
    }
    
    public func mentionStopped() {
        taggingView.stopFetchingUsers()
    }
    
    public func contentHeightChanged() {
        let width = inputTextView.frame.size.width
        let newSize = inputTextView.sizeThatFits(CGSize(width: width, height: .greatestFiniteMagnitude))
        
        inputTextView.isScrollEnabled = newSize.height > textInputMaximumHeight
        inputTextViewHeightConstraint?.constant = min(max(40, newSize.height), textInputMaximumHeight)
        
        sendButton.isEnabled = !inputTextView.attributedText.string.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && 
            inputTextView.text.trimmingCharacters(in: .whitespacesAndNewlines) != inputTextView.placeHolderText
    }
}

// MARK: LMFeedTaggedUserFoundProtocol
extension LMFeedCommentBottomsheet: LMFeedTaggedUserFoundProtocol {
    public func userSelected(with route: String, and userName: String) {
        inputTextView.addTaggedUser(with: userName, route: route)
        mentionStopped()
    }
    
    public func updateHeight(with height: CGFloat) {
        taggingViewHeightConstraint?.constant = height
    }
}

// MARK: LMFeedPostCommentProtocol
extension LMFeedCommentBottomsheet: LMFeedPostCommentProtocol {
    public func didTapURL(url: URL) {
        openURL(with: url)
    }
    
    public func didTapUserName(for uuid: String) {
        showError(with: "Tapped User with uuid: \(uuid)", isPopVC: false)
    }
    
    public func didTapCommentMenuButton(for commentId: String) {
        viewModel.showMenu(for: commentId)
    }
    
    public func didTapLikeButton(for commentId: String, indexPath: IndexPath) {
        changeCommentLike(for: indexPath)
        viewModel.likeComment(for: commentId, indexPath: indexPath)
    }
    
    public func didTapLikeCountButton(for commentId: String) {
        viewModel.allowCommentLikeView(for: commentId)
        do {
            let viewcontroller = try LMFeedLikeViewModel.createModule(postID: postID, commentID: commentId)
            navigationController?.pushViewController(viewcontroller, animated: true)
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    public func didTapReplyButton(for commentId: String) {
        guard isCommentingEnabled else { return }
        viewModel.replyToComment(having: commentId)
    }
    
    public func didTapReplyCountButton(for commentId: String) {
        viewModel.getCommentReplies(commentId: commentId, isClose: true)
    }
    
    private func changeCommentLike(for indexPath: IndexPath) {
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
} 
