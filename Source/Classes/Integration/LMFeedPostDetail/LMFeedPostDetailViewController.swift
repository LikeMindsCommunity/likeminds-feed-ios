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
        return table
    }()
    
    open private(set) lazy var inputTextView: LMTextView = {
        let textView = LMTextView().translatesAutoresizingMaskIntoConstraints()
        return textView
    }()

    open var inputTextViewHeightConstraint: NSLayoutConstraint?
    open var inputTextViewBottomConstraint: NSLayoutConstraint?
    
    
    // MARK: Data Variables
    var cellsData: [LMFeedPostTableCellProtocol] = []
    
    // MARK: setupViews
    open override func setupViews() {
        super.setupViews()
        
        view.addSubview(tableView)
        view.addSubview(inputTextView)
    }
    
    
    // MARK: setupLayouts
    open override func setupLayouts() {
        super.setupLayouts()
        
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            
            inputTextView.topAnchor.constraint(equalTo: tableView.bottomAnchor),
            inputTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            inputTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
        
        inputTextViewBottomConstraint = NSLayoutConstraint(item: inputTextView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0)
        inputTextViewBottomConstraint?.isActive = true
        
        inputTextViewHeightConstraint = NSLayoutConstraint(item: inputTextView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 50)
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
    }
    
    
    // MARK: setupAppearance
    open override func setupAppearance() {
        super.setupAppearance()
        
        tableView.backgroundColor = .clear
        view.backgroundColor = Appearance.shared.colors.backgroundColor
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        sampleDataGenerator()
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
            return comment.replies.count + (comment.loadMoreComments != nil ? 1 : 0)
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
                comment: "This is a Comment, I'm making a SDK, god help me!",
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
