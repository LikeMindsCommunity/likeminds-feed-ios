//
//  LMFeedPostListViewModel.swift
//  likeminds-feed-iOS
//
//  Created by Devansh Mohata on 02/01/24.
//

import LikeMindsFeed

// MARK: LMUniversalFeedViewModelProtocol
public protocol LMFeedPostListViewModelProtocol: AnyObject {
    func loadPosts(with data: [LMFeedPostTableCellProtocol])
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
    public var postList: [LMUniversalFeedDataModel] = []
    
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
                
                let convertedData: [LMUniversalFeedDataModel] = posts.compactMap { post in
                    guard let user = users[post.uuid ?? ""] else { return nil }
                    return .init(post: post, user: user, allTopics: topics)
                }
                
                self.postList.append(contentsOf: convertedData)
                self.convertToViewData()
            }
        }
    }
    
    func convertToViewData() {
        var convertedViewData: [LMFeedPostTableCellProtocol] = []
        
        postList.forEach { post in
            if let link = post.linkAttachment {
                convertedViewData.append(convertToLinkViewData(from: post, link: link))
            } else if !post.documentAttachment.isEmpty {
                convertedViewData.append(convertToDocumentCells(from: post))
            } else {
                convertedViewData.append(convertToImageVideoCells(from: post))
            }
        }
        
        delegate?.loadPosts(with: convertedViewData)
    }
    
    func generateTopicViewModel(from topics: [LMUniversalFeedDataModel.TopicModel]) -> LMFeedTopicView.ViewModel {
        let mappedTopics: [LMFeedTopicCollectionCellDataModel] = topics.map {
            .init(topic: $0.topic, topicID: $0.topicId)
        }
        
        return .init(topics: mappedTopics)
    }
    
    func convertToHeaderViewData(from data: LMUniversalFeedDataModel) -> LMFeedPostHeaderView.ViewModel {
        .init(
            profileImage: data.userImage,
            authorName: data.userName,
            authorTag: data.userCustomTitle,
            subtitle: "\(data.createTime)\(data.isEdited ? " • Edited" : "")",
            isPinned: data.isPinned,
            showMenu: !data.postMenu.isEmpty
        )
    }
    
    func convertToFooterViewData(from data: LMUniversalFeedDataModel) -> LMFeedPostFooterView.ViewModel {
        .init(likeCount: data.likeCount, commentCount: data.commentCount, isSaved: data.isLiked, isLiked: data.isSaved)
    }
    
    func convertToLinkViewData(from data: LMUniversalFeedDataModel, link: LMUniversalFeedDataModel.LinkAttachment) -> LMFeedPostLinkCell.ViewModel {
        .init(
            postID: data.postId,
            userUUID: data.userUUID,
            headerData: convertToHeaderViewData(from: data),
            postText: data.postContent,
            topics: generateTopicViewModel(from: data.topics),
            mediaData: .init(linkPreview: link.previewImage, title: link.title, description: link.description, url: link.url),
            footerData: convertToFooterViewData(from: data)
        )
    }
    
    func convertToDocumentCells(from data: LMUniversalFeedDataModel) -> LMFeedPostDocumentCell.ViewModel {
        func convertToDocument(from data: [LMUniversalFeedDataModel.DocumentAttachment]) -> [LMFeedPostDocumentCellView.ViewModel] {
            data.map { datum in
                    .init(title: datum.name, documentURL: datum.url, size: datum.size, pageCount: datum.pageCount, docType: datum.format)
            }
        }
        
        return .init(
            postID: data.postId,
            userUUID: data.userUUID,
            headerData: convertToHeaderViewData(from: data),
            topics: generateTopicViewModel(from: data.topics),
            postText: data.postContent,
            documents: convertToDocument(from: data.documentAttachment),
            footerData: convertToFooterViewData(from: data)
        )
    }
    
    func convertToImageVideoCells(from data: LMUniversalFeedDataModel) -> LMFeedPostMediaCell.ViewModel {
        func convertToMediaProtocol(from data: [LMUniversalFeedDataModel.ImageVideoAttachment]) -> [LMFeedMediaProtocol] {
            data.map { datum in
                if datum.isVideo {
                    return LMFeedPostVideoCollectionCell.ViewModel(videoURL: datum.url)
                } else {
                    return LMFeedPostImageCollectionCell.ViewModel(image: datum.url)
                }
            }
        }
        
        return .init(
            postID: data.postId,
            userUUID: data.userUUID,
            headerData: convertToHeaderViewData(from: data),
            postText: data.postContent,
            topics: generateTopicViewModel(from: data.topics),
            mediaData: convertToMediaProtocol(from: data.imageVideoAttachment),
            footerData: convertToFooterViewData(from: data)
        )
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
