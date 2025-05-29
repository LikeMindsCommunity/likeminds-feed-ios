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
}

open class LMFeedVideoListViewModel {
    public var currentPage: Int
    public var pageSize: Int
    public var selectedTopics: [String]
    public var isLastPostReached: Bool
    public var isFetchingFeed: Bool
    public var postList: [LMFeedPostDataModel]
    
    public weak var delegate: LMFeedVideoListViewModelProtocol?
    
    init(delegate: LMFeedVideoListViewModelProtocol) {
        self.currentPage = 1
        self.pageSize = 20
        self.selectedTopics = []
        self.isLastPostReached = false
        self.isFetchingFeed = false
        self.postList = []
        self.delegate = delegate
    }
    
    // Sample colors for demonstration
    public let pageColors: [UIColor] = [
        .systemRed,
        .systemBlue,
        .systemGreen,
        .systemYellow,
        .systemPurple,
        .systemOrange,
        .systemPink,
        .systemTeal
    ]
    
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
        
        LMFeedPostOperation.shared.getFeed(currentPage: currentPage, pageSize: pageSize, selectedTopics: selectedTopics) { [weak self] response in
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
        // Handle menu action
    }
    
    public func allowPostLikeView(for postID: String) -> Bool {
        return true
    }
} 
