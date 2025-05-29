import UIKit
import LikeMindsFeedUI

open class LMFeedCommentBottomsheet: LMFeedViewController, LMFeedBasePostDetailViewModelProtocol {
    public func showPostDetails(with post: LMFeedPostContentModel, comments: [LMFeedCommentContentModel], isInitialPage: Bool) {
        if isInitialPage {
            commentsData.removeAll(keepingCapacity: true)
        }
        commentsData.append(contentsOf: comments)
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
        // Not needed for comment bottomsheet
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
    private lazy var contentView: LMFeedView = {
        let view = LMFeedView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        return view
    }()
    
    private lazy var commentTableView: LMFeedTableView = {
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
    
    private lazy var containerView: LMFeedView = {
        let view = LMFeedView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = LMFeedAppearance.shared.colors.white
        return view
    }()
    
    private lazy var inputTextView: LMFeedTaggingTextView = {
        let textView = LMFeedTaggingTextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.isEditable = true
        textView.isScrollEnabled = false
        textView.backgroundColor = LMFeedAppearance.shared.colors.clear
        textView.textColor = LMFeedAppearance.shared.colors.textColor
        textView.contentMode = .center
        textView.font = LMFeedAppearance.shared.fonts.textFont1
        textView.placeHolderText = LMStringConstants.shared.writeComment
        return textView
    }()
    
    private lazy var sendButton: LMFeedButton = {
        let button = LMFeedButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(nil, for: .normal)
        button.setImage(LMFeedConstants.shared.images.planeIconFilled, for: .normal)
        button.tintColor = LMFeedAppearance.shared.colors.appTintColor
        button.isEnabled = false
        return button
    }()
    
    private lazy var stackView: LMFeedStackView = {
        let stack = LMFeedStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.alignment = .center
        stack.distribution = .fill
        stack.backgroundColor = LMFeedAppearance.shared.colors.clear
        return stack
    }()
    
    private lazy var replyView: LMFeedView = {
        let view = LMFeedView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var replyNameLabel: LMFeedLabel = {
        let label = LMFeedLabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Replying To XYZ"
        label.font = LMFeedAppearance.shared.fonts.textFont1
        label.textColor = LMFeedAppearance.shared.colors.gray3
        return label
    }()

    private lazy var removeReplyButton: LMFeedButton = {
        let button = LMFeedButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(nil, for: .normal)
        button.setImage(LMFeedConstants.shared.images.xmarkIcon, for: .normal)
        button.tintColor = LMFeedAppearance.shared.colors.gray3
        return button
    }()

    private lazy var replySepratorView: LMFeedView = {
        let view = LMFeedView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = LMFeedAppearance.shared.colors.sepratorColor
        return view
    }()
    
    // MARK: Data Variables
    private var postID: String
    private var commentsData: [LMFeedCommentContentModel] = []
    private var isCommentingEnabled: Bool = LocalPreferences.memberState?.memberRights?.contains(where: { $0.state == .commentOrReplyOnPost }) ?? false
    private var inputTextViewHeightConstraint: NSLayoutConstraint?
    private var textInputMaximumHeight: CGFloat = 100
    private var viewModel: LMFeedPostDetailViewModel
    
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
        setupViews()
        setupLayouts()
        setupActions()
        setupAppearance()
        viewModel.getPost(isInitialFetch: true)
    }
    
    private func setupTableView() {
        commentTableView.register(LMUIComponents.shared.replyView)
        commentTableView.registerHeaderFooter(LMUIComponents.shared.loadMoreReplies)
        commentTableView.registerHeaderFooter(LMUIComponents.shared.commentView)
    }
    
    // MARK: Setup Methods
    open override func setupViews() {
        super.setupViews()
        view.addSubview(contentView)
        contentView.addSubview(containerView)
        containerView.addSubview(commentTableView)
        containerView.addSubview(replySepratorView)
        containerView.addSubview(replyView)
        containerView.addSubview(stackView)
        
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
            
            commentTableView.topAnchor.constraint(equalTo: containerView.topAnchor),
            commentTableView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            commentTableView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            commentTableView.bottomAnchor.constraint(equalTo: replySepratorView.topAnchor),
            
            replySepratorView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            replySepratorView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            replySepratorView.bottomAnchor.constraint(equalTo: replyView.topAnchor),
            replySepratorView.heightAnchor.constraint(equalToConstant: 1),
            
            replyView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            replyView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            replyView.bottomAnchor.constraint(equalTo: stackView.topAnchor),
            
            replyNameLabel.topAnchor.constraint(equalTo: replyView.topAnchor, constant: 16),
            replyNameLabel.bottomAnchor.constraint(equalTo: replyView.bottomAnchor, constant: -16),
            replyNameLabel.leadingAnchor.constraint(equalTo: replyView.leadingAnchor, constant: 16),
            
            removeReplyButton.leadingAnchor.constraint(equalTo: replyNameLabel.trailingAnchor, constant: 16),
            removeReplyButton.trailingAnchor.constraint(equalTo: replyView.trailingAnchor, constant: -16),
            removeReplyButton.centerYAnchor.constraint(equalTo: replyNameLabel.centerYAnchor),
            removeReplyButton.widthAnchor.constraint(equalTo: removeReplyButton.heightAnchor),
            
            stackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            
            inputTextView.topAnchor.constraint(equalTo: stackView.topAnchor),
            inputTextView.bottomAnchor.constraint(equalTo: stackView.bottomAnchor),
            
            sendButton.widthAnchor.constraint(equalTo: sendButton.heightAnchor)
        ])
        
        inputTextViewHeightConstraint = inputTextView.heightAnchor.constraint(equalToConstant: 40)
        inputTextViewHeightConstraint?.isActive = true
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
        replyView.isHidden = true
    }
    
    // MARK: Action Methods
    @objc private func didTapReplyCrossButton() {
        replyView.isHidden = true
        viewModel.replyToComment(having: nil)
    }

    @objc private func didTapSendCommentButton() {
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
        if section == commentsData.count - 1 {
            viewModel.getPost(isInitialFetch: false)
        }
    }
}

// MARK: LMFeedTaggingTextViewProtocol
extension LMFeedCommentBottomsheet: LMFeedTaggingTextViewProtocol {
    public func mentionStarted(with text: String) {
        // TODO: Implement mention functionality
    }
    
    public func mentionStopped() {
        // TODO: Implement mention stop functionality
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
