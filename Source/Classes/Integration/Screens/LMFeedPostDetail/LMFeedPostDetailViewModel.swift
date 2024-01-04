//
//  LMFeedPostDetailViewModel.swift
//  likeminds-feed-iOS
//
//  Created by Devansh Mohata on 03/01/24.
//

import LikeMindsFeed

public protocol LMFeedPostDetailViewModelProtocol: LMBaseViewControllerProtocol {
    func showPostDetails(with post: LMFeedPostTableCellProtocol, comments: [LMFeedPostCommentCellProtocol], indexPath: IndexPath?)
    
    func changePostLike()
    func changePostSave()
    
    func changeCommentLike(for indexPath: IndexPath)
}

public class LMFeedPostDetailViewModel {
    public let postID: String
    public var currentPage: Int
    public var pageSize: Int
    public var isFetchingData: Bool
    public var isDataAvailable: Bool
    public var postDetail: LMFeedPostDataModel?
    public weak var delegate: LMFeedPostDetailViewModelProtocol?
    
    init(postID: String, delegate: LMFeedPostDetailViewModelProtocol?) {
        self.postID = postID
        self.currentPage = 1
        self.pageSize = 10
        self.isFetchingData = false
        self.isDataAvailable = true
        self.delegate = delegate
    }
    
    public static func createModule(for postID: String) -> LMFeedPostDetailViewController {
        let viewController = Components.shared.postDetailScreen.init()
        let viewModel: LMFeedPostDetailViewModel = .init(postID: postID, delegate: viewController)
        
        viewController.viewModel = viewModel
        return viewController
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
        
        let request = GetPostRequest.builder()
            .postId(postID)
            .page(currentPage)
            .pageSize(pageSize)
            .build()
        
        LMFeedClient.shared.getPost(request) { [weak self] response in
            guard let self else { return }
            self.isFetchingData = false
            guard response.success,
                  let post = response.data?.post,
                  let users = response.data?.users else {
                // TODO: Show Error Alert
                return
            }
            
            
            let allTopics = response.data?.topics?.compactMap({ $0.value }) ?? []
            
            if currentPage != 1 {
                let newComments: [LMFeedCommentDataModel] = post.replies?.enumerated().compactMap { index, comment in
                    guard let user = users[comment.uuid ?? ""] else { return nil }
                    return .init(comment: comment, user: user, index: .init(row: NSNotFound, section: index))
                } ?? []
                
                var commentList = postDetail?.comments ?? []
                commentList.append(contentsOf: newComments)
                
                postDetail?.comments = commentList
                self.isDataAvailable = !newComments.isEmpty
            } else {
                self.postDetail = .init(post: post, users: users, allTopics: allTopics)
            }
            
            self.currentPage += 1
            self.convertToViewData()
        }
    }
    
    func convertToViewData(for indexPath: IndexPath? = nil) {
        guard let postDetail else { return }
        let convertedPostDetail = LMFeedConvertToFeedPost.convertToViewModel(for: postDetail)
        
        var convertedComments: [LMFeedPostCommentCellProtocol] = []
        
        if !postDetail.comments.isEmpty {
            let totalCommentCellData: LMFeedPostDetailTotalCommentCell.ViewModel = .init(totalComments: postDetail.commentCount)
            convertedComments.append(totalCommentCellData)
            
            postDetail.comments.enumerated().forEach { index, comment in
                convertedComments.append(convertToCommentModel(from: comment))
                
                if !comment.replies.isEmpty,
                   comment.totalRepliesCount > comment.replies.count {
                    convertedComments.append(convertToShowMoreReplies(from: comment))
                }
            }
        }
        
        delegate?.showPostDetails(with: convertedPostDetail, comments: convertedComments, indexPath: indexPath)
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
        .init(parentCommentId: comment.commentID, commentCount: comment.replies.count, totalComments: comment.totalRepliesCount)
    }
}


// MARK: Menu Actions
public extension LMFeedPostDetailViewModel {
    func showMenu(for commentID: String) {
        guard let comment = findComment(for: commentID, from: postDetail?.comments ?? []),
        !comment.menuItems.isEmpty else { return }
        
        let alert = UIAlertController(title: .none, message: .none, preferredStyle: .actionSheet)
        
        comment.menuItems.forEach { menu in
            switch menu.id {
            case .deleteComment:
                alert.addAction(.init(title: "Delete Comment", style: .destructive) { _ in
                    print("Delete Action")
                })
            case .reportComment:
                alert.addAction(.init(title: "Report Comment", style: .destructive) { _ in
                    print("Report Action")
                })
            case .editComment:
                alert.addAction(.init(title: "Edit Comment", style: .destructive) { _ in
                    print("Edit Action")
                })
            default:
                break
            }
        }
        
        alert.addAction(.init(title: "Cancel", style: .cancel))
        
        delegate?.presentAlert(with: alert, animated: true)
    }
    
    func findComment(for commentID: String, from comments: [LMFeedCommentDataModel]) -> LMFeedCommentDataModel? {
        for comment in comments {
            if comment.commentID == commentID {
                return comment
            }
            
            if let resultComment = findComment(for: commentID, from: comment.replies) {
                return resultComment
            }
        }
        
        return nil
    }
}


// MARK: Like Comment
public extension LMFeedPostDetailViewModel {
    func likeComment(for commentID: String, indexPath: IndexPath) {
        guard let postID = postDetail?.postId else { return }
        let request = LikeCommentRequest
            .builder()
            .postId(postID)
            .commentId(commentID)
            .build()
        
        LMFeedClient.shared.likeComment(request) { [weak self] response in
            guard let self else { return }
            
            if response.success,
               var comment = findComment(for: commentID, from: postDetail?.comments ?? []) {
                let isLiked = comment.isLiked
                comment.isLiked = !isLiked
                comment.likeCount += !isLiked ? 1 : -1
                
                let index = comment.index
                
                if index.row == NSNotFound {
                    postDetail?.comments[index.section] = comment
                    dump(postDetail?.comments[index.section])
                } else {
                    postDetail?.comments[index.section].replies[index.row] = comment
                    dump(postDetail?.comments[index.section].replies[index.row])
                }
            } else {
                delegate?.changeCommentLike(for: indexPath)
            }
        }
    }
}


// MARK: Post Shenanigans
public extension LMFeedPostDetailViewModel {
    // MARK: Like Post
    func likePost(for postId: String) {
        let request = LikePostRequest.builder()
            .postId(postId)
            .build()
        
        LMFeedClient.shared.likePost(request) { [weak self] response in
            guard let self else { return }
            
            if response.success {
                let isLiked = postDetail?.isLiked ?? true
                postDetail?.isLiked = !isLiked
                postDetail?.likeCount = !isLiked ? 1 : -1
            } else if !response.success {
                delegate?.changePostLike()
            }
        }
    }
    
    // MARK: Save Post
    func savePost(for postId: String) {
        let request = SavePostRequest.builder()
            .postId(postId)
            .build()
        
        LMFeedClient.shared.savePost(request) { [weak self] response in
            guard let self else { return }
            
            if response.success {
                postDetail?.isSaved.toggle()
            } else {
                delegate?.changePostSave()
            }
        }
    }
}

