//
//  LMFeedPostListViewModel.swift
//  likeminds-feed-iOS
//
//  Created by Devansh Mohata on 02/01/24.
//

import lm_feedUI_iOS
import LikeMindsFeed

// MARK: LMUniversalFeedViewModelProtocol
public protocol LMFeedPostListViewModelProtocol: AnyObject {
    func loadPosts(with data: [LMFeedPostTableCellProtocol], for index: IndexPath?)
    func undoLikeAction(for postID: String)
    func undoSaveAction(for postID: String)
    func showHideFooterLoader(isShow: Bool)
    func showActivityLoader()
}

public class LMFeedPostListViewModel {
    public var currentPage: Int = 1
    public var pageSize: Int = 10
    public var selectedTopics: [String] = []
    public var isLastPostReached: Bool = false
    public var isFetchingFeed: Bool = false
    public var postList: [LMFeedPostDataModel] = []
    
    public weak var delegate: LMFeedPostListViewModelProtocol?
    
    init(delegate: LMFeedPostListViewModelProtocol? = nil) {
        self.currentPage = 1
        self.pageSize = 10
        self.selectedTopics = []
        self.isLastPostReached = false
        self.isFetchingFeed = false
        self.postList = []
        self.delegate = delegate
    }
    
    public static func createModule(with delegate: LMFeedPostListVCFromProtocol) -> LMFeedPostListViewController {
        let viewController = Components.shared.feedListViewController.init()
        let viewModel: LMFeedPostListViewModel = .init(delegate: viewController)
        
        viewController.viewModel = viewModel
        viewController.delegate = delegate
        return viewController
    }
}

// MARK: Get Feed 
public extension LMFeedPostListViewModel {
    func updateTopics(with selectedTopics: [String]) {
        self.selectedTopics = selectedTopics
        getFeed(fetchInitialPage: true)
    }
    
    func getFeed(fetchInitialPage: Bool = false) {
        if fetchInitialPage {
            isLastPostReached = false
            isFetchingFeed = false
            currentPage = 1
            postList.removeAll()
            delegate?.showActivityLoader()
        } else {
            delegate?.showHideFooterLoader(isShow: true)
        }
        
        guard !isLastPostReached,
              !isFetchingFeed else { return }
        
        isFetchingFeed = true
        
        var requestFeed = GetFeedRequest.builder()
            .page(currentPage)
            .pageSize(pageSize)
        
        if !selectedTopics.isEmpty {
            requestFeed = requestFeed
                .topics(selectedTopics)
                .build()
        }
        
        LMFeedClient.shared.getFeed(requestFeed) { [weak self] result in
            // Getting `self` or it is of no use
            guard let self else { return }
            
            self.isFetchingFeed = false
            // Checking if data was fetched successfully or not
            guard result.success else {
                // TODO: Error Logic
                return
            }
            
            // Extracting the posts or else there is no point in continuing if no data!
            guard let posts = result.data?.posts,
                  let users = result.data?.users else { return }
            
            self.isLastPostReached = posts.isEmpty
            self.currentPage += 1
            
            if !posts.isEmpty {
                let topics: [TopicFeedResponse.TopicResponse] = result.data?.topics?.compactMap {
                    $0.value
                } ?? []
                
                let convertedData: [LMFeedPostDataModel] = posts.compactMap { post in
                    return .init(post: post, users: users, allTopics: topics)
                }
                
                self.postList.append(contentsOf: convertedData)
                self.convertToViewData()
            }
        }
    }
    
    func convertToViewData(for index: IndexPath? = nil) {
        var convertedViewData: [LMFeedPostTableCellProtocol] = []
        
        postList.forEach { post in
            convertedViewData.append(LMFeedConvertToFeedPost.convertToViewModel(for: post))
        }
        
        delegate?.loadPosts(with: convertedViewData, for: index)
    }
}


// MARK: Like Post
public extension LMFeedPostListViewModel {
    func likePost(for postId: String) {
        let request = LikePostRequest.builder()
            .postId(postId)
            .build()
        
        LMFeedClient.shared.likePost(request) { [weak self] response in
            guard let self else { return }
            
            if response.success,
               let index = postList.firstIndex(where: { $0.postId == postId }) {
                var feed = postList[index]
                feed.isLiked.toggle()
                feed.likeCount = feed.isLiked ? 1 : -1
                postList[index] = feed
            } else if !response.success {
                delegate?.undoLikeAction(for: postId)
            }
        }
    }
}

// MARK: Save Post
public extension LMFeedPostListViewModel {
    func savePost(for postId: String) {
        let request = SavePostRequest.builder()
            .postId(postId)
            .build()
        
        LMFeedClient.shared.savePost(request) { [weak self] response in
            guard let self else { return }
            
            if response.success,
               let index = postList.firstIndex(where: { $0.postId == postId }){
                var feed = postList[index]
                feed.isSaved.toggle()
                postList[index] = feed
            } else {
                delegate?.undoSaveAction(for: postId)
            }
        }
    }
}


// MARK: Update Post Content
public extension LMFeedPostListViewModel {
    func updatePostData(for post: LMFeedPostDataModel) {
        guard let index = postList.firstIndex(where: { $0.postId == post.postId }) else { return }
        postList[index] = post
        convertToViewData(for: IndexPath(row: index, section: 0))
    }
}
