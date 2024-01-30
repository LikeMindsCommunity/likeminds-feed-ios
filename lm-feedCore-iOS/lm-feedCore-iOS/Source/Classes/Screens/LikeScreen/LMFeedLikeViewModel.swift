//
//  LMFeedLikeViewModel.swift
//  lm-feedCore-iOS
//
//  Created by Devansh Mohata on 21/01/24.
//

import lm_feedUI_iOS
import LikeMindsFeed

public protocol LMFeedLikeViewModelProtocol: LMBaseViewControllerProtocol {
    func reloadTableView(with data: [LMFeedLikeUserTableCell.ViewModel], totalCount: Int)
    func showHideTableLoader(isShow: Bool)
}

public final class LMFeedLikeViewModel {
    public var postID: String
    public var commentID: String?
    public var currentPage: Int
    public var pageSize: Int
    public var totalLikes: Int
    public var likesData: [LMFeedLikeDataModel]
    public var isFetching: Bool
    public var isLastPage: Bool
    public weak var delegate: LMFeedLikeViewModelProtocol?
    
    init(postID: String, commentID: String?, delegate: LMFeedLikeViewModelProtocol) {
        self.postID = postID
        self.commentID = commentID
        self.currentPage = 1
        self.pageSize = 20
        self.totalLikes = 0
        self.likesData = []
        self.isFetching = false
        self.isLastPage = false
        self.delegate = delegate
    }
    
    public static func createModule(postID: String, commentID: String? = nil) -> LMFeedLikeViewController {
        let viewcontroller = Components.shared.likeListScreen.init()
        let viewModel = LMFeedLikeViewModel(postID: postID, commentID: commentID, delegate: viewcontroller)
        
        viewcontroller.viewModel = viewModel
        return viewcontroller
    }
    
    func getLikes() {
        guard !isFetching,
              !isLastPage else { return }
        
        isFetching = true
        
        if currentPage == 1 {
            delegate?.showHideLoaderView(isShow: true)
        } else {
            delegate?.showHideTableLoader(isShow: true)
        }
        
        if let commentID {
            fetchCommentLikedUsers(postId: postID, commentId: commentID)
        } else {
            fetchPostLikedUsers(postId: postID)
        }
    }
    
    func fetchPostLikedUsers(postId: String) {
        let request = GetPostLikesRequest.builder()
            .postId(postId)
            .page(currentPage)
            .pageSize(pageSize)
            .build()
        
        LMFeedClient.shared.getPostLikes(request) { [weak self] response in
            guard let self else { return }
            isFetching = false
            
            if currentPage == 1 {
                delegate?.showHideLoaderView(isShow: false)
            } else {
                delegate?.showHideTableLoader(isShow: false)
            }
            
            if response.success,
            let likes = response.data?.likes,
            let users = response.data?.users {
                totalLikes = response.data?.totalCount ?? .zero
                
                let tempLikes: [LMFeedLikeDataModel] = likes.compactMap { like in
                    guard let user = users[like.uuid ?? ""],
                          let username = user.name,
                          let uuid = user.sdkClientInfo?.uuid else { return nil }
                    
                    return .init(username: username, uuid: uuid, customTitle: user.customTitle, userImage: user.imageUrl)
                }
                
                isLastPage = tempLikes.isEmpty
                
                likesData.append(contentsOf: tempLikes)
                currentPage += 1
                convertToViewData()
            } else if currentPage == 1 {
                delegate?.showError(with: response.errorMessage ?? LMStringConstants.shared.genericErrorMessage, isPopVC: true)
            }
        }
    }
    
    func fetchCommentLikedUsers(postId: String, commentId: String) {
        let request = GetCommentLikesRequest.builder()
            .postId(postId)
            .commentId(commentId)
            .page(currentPage)
            .pageSize(pageSize)
            .build()
        
        LMFeedClient.shared.getCommentLikes(request) { [weak self] response in
            guard let self else { return }
            isFetching = false
            
            if currentPage == 1 {
                delegate?.showHideLoaderView(isShow: false)
            } else {
                delegate?.showHideTableLoader(isShow: false)
            }
            
            if response.success,
            let likes = response.data?.likes,
            let users = response.data?.users {
                totalLikes = response.data?.totalLikes ?? .zero
                
                let tempLikes: [LMFeedLikeDataModel] = likes.compactMap { like in
                    guard let user = users[like.uuid ?? ""],
                          let username = user.name,
                          let uuid = user.sdkClientInfo?.uuid else { return nil }
                    
                    return .init(username: username, uuid: uuid, customTitle: user.customTitle, userImage: user.imageUrl)
                }
                
                isLastPage = tempLikes.isEmpty
                
                likesData.append(contentsOf: tempLikes)
                currentPage += 1
                convertToViewData()
            } else if currentPage == 1 {
                delegate?.showError(with: response.errorMessage ?? LMStringConstants.shared.genericErrorMessage)
            }
        }
    }
    
    func convertToViewData() {
        let convertedData: [LMFeedLikeUserTableCell.ViewModel] = likesData.map { like in
                .init(username: like.username, uuid: like.uuid, customTitle: like.customTitle, profileImage: like.userImage)
        }
        
        delegate?.reloadTableView(with: convertedData, totalCount: totalLikes)
    }
}
