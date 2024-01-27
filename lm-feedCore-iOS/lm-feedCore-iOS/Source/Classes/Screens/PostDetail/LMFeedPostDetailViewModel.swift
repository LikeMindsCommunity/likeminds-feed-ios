//
//  LMFeedPostDetailViewModel.swift
//  likeminds-feed-iOS
//
//  Created by Devansh Mohata on 03/01/24.
//

import lm_feedUI_iOS
import LikeMindsFeed

public protocol LMFeedPostDetailViewModelProtocol: LMBaseViewControllerProtocol {
    func showPostDetails(with post: LMFeedPostTableCellProtocol, comments: [LMFeedPostCommentCellProtocol], indexPath: IndexPath?, openCommentSection: Bool)
    
    func changePostLike()
    func changePostSave()
    
    func changeCommentLike(for indexPath: IndexPath)
    func replyToComment(userName: String)
    
    func showNoPostError(with message: String, isPop: Bool)
    func updateCommentStatus(isEnabled: Bool)
    
    func navigateToEditPost(for postID: String)
}

final public class LMFeedPostDetailViewModel {
    public let postID: String
    public var currentPage: Int
    public var pageSize: Int
    public var isFetchingData: Bool
    public var isDataAvailable: Bool
    public var postDetail: LMFeedPostDataModel?
    public var commentList: [LMFeedCommentDataModel]
    public var replyToComment:  LMFeedCommentDataModel?
    public var openCommentSection: Bool
    public weak var delegate: LMFeedPostDetailViewModelProtocol?
    
    public init(postID: String, delegate: LMFeedPostDetailViewModelProtocol?, openCommentSection: Bool = false) {
        self.postID = postID
        self.commentList = []
        self.currentPage = 1
        self.pageSize = 10
        self.isFetchingData = false
        self.isDataAvailable = true
        self.openCommentSection = openCommentSection
        self.delegate = delegate
    }
    
    public static func createModule(
        for postID: String,
        openCommentSection: Bool = false
    ) -> LMFeedPostDetailViewController? {
        guard LMFeedMain.isInitialized else { return nil }
        let viewController = Components.shared.postDetailScreen.init()
        let viewModel: LMFeedPostDetailViewModel = .init(postID: postID, delegate: viewController, openCommentSection: openCommentSection)
        
        viewController.viewModel = viewModel
        return viewController
    }
    
    func findCommentIndex(for commentID: String, from comments: [LMFeedCommentDataModel]) -> (comment: LMFeedCommentDataModel, index: IndexPath)? {
        for (idx, comment) in comments.enumerated() {
            if comment.commentID == commentID {
                return (comment, IndexPath(row: NSNotFound, section: idx))
            }
            
            for(innerIdx, innerComment) in comment.replies.enumerated() {
                return (innerComment, IndexPath(row: innerIdx, section: idx))
            }
        }
        
        return nil
    }
    
    func getMemberState() {
        LMFeedClient.shared.getMemberState() { [weak self] result in
            guard let self else { return }
            
            if result.success,
               let memberState = result.data {
                LocalPreferences.memberState = memberState
            }
            
            delegate?.updateCommentStatus(isEnabled: LocalPreferences.memberState?.memberRights?.contains(where: { $0.state == .commentOrReplyOnPost }) ?? false)
        }
    }
    
    func allowPostLikeView() -> Bool {
        postDetail?.likeCount ?? 0 > 0
    }
    
    func allowCommentLikeView(for commentId: String) -> Bool {
        if let comment = findCommentIndex(for: commentId, from: commentList) {
            return comment.comment.likeCount > 0
        }
        return false
    }
    
    func notifyObjectChange() {
        guard let postDetail else { return }
        NotificationCenter.default.post(name: .LMPostUpdate, object: postDetail)
    }
    
    func updatePostData(with data: LMFeedPostDataModel) {
        postDetail = data
        convertToViewData()
    }
}

// MARK: Get Post Details
public extension LMFeedPostDetailViewModel {
    func getPost(isInitialFetch: Bool) {
        if isInitialFetch {
            currentPage = 1
            isFetchingData = false
            isDataAvailable = true
        }
        
        guard !isFetchingData,
              isDataAvailable else { return }
        
        self.isFetchingData = true
        
        LMFeedPostOperation.shared.getPost(for: postID, currentPage: currentPage, pageSize: pageSize) { [weak self] response in
            guard let self else { return }
            self.isFetchingData = false
            guard response.success,
                  let post = response.data?.post,
                  let users = response.data?.users else {
                delegate?.showNoPostError(with: response.errorMessage ?? "Something Went Wrong", isPop: postDetail == nil)
                return
            }
            
            let allTopics = response.data?.topics?.compactMap({ $0.value }) ?? []
            
            if currentPage == 1 {
                commentList.removeAll(keepingCapacity: true)
            }
            
            self.postDetail = .init(post: post, users: users, allTopics: allTopics)
            
            let newComments: [LMFeedCommentDataModel] = post.replies?.enumerated().compactMap { index, comment in
                guard let user = users[comment.uuid ?? ""] else { return nil }
                return .init(comment: comment, user: user)
            } ?? []
            
            commentList.append(contentsOf: newComments)
            isDataAvailable = !newComments.isEmpty
            
            self.currentPage += 1
            self.convertToViewData()
        }
    }
    
    func convertToViewData(for indexPath: IndexPath? = nil) {
        guard let postDetail else { return }
        let convertedPostDetail = LMFeedConvertToFeedPost.convertToViewModel(for: postDetail)
        
        var convertedComments: [LMFeedPostCommentCellProtocol] = []
        
        if !commentList.isEmpty {
            let totalCommentCellData: LMFeedPostDetailTotalCommentCell.ViewModel = .init(totalComments: postDetail.commentCount)
            convertedComments.append(totalCommentCellData)
            
            commentList.enumerated().forEach { index, comment in
                convertedComments.append(convertToCommentModel(from: comment))
                
                if !comment.replies.isEmpty,
                   comment.totalRepliesCount > comment.replies.count {
                    convertedComments.append(convertToShowMoreReplies(from: comment))
                }
            }
        }
        
        delegate?.showPostDetails(with: convertedPostDetail, comments: convertedComments, indexPath: indexPath, openCommentSection: openCommentSection)
        openCommentSection = false
    }
    
    func convertToCommentModel(from comment: LMFeedCommentDataModel) -> LMFeedPostDetailCommentCellViewModel {
        var replies: [LMFeedPostDetailCommentCellViewModel] = []
        
        comment.replies.forEach { reply in
            replies.append(convertToCommentModel(from: reply))
        }
        
        return .init(
            author: comment.userDetail,
            commentId: comment.commentID,
            tempCommentId: comment.temporaryCommentID,
            comment: comment.commentText,
            commentTime: comment.createdAtFormatted,
            likeCount: comment.likeCount,
            totalReplyCount: comment.totalRepliesCount,
            replies: replies
        )
    }
    
    func convertToShowMoreReplies(from comment: LMFeedCommentDataModel) -> LMFeedPostMoreRepliesCell.ViewModel {
        .init(parentCommentId: comment.commentID ?? "", commentCount: comment.replies.count, totalComments: comment.totalRepliesCount)
    }
}


// MARK: Comment Shenanigans
public extension LMFeedPostDetailViewModel {
    func likeComment(for commentID: String, indexPath: IndexPath) {
        guard let postID = postDetail?.postId else { return }
        let request = LikeCommentRequest
            .builder()
            .postId(postID)
            .commentId(commentID)
            .build()
        
        LMFeedPostOperation.shared.likeComment(for: postID, commentID: commentID) { [weak self] response in
            guard let self else { return }
            
            if response,
               let commData = findCommentIndex(for: commentID, from: commentList) {
                var comment = commData.comment
                let commentIndex = commData.index
                
                let isLiked = comment.isLiked
                comment.isLiked = !isLiked
                comment.likeCount += !isLiked ? 1 : -1
                
                
                if commentIndex.row == NSNotFound {
                    commentList[commentIndex.section] = comment
                } else {
                    commentList[commentIndex.section].replies[commentIndex.row] = comment
                }
            } else {
                delegate?.changeCommentLike(for: indexPath)
            }
        }
    }
    
    func getCommentReplies(commentId: String, isClose: Bool) {
        if let index = commentList.firstIndex(where: { $0.commentID == commentId }),
           isClose,
           !commentList[index].replies.isEmpty {
            commentList[index].replies.removeAll(keepingCapacity: true)
            convertToViewData()
            return
        }
        
        guard !isFetchingData,
              let postID = postDetail?.postId,
              let (parentComment, parentIndex) = findCommentIndex(for: commentId, from: commentList) else { return }
        self.isFetchingData = true
        
        let replyCurrentPage = (parentComment.replies.count / 5) + 1
        
        LMFeedPostOperation.shared.getCommentReplies(for: postID, commentID: commentId, currentPage: replyCurrentPage) { [weak self] response in
            guard let self else { return }
            isFetchingData = false
            
            guard let commentArray = response.data?.comment,
                  let users =  response.data?.users else {
                return
            }
            
            let newComments: [LMFeedCommentDataModel] = commentArray.replies?.enumerated().compactMap { index, comment in
                guard let user = users[comment.uuid ?? ""] else { return nil }
                return .init(comment: comment, user: user)
            } ?? []
            
            commentList[parentIndex.section].replies.append(contentsOf: newComments)
            self.convertToViewData()
        }
    }
    
    
    // MARK: Show Comment Menu
    func showMenu(for commentID: String) {
        guard let (comment, _) = findCommentIndex(for: commentID, from: commentList),
              !comment.menuItems.isEmpty else { return }
        
        let alert = UIAlertController(title: .none, message: .none, preferredStyle: .actionSheet)
        
        comment.menuItems.forEach { menu in
            switch menu.id {
            case .deleteComment:
                alert.addAction(.init(title: menu.name, style: .destructive) { _ in
                    print("Delete Action")
                })
            case .reportComment:
                alert.addAction(.init(title: menu.name, style: .destructive) { _ in
                    print("Report Action")
                })
            case .editComment:
                alert.addAction(.init(title: menu.name, style: .default) { _ in
                    print("Edit Action")
                })
            default:
                break
            }
        }
        
        alert.addAction(.init(title: "Cancel", style: .cancel))
        
        delegate?.presentAlert(with: alert, animated: true)
    }
    
    // MARK: Click on Reply Button
    func replyToComment(having commentID: String?) {
        guard let commentID,
              let (comment, _) = findCommentIndex(for: commentID, from: commentList) else {
            replyToComment = nil
            return
        }
        
        replyToComment = comment
        delegate?.replyToComment(userName: comment.userDetail.userName)
    }
    
    // MARK: Send Comment Button
    func postReply(with commentString: String) {
        guard let userInfo = LocalPreferences.userObj,
              let userName = userInfo.name,
              let uuid = userInfo.uuid else { return }
        
        let userObj = LMFeedUserDataModel(userName: userName, userUUID: uuid, userProfileImage: userInfo.imageUrl, customTitle: userInfo.customTitle)
        let time = Int(Date().millisecondsSince1970.rounded())
        
        let localComment: LMFeedCommentDataModel = .init(
            commentID: nil,
            userDetail: userObj,
            temporaryCommentID: "\(time)",
            createdAt: time,
            isLiked: false,
            likeCount: 0,
            isEdited: false,
            commentText: commentString,
            menuItems: [],
            totalRepliesCount: 0
        )
        
        if let replyToComment,
           let commentID = replyToComment.commentID,
           let (_, commentIndex) = findCommentIndex(for: commentString, from: commentList) {
               commentList[commentIndex.section].replies.insert(localComment, at: 0)
               postReplyOnComment(with: commentString, commentID: commentID, localComment: localComment)
           } else {
               commentList.insert(localComment, at: 0)
               postReplyOnPost(with: commentString, localComment: localComment)
           }
        
        replyToComment = nil
        convertToViewData()
    }
    
    private func postReplyOnPost(with comment: String, localComment: LMFeedCommentDataModel) {
        LMFeedPostOperation.shared.postReplyOnPost(for: postID, with: comment, createdAt: localComment.createdAt) { [weak self] response in
            guard let self,
                  response.success,
                  let comment = response.data?.comment,
                  let user = response.data?.users?[comment.uuid ?? ""],
                  let newComment = LMFeedCommentDataModel.init(comment: comment, user: user) else { return }
            
            if let idx = commentList.firstIndex(where: { $0.temporaryCommentID == localComment.temporaryCommentID }) {
                commentList[idx] = newComment
                convertToViewData(for: .init(row: NSNotFound, section: idx))
                postDetail?.commentCount += 1
                notifyObjectChange()
            }
        }
    }
    
    private func postReplyOnComment(with comment: String, commentID: String, localComment: LMFeedCommentDataModel) {
        LMFeedPostOperation.shared.postReplyOnComment(for: postID, with: comment, commentID: commentID, createdAt: localComment.createdAt) { [weak self] response in
            guard let self,
                  response.success,
                  let comment = response.data?.comment,
                  let user = response.data?.users?[comment.uuid ?? ""],
                  let newComment = LMFeedCommentDataModel.init(comment: comment, user: user) else { return }
            
            if let idx = commentList.firstIndex(where: { $0.commentID == commentID }),
               let tempIdx = commentList[idx].replies.firstIndex(where: { $0.temporaryCommentID == localComment.temporaryCommentID }) {
                commentList[idx].replies[tempIdx] = newComment
                convertToViewData(for: .init(row: tempIdx, section: idx))
            }
        }
    }
}


// MARK: Post Shenanigans
public extension LMFeedPostDetailViewModel {
    // MARK: Like Post
    func likePost(for postId: String) {
        LMFeedPostOperation.shared.likePost(for: postId) { [weak self] response in
            guard let self else { return }
            
            if response {
                let newState = !(postDetail?.isLiked ?? true)
                postDetail?.isLiked = newState
                postDetail?.likeCount += newState ? 1 : -1
                notifyObjectChange()
            } else {
                delegate?.changePostLike()
            }
        }
    }
    
    // MARK: Save Post
    func savePost(for postId: String) {
        LMFeedPostOperation.shared.savePost(for: postId) { [weak self] response in
            guard let self else { return }
            
            if response {
                postDetail?.isSaved.toggle()
                notifyObjectChange()
            } else {
                delegate?.changePostSave()
            }
        }
    }
    
    
    // MARK: Un/Pin Post
    func pinUnpinPost(postId: String) {
        LMFeedPostOperation.shared.pinUnpinPost(postId: postId) { [weak self] response in
            guard let self else { return }
            if response {
                postDetail?.isPinned.toggle()
                updatePinMenu()
                convertToViewData(for: .init(row: NSNotFound, section: 0))
                notifyObjectChange()
            }
        }
    }
    
    func updatePinMenu() {
        guard let index = postDetail?.postMenu.firstIndex(where: { $0.id == .pinPost || $0.id == .unpinPost }) else { return }
        if postDetail?.isPinned == true {
            postDetail?.postMenu[index] = .init(id: .unpinPost, name: "Unpin this Post")
        } else {
            postDetail?.postMenu[index] = .init(id: .pinPost, name: "Pin this Post")
        }
    }
    
    
    // MARK: Show Post Menu
    func showMenu(postID: String) {
        guard let postDetail else { return }
        
        let alert = UIAlertController(title: .none, message: .none, preferredStyle: .actionSheet)
        
        postDetail.postMenu.forEach { menu in
            switch menu.id {
            case .deletePost:
                alert.addAction(.init(title: menu.name, style: .destructive) { _ in
                    print("Delete Action")
                })
            case .pinPost:
                alert.addAction(.init(title: menu.name, style: .default) { [weak self] _ in
                    self?.pinUnpinPost(postId: postID)
                })
            case .unpinPost:
                alert.addAction(.init(title: menu.name, style: .default) { [weak self] _ in
                    self?.pinUnpinPost(postId: postID)
                })
            case .reportPost:
                alert.addAction(.init(title: menu.name, style: .destructive) { _ in
                    print("Report Action")
                })
            case .editPost:
                alert.addAction(.init(title: menu.name, style: .default) { [weak self] _ in
                    self?.delegate?.navigateToEditPost(for: postID)
                })
            default:
                break
            }
        }
        
        alert.addAction(.init(title: "Cancel", style: .cancel))
        
        delegate?.presentAlert(with: alert, animated: true)
    }
}

