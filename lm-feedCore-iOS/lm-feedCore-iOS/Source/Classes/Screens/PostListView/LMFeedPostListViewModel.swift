//
//  LMFeedPostListViewModel.swift
//  likeminds-feed-iOS
//
//  Created by Devansh Mohata on 02/01/24.
//

import lm_feedUI_iOS
import LikeMindsFeed

// MARK: LMUniversalFeedViewModelProtocol
public protocol LMFeedPostListViewModelProtocol: LMBaseViewControllerProtocol {
    func loadPosts(with data: [LMFeedPostTableCellProtocol], for index: IndexPath?)
    func undoLikeAction(for postID: String)
    func undoSaveAction(for postID: String)
    func showHideFooterLoader(isShow: Bool)
    func showActivityLoader()
    func navigateToEditScreen(for postID: String)
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
    
    public static func createModule(with delegate: LMFeedPostListVCFromProtocol) -> LMFeedPostListViewController? {
        guard LMFeedMain.isInitialized else { return nil }
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
        
        LMFeedPostOperation.shared.getFeed(currentPage: currentPage, pageSize: pageSize, selectedTopics: selectedTopics) { [weak self] response in
            guard let self else { return }
            
            isFetchingFeed = false
            
            guard response.success,
                  let posts = response.data?.posts,
                  let users = response.data?.users else {
                // TODO: Error
                return
            }
            
            self.isLastPostReached = posts.isEmpty
            self.currentPage += 1
            
            if !posts.isEmpty {
                let topics: [TopicFeedResponse.TopicResponse] = response.data?.topics?.compactMap {
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
        LMFeedPostOperation.shared.likePost(for: postId) { [weak self] response in
            guard let self,
                  let index = postList.firstIndex(where: { $0.postId == postId }) else { return }
            
            if response {
                var feed = postList[index]
                feed.isLiked.toggle()
                feed.likeCount += feed.isLiked ? 1 : -1
                postList[index] = feed
            } else {
                convertToViewData(for: IndexPath(row: index, section: 0))
            }
        }
    }
    
    func allowPostLikeView(for postId: String) -> Bool {
        guard let likeCount = postList.first(where: { $0.postId == postId })?.likeCount else { return false }
        return likeCount > 0
    }
}

// MARK: Save Post
public extension LMFeedPostListViewModel {
    func savePost(for postId: String) {
        LMFeedPostOperation.shared.savePost(for: postId) { [weak self] response in
            guard let self,
                  let index = postList.firstIndex(where: { $0.postId == postId }) else { return }
            
            if response {
                var feed = postList[index]
                feed.isSaved.toggle()
                postList[index] = feed
            } else {
                convertToViewData(for: IndexPath(row: index, section: 0))
            }
        }
    }
}


// MARK: Show Menu
public extension LMFeedPostListViewModel {
    func togglePostPin(for postID: String) {
        LMFeedPostOperation.shared.pinUnpinPost(postId: postID) { [weak self] response in
            guard let self,
                  let index = postList.firstIndex(where: { $0.postId == postID }) else { return }
            
            if response {
                var feed = postList[index]
                feed.isPinned.toggle()
                postList[index] = feed
                convertToViewData(for: IndexPath(row: index, section: 0))
            }
        }
    }
}

// MARK: Show Menu
public extension LMFeedPostListViewModel {
    func showMenu(for postID: String) {
        guard let post = postList.first(where: { $0.postId == postID }) else { return }
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        post.postMenu.forEach { menu in
            switch menu.id {
            case .deletePost:
                let action = UIAlertAction(title: menu.name, style: .destructive) { _ in
                    print(#function)
                }
                alert.addAction(action)
            case .pinPost,
                    .unpinPost:
                let action = UIAlertAction(title: menu.name, style: .default) { [weak self] _ in
                    self?.togglePostPin(for: postID)
                }
                alert.addAction(action)
            case .reportPost:
                let action = UIAlertAction(title: menu.name, style: .destructive) { _ in
                    print(#function)
                }
                alert.addAction(action)
            case .editPost:
                let action = UIAlertAction(title: menu.name, style: .default) { [weak self] _ in
                    self?.delegate?.navigateToEditScreen(for: postID)
                }
                alert.addAction(action)
            default:
                break
            }
        }
        
        alert.addAction(.init(title: "Cancel", style: .default))
        
        delegate?.presentAlert(with: alert, animated: true)
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
