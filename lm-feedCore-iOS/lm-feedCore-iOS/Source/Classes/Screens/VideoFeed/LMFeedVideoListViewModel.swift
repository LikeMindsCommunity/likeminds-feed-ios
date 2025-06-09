import Foundation
import LikeMindsFeedUI
import LikeMindsFeed

public protocol LMFeedVideoListViewModelProtocol: AnyObject {
    func updateVideoList(with posts: [LMFeedPostContentModel], isInitialPage: Bool)
    func showError(with message: String, isPopVC: Bool)
    func showActivityLoader()
    func showHideFooterLoader(isShow: Bool)
    func updatePostList(with post: [LMFeedPostContentModel], isInitialPage: Bool)
    func updatePost(with post: LMFeedPostContentModel, onlyHeader: Bool, onlyFooter: Bool)
    func removePost(with postID: String)
    func presentAlert(with alert: UIAlertController, animated: Bool)
    func navigateToReportScreen(for postID: String, creatorUUID: String)
    func navigateToDeleteScreen(for postID: String)
    func navigateToEditScreen(for postID: String)
}

open class LMFeedVideoListViewModel {
    public var currentPage: Int
    public var pageSize: Int
    public var selectedTopics: [String]
    public var isLastPostReached: Bool
    public var isFetchingFeed: Bool
    public var postList: [LMFeedPostDataModel]
    public var postIds: [String]
    
    public weak var delegate: LMFeedVideoListViewModelProtocol?
    
    init(delegate: LMFeedVideoListViewModelProtocol, postIds: [String] = []) {
        self.currentPage = 1
        self.pageSize = 20
        self.selectedTopics = []
        self.isLastPostReached = false
        self.isFetchingFeed = false
        self.postList = []
        self.postIds = postIds
        self.delegate = delegate
    }
    
    func getFeed(fetchInitialPage: Bool = false) {
        if fetchInitialPage {
            isLastPostReached = false
            isFetchingFeed = false
            currentPage = 1
            postList.removeAll(keepingCapacity: true)
        }
        
        guard !isLastPostReached,
              !isFetchingFeed else { return }
        
        if currentPage != 1 {
            delegate?.showHideFooterLoader(isShow: true)
        }
        
        isFetchingFeed = true
        
        LMFeedPostOperation.shared.getFeed(currentPage: currentPage, pageSize: pageSize, selectedTopics: selectedTopics, postIds: postIds) { [weak self] response in
            guard let self else { return }
            
            delegate?.showHideFooterLoader(isShow: false)
            
            guard response.success,
                  let posts = response.data?.posts,
                  let users = response.data?.users else {
                isFetchingFeed = false
                return
            }
            
            let topics: [TopicFeedResponse.TopicResponse] = response.data?.topics?.compactMap {
                $0.value
            } ?? []
            
            let widgets = response.data?.widgets ?? [:]
            
            let comments = response.data?.filteredComments ?? [:]
            
            let convertedData: [LMFeedPostDataModel] = posts.compactMap { post in
                guard let attachments = post.attachments,
                      !attachments.isEmpty,
                      attachments[0].attachmentType == .reel else {
                    return nil
                }
                return .init(post: post, users: users, allTopics: topics, widgets: widgets, filteredComments: comments)
            }
            
            
            self.updatePostList(with: convertedData)
        }
    }
    
    func updatePostList(with data: [LMFeedPostDataModel]) {
        guard !data.isEmpty else {
            isFetchingFeed = false
            return
        }
        
        postList.append(contentsOf: data)
        
        Task {
            let convertedData = await convertToViewData(from: data)
            await MainActor.run {
                self.isFetchingFeed = false
                
               
                // Check if current page is 1 and we have startFeedWithPostIds
                if currentPage == 1 && !postIds.isEmpty {
                    for (index, post) in convertedData.enumerated() {
                        if index < postIds.count && post.postID != postIds[index] {
                            delegate?.showError(with: "Post has been deleted", isPopVC: false)
                            break
                        }
                    }
                }
                
                delegate?.updatePostList(with: convertedData, isInitialPage: currentPage == 1)
                isLastPostReached = postList.isEmpty
                currentPage += 1
            }
        }
    }
    func convertToViewData(from data: [LMFeedPostDataModel]) async -> [LMFeedPostContentModel] {
        return await withCheckedContinuation { continuation in
            Task.detached(priority: .background) {
                let convertedViewData = data.map { post in
                    LMFeedConvertToFeedPost.convertToViewModel(for: post)
                }
                
                continuation.resume(returning: convertedViewData)
            }
        }
    }

    
    func likePost(for postId: String) {
        LMFeedPostOperation.shared.likePost(for: postId) { [weak self] response in
            guard let self,
                  let index = postList.firstIndex(where: { $0.postId == postId }) else { return }
            
            if response {
                var feed = postList[index]
                feed.isLiked.toggle()
                feed.likeCount += feed.isLiked ? 1 : -1
                postList[index] = feed
            } else {
                updatePost(for: postId, onlyFooter: true)
            }
        }
    }
    
    func updatePost(for postID: String, onlyHeader: Bool = false, onlyFooter: Bool = false) {
        guard let post = postList.first(where: { $0.postId == postID }) else { return }
        
        let convertedPost = LMFeedConvertToFeedPost.convertToViewModel(for: post)
        delegate?.updatePost(with: convertedPost, onlyHeader: onlyHeader, onlyFooter: onlyFooter)
    }
    
    public func savePost(for postID: String) {
        // Handle save action
    }
    
    public func showMenu(for postID: String) {
            guard let post = postList.first(where: { $0.postId == postID }) else { return }
            
            let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            
            post.postMenu.forEach { menu in
                switch menu.id {
                case .deletePost:
                    let action = UIAlertAction(title: menu.name, style: .destructive) { [weak self] _ in
                        self?.handleDeletePost(for: post)
                    }
                    alert.addAction(action)
                case .pinPost,
                        .unpinPost:
                    let action = UIAlertAction(title: menu.name, style: .default) { [weak self] _ in
                        self?.togglePostPin(for: postID)
                        
                        LMFeedCore.analytics?.trackEvent(for: post.isPinned ? .postUnpinned : .postPinned, eventProperties: [
                            "created_by_id": post.userDetails.userUUID,
                            "post_id": postID,
                            "post_type": post.getPostType()
                        ])
                    }
                    alert.addAction(action)
                case .reportPost:
                    let action = UIAlertAction(title: menu.name, style: .destructive) { [weak self] _ in
                        self?.delegate?.navigateToReportScreen(for: postID, creatorUUID: post.userDetails.userUUID)
                    }
                    alert.addAction(action)
                case .editPost:
                    let action = UIAlertAction(title: menu.name, style: .default) { [weak self] _ in
                        self?.delegate?.navigateToEditScreen(for: postID)
                        
                        LMFeedCore.analytics?.trackEvent(for: .postEdited, eventProperties: [
                            "post_id": postID,
                            "post_type": post.getPostType()
                        ])
                    }
                    alert.addAction(action)
                default:
                    break
                }
            }
            
        alert.addAction(.init(title: LMStringConstants.shared.cancelActionTitle , style: .default))
            
            delegate?.presentAlert(with: alert, animated: true)
        }
    
    func handleDeletePost(for post: LMFeedPostDataModel) {
        // Case of Self Deletion
        if post.userDetails.userUUID == LocalPreferences.userObj?.sdkClientInfo?.uuid {
            let alert = UIAlertController(title: "\(LMStringConstants.shared.deletePost)?", message: LMStringConstants.shared.deletePostMessage, preferredStyle: .alert)
            
            let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
                self?.deletePost(postID: post.postId, reason: nil)
            }
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
            
            alert.addAction(cancelAction)
            alert.addAction(deleteAction)
            
            delegate?.presentAlert(with: alert, animated: true)
            
            LMFeedCore.analytics?.trackEvent(for: .postDeleted, eventProperties: [
                "user_state": "member",
                "user_id": post.userDetails.userUUID,
                "post_id": post.postId,
                "post_type": post.getPostType()
            ])
        } else if LocalPreferences.memberState?.state == 1 {
            delegate?.navigateToDeleteScreen(for: post.postId)
            
            LMFeedCore.analytics?.trackEvent(for: .postDeleted, eventProperties: [
                "user_state": "CM",
                "user_id": post.userDetails.userUUID,
                "post_id": post.postId,
                "post_type": post.getPostType()
            ])
        }
    }
    func deletePost(postID: String, reason: String?) {
        LMFeedPostOperation.shared.deletePost(postId: postID, reason: reason) { [weak self] response in
            guard let self else { return }
            switch response {
            case .success():
                removePost(for: postID)
            case .failure(let error):
                delegate?.showError(with: error.localizedDescription, isPopVC: false)
            }
        }
    }
    
    func removePost(for postID: String) {
        postList.removeAll(where: { $0.postId == postID })
        delegate?.removePost(with: postID)
    }
    
    private func togglePostPin(for postID: String) {
        LMFeedPostOperation.shared.pinUnpinPost(postId: postID) { [weak self] response in
            guard let self,
                  let index = postList.firstIndex(where: { $0.postId == postID }) else { return }
            
            if response {
                var feed = postList[index]
                feed.isPinned.toggle()
                if let idx = feed.postMenu.firstIndex(where: { $0.id == .pinPost }) {
                    feed.postMenu[idx] = .init(id: .unpinPost, name: LMStringConstants.shared.unpinThisPost)
                } else if let idx = feed.postMenu.firstIndex(where: { $0.id == .unpinPost }) {
                    feed.postMenu[idx] = .init(id: .pinPost, name: LMStringConstants.shared.pinThisPost)
                }
                
                postList[index] = feed
                
                updatePost(for: postID, onlyHeader: true)
            }
        }
    }
    
    public func allowPostLikeView(for postID: String) -> Bool {
        return true
    }
    
    func updatePostData(for post: LMFeedPostDataModel) {
        guard let index = postList.firstIndex(where: { $0.postId == post.postId }) else { return }
        postList[index] = post
        updatePost(for: post.postId)
    }
} 
