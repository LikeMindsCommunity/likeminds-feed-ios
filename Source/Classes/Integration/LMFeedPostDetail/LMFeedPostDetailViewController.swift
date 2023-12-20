//
//  LMFeedPostDetailViewController.swift
//  LMFramework
//
//  Created by Devansh Mohata on 15/12/23.
//

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
        table.rowHeight = UITableView.automaticDimension
        table.estimatedRowHeight = 50
        table.estimatedSectionHeaderHeight = 1
        table.sectionFooterHeight = .zero
        table.sectionHeaderHeight = UITableView.automaticDimension
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
    var cellsData: [LMFeedPostTableCellProtocol] = []
    open private(set) var textInputMaximumHeight: CGFloat = 100
    
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
        tableView.register(Components.shared.postCell)
        tableView.register(Components.shared.linkCell)
        tableView.register(Components.shared.documentCell)
        tableView.register(Components.shared.commentCell)
        tableView.register(Components.shared.totalCommentCell)
        tableView.register(Components.shared.loadMoreReplies)
        tableView.registerHeaderFooter(Components.shared.commentHeaderView)
        
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
        
        sampleDataGenerator()
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
        cellsData.count
    }
    
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let comment = cellsData[section] as? LMFeedPostDetailCommentCellViewModel {
            return comment.replies.count
        }
        return 1
    }
    
    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(Components.shared.postCell),
           let data = cellsData[indexPath.section] as? LMFeedPostMediaCell.ViewModel {
            cell.configure(with: data, delegate: self)
            return cell
        } else if let cell = tableView.dequeueReusableCell(Components.shared.linkCell),
                  let data = cellsData[indexPath.section] as? LMFeedPostLinkCell.ViewModel {
            cell.configure(with: data, delegate: self)
            return cell
        } else if let cell = tableView.dequeueReusableCell(Components.shared.documentCell),
                  let data = cellsData[indexPath.section] as? LMFeedPostDocumentCell.ViewModel {
            cell.configure(for: indexPath, with: data, delegate: self)
            return cell
        } else if let cell = tableView.dequeueReusableCell(Components.shared.totalCommentCell),
                  let data = cellsData[indexPath.section] as? LMFeedPostDetailTotalCommentCell.ViewModel {
            cell.configure(with: data)
            return cell
        } else if let cell = tableView.dequeueReusableCell(Components.shared.commentCell),
                  let data = cellsData[indexPath.section] as? LMFeedPostDetailCommentCellViewModel {
            let comment = data.replies[indexPath.row]
            cell.configure(with: comment, delegate: self, isShowSeprator: (data.replies.count - 1) == indexPath.row)
            return cell
        } else if let cell = tableView.dequeueReusableCell(Components.shared.loadMoreReplies),
                  let tempData = cellsData[indexPath.section] as? LMFeedPostDetailCommentCellViewModel,
                  let data = tempData.loadMoreComments {
            cell.configure(with: data, delegate: self)
            return cell
        }
        
        return UITableViewCell()
    }
    
    open func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if let header = tableView.dequeueReusableHeaderFooterView(Components.shared.commentHeaderView),
           let data = cellsData[section] as? LMFeedPostDetailCommentCellViewModel {
            header.configure(with: data, delegate: self)
            return header
        }
        return nil
    }
    
    open func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return nil
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if type(of: scrollView) is UITableView.Type {
            view.endEditing(true)
            inputTextViewHeightConstraint?.constant = 40
        }
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
        if var data = cellsData[indexPath.section] as? LMFeedPostDocumentCell.ViewModel {
            data.isShowAllDocuments.toggle()
            cellsData[indexPath.section] = data
            tableView.reloadRows(at: [indexPath], with: .none)
        }
    }
}


// MARK: LMChatPostCommentProtocol
@objc
extension LMFeedPostDetailViewController: LMChatPostCommentProtocol {
    open func didTapUserName(for uuid: String) { }
    
    open func didTapMenuButton(for commentId: String) { }
    
    open func didTapLikeButton(for commentId: String) { }
    
    open func didTapLikeCountButton(for commentId: String) { }
    
    open func didTapReplyButton(for commentId: String) { }
    
    open func didTapReplyCountButton(for commentId: String) { }
}


// MARK: LMFeedTableCellToViewControllerProtocol
@objc
extension LMFeedPostDetailViewController: LMFeedTableCellToViewControllerProtocol {
    open func didTapProfilePicture(for uuid: String) { }
    
    open func didTapLikeTextButton(for postID: String) { }
    
    open func didTapCommentButton(for postID: String) { }
    
    open func didTapShareButton(for postID: String) { }
    
    open func didTapSaveButton(for postID: String) { }
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


extension LMFeedPostDetailViewController {
    func sampleDataGenerator() {
        docGenerator()
        generateTotalComment()
        generateCommentCell()
        tableView.reloadData()
    }
    
    func headerData() -> LMFeedPostHeaderView.ViewModel {
        .init(
            profileImage: "https://picsum.photos/200/300",
            authorName: "Devansh Mohata",
            authorTag: Bool.random() ? "Owner" : nil,
            subtitle: "3 Hours Ago",
            isPinned: Bool.random(),
            showMenu: Bool.random()
        )
    }
    
    func docGenerator() {
        func doccer(id: Int) -> LMFeedPostDocumentCellView.ViewModel {
            .init(
                documentID: id,
                title: "This is PDF \(id)",
                size: Double(id * id) * 10,
                pageCount: id,
                docType: "PDF"
            )
        }
        
        
        var docs: [LMFeedPostDocumentCellView.ViewModel] = []
        
        for j in 0...5 {
            docs.append(doccer(id: j))
        }
        
        let datum = LMFeedPostDocumentCell.ViewModel.init(
            headerData: headerData(),
            postText: "<<Thor|route://user_profile/thor123>> <<DB|route://user_profile/fgsdfgs>> fdsgkdskfbj <<DB|route://user_profile/fgsdfgs>> <<Feed Api key bot|route://user_profile/1d7fcd74-21ed-4e54-b5b4-792e2d2a1e2f>> This is a Post containing Documents www.google.com as #Attachments<<Thor|route://user_profile/thor123>> <<DB|route://user_profile/fgsdfgs>> fdsgkdskfbj <<DB|route://user_profile/fgsdfgs>> <<Feed Api key bot|route://user_profile/1d7fcd74-21ed-4e54-b5b4-792e2d2a1e2f>> This is a Post containing Documents www.google.com as #Attachments<<Thor|route://user_profile/thor123>> <<DB|route://user_profile/fgsdfgs>> fdsgkdskfbj <<DB|route://user_profile/fgsdfgs>> <<Feed Api key bot|route://user_profile/1d7fcd74-21ed-4e54-b5b4-792e2d2a1e2f>> This is a Post containing Documents www.google.com as #Attachments",
            documents: docs,
            footerData: .init(isSaved: Bool.random(), isLiked: Bool.random()))
        
        cellsData.append(datum)
    }
    
    func generateCommentCell() {
        var replies: [LMFeedPostDetailCommentCellViewModel] = []
        
        for _ in (0...2) {
            replies.append(generateCommentCellReply())
        }
        
        for _ in (0...3) {
            let data = LMFeedPostDetailCommentCellViewModel(
                author: .init(name: "Devansh", avatarURL: "www.o.com", uuid: "devansh_rocks"),
                postId: "POSTER",
                commentId: "COMMENTER",
                tempCommentId: nil,
                comment: "This is a Comment, I'm making a SDK, god help me!This is a Comment, I'm making a SDK, god help me!This is a Comment, I'm making a SDK, god help me!This is a Comment, I'm making a SDK, god help me!This is a Comment, I'm making a SDK, god help me!This is a Comment, I'm making a SDK, god help me!This is a Comment, I'm making a SDK, god help me!This is a Comment, I'm making a SDK, god help me!",
                commentTime: "Just Now",
                likeCount: 3,
                totalReplyCount: 20,
                replies: replies,
                isEdited: Bool.random()
            )
            
            cellsData.append(data)
        }
    }
    
    func generateCommentCellReply() -> LMFeedPostDetailCommentCellViewModel {
        LMFeedPostDetailCommentCellViewModel(
            author: .init(name: "Devansh", avatarURL: "www.o.com", uuid: "devansh_rocks"),
            postId: "POSTER",
            commentId: "COMMENTER",
            tempCommentId: nil,
            comment: "This is a Comment, I'm making a SDK, god help me!",
            commentTime: "Just Now",
            likeCount: 3,
            totalReplyCount: 0,
            replies: [],
            isEdited: Bool.random()
        )
    }
    
    func generateTotalComment() {
        let data: LMFeedPostDetailTotalCommentCell.ViewModel = .init(totalComments: 15)
        cellsData.append(data)
    }
}
