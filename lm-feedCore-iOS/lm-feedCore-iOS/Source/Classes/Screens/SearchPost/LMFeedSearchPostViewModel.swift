//
//  LMFeedSearchPostViewModel.swift
//  LikeMindsFeedCore
//
//  Created by Devansh Mohata on 29/06/24.
//

import LikeMindsFeed
import LikeMindsFeedUI

public protocol LMFeedSearchPostViewModelProtocol: LMBaseViewControllerProtocol {
    func showLoader(isShow: Bool)
    func showTableFooter(isShow: Bool)
    func updatePostList(with post: [LMFeedPostContentModel])
    func removePost(postID: String)
    func updatePost(post: LMFeedPostContentModel)
    func showEmptyView()
    func removePreviousResults()
    
    func navigateToDeleteScreen(for postID: String)
    func navigateToReportScreen(for postID: String, creatorUUID: String)
    func navigateToPollResultScreen(with pollID: String, optionList: [LMFeedPollDataModel.Option], selectedOption: String?)
    func navigateToAddOptionPoll(with postID: String, pollID: String, options: [String])
}

public class LMFeedSearchPostViewModel {
    var timer: Timer?
    unowned var delegate: LMFeedSearchPostViewModelProtocol
    var postList: [LMFeedPostDataModel]
    var page: Int
    var searchString: String
    let pageSize: Int
    let searchType: String
    var isFetchingResults: Bool
    var isLastPage: Bool
    
    init(delegate: LMFeedSearchPostViewModelProtocol) {
        self.timer = nil
        self.delegate = delegate
        self.postList = []
        self.page = 1
        self.pageSize = 10
        self.searchString = ""
        self.searchType = "text"
        self.isFetchingResults = false
        self.isLastPage = false
    }
    
    public static func createModule() throws -> LMFeedSearchPostScreen {
        guard LMFeedCore.isInitialized else { throw LMFeedError.feedNotInitialized }
        
        let viewController = Components.shared.searchPostScreen.init()
        let viewModel = LMFeedSearchPostViewModel.init(delegate: viewController)
        
        viewController.viewModel = viewModel
        
        return viewController
    }
    
    public func searchPosts(with search: String) {
        timer?.invalidate()
        
        guard !search.isEmpty else {
            delegate.removePreviousResults()
            return
        }
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { [weak self] _ in
            self?.postList.removeAll(keepingCapacity: true)
            
            self?.page = 1
            self?.isLastPage = false
            self?.isFetchingResults = false
            
            self?.searchString = search
            
            self?.fetchPosts()
            
            self?.delegate.removePreviousResults()
        }
    }
    
    public func fetchPaginated() {
        fetchPosts()
    }
    
    func fetchPosts() {
        guard !isFetchingResults,
              !isLastPage else { return }
        
        isFetchingResults = true
        handleLoader(isShow: true)
        
        let request = SearchPostsRequest
            .builder()
            .search(searchString)
            .searchType(searchType)
            .page(page)
            .pageSize(pageSize)
            .build()
        
        LMFeedClient.shared.searchPosts(request) { [weak self] response in
            defer {
                self?.isFetchingResults = false
                self?.handleLoader(isShow: false)
            }
            
            guard response.success,
                  let posts = response.data?.posts,
                  let users = response.data?.users else {
                return
            }
            
            
            let topics: [TopicFeedResponse.TopicResponse] = response.data?.topics?.compactMap {
                $0.value
            } ?? []
            
            let widgets = response.data?.widgets?.compactMap({ $0.value }) ?? []
            
            let convertedData: [LMFeedPostDataModel] = posts.compactMap { post in
                return .init(post: post, users: users, allTopics: topics, widgets: widgets)
            }
            
            self?.page += 1
            self?.isLastPage = convertedData.isEmpty
            self?.convertToViewData(for: convertedData)
        }
    }
    
    func convertToViewData(for data: [LMFeedPostDataModel]) {
        postList.append(contentsOf: data)
        
        guard !postList.isEmpty else {
            delegate.showEmptyView()
            return
        }
        
        DispatchQueue.global(qos: .background).async { [weak delegate] in
            var convertedViewData: [LMFeedPostContentModel] = []
            
            data.forEach { post in
                convertedViewData.append(LMFeedConvertToFeedPost.convertToViewModel(for: post))
            }
            
            DispatchQueue.main.async {
                delegate?.updatePostList(with: convertedViewData)
            }
        }
    }
    
    func handleLoader(isShow: Bool) {
        if isShow {
            if page == 1 {
                delegate.showLoader(isShow: isShow)
            } else {
                delegate.showTableFooter(isShow: isShow)
            }
        } else {
            delegate.showLoader(isShow: isShow)
            delegate.showTableFooter(isShow: isShow)
        }
    }
    
    func reloadList() {
        DispatchQueue.global(qos: .background).async { [weak self] in
            var convertedViewData: [LMFeedPostContentModel] = []
            
            self?.postList.forEach { post in
                convertedViewData.append(LMFeedConvertToFeedPost.convertToViewModel(for: post))
            }
            
            DispatchQueue.main.async {
                self?.delegate.updatePostList(with: convertedViewData)
            }
        }
    }
}


// MARK: Action Handling
extension LMFeedSearchPostViewModel {
    func showMenu(for postID: String) {
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
                    self?.delegate.navigateToReportScreen(for: postID, creatorUUID: post.userDetails.userUUID)
                }
                alert.addAction(action)
            default:
                break
            }
        }
        
        alert.addAction(.init(title: "Cancel", style: .cancel))
        
        delegate.presentAlert(with: alert, animated: true)
    }
}


// MARK: Delete Post
public extension LMFeedSearchPostViewModel {
    func handleDeletePost(for post: LMFeedPostDataModel) {
        // Case of Self Deletion
        if post.userDetails.userUUID == LocalPreferences.userObj?.sdkClientInfo?.uuid {
            let alert = UIAlertController(title: "Delete Post?", message: "Are you sure you want to delete this post? This action cannot be reversed", preferredStyle: .alert)
            
            let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
                self?.deletePost(postID: post.postId, reason: nil)
            }
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
            
            alert.addAction(cancelAction)
            alert.addAction(deleteAction)
            
            delegate.presentAlert(with: alert, animated: true)
            
            LMFeedCore.analytics?.trackEvent(for: .postDeleted, eventProperties: [
                "user_state": "member",
                "user_id": post.userDetails.userUUID,
                "post_id": post.postId,
                "post_type": post.getPostType()
            ])
        } else if LocalPreferences.memberState?.state == 1 {
            delegate.navigateToDeleteScreen(for: post.postId)
            
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
                delegate.showError(with: error.localizedDescription, isPopVC: false)
            }
        }
    }
    
    func removePost(for postID: String) {
        guard let index = postList.firstIndex(where: { $0.postId == postID }) else { return }
        postList.remove(at: index)
        delegate.removePost(postID: postID)
    }
}


// MARK: Pin Post
public extension LMFeedSearchPostViewModel {
    func togglePostPin(for postID: String) {
        LMFeedPostOperation.shared.pinUnpinPost(postId: postID) { [weak self] response in
            guard let self,
                  let index = postList.firstIndex(where: { $0.postId == postID }) else { return }
            
            if response {
                var feed = postList[index]
                feed.isPinned.toggle()
                if let idx = feed.postMenu.firstIndex(where: { $0.id == .pinPost }) {
                    feed.postMenu[idx] = .init(id: .unpinPost, name: "Unpin this Post")
                } else if let idx = feed.postMenu.firstIndex(where: { $0.id == .unpinPost }) {
                    feed.postMenu[idx] = .init(id: .pinPost, name: "Pin this Post")
                }
                
                postList[index] = feed
                
                var convertedPost = LMFeedConvertToFeedPost.convertToViewModel(for: feed)
                delegate.updatePost(post: convertedPost)
            }
        }
    }
}


// MARK: Like Post
public extension LMFeedSearchPostViewModel {
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
                self.reloadList()
            }
        }
    }
    
    func allowPostLikeView(for postId: String) -> Bool {
        guard let likeCount = postList.first(where: { $0.postId == postId })?.likeCount else { return false }
        return likeCount > 0
    }
}


// MARK: Save Post
public extension LMFeedSearchPostViewModel {
    func savePost(for postId: String) {
        LMFeedPostOperation.shared.savePost(for: postId) { [weak self] response in
            guard let self,
                  let index = postList.firstIndex(where: { $0.postId == postId }) else { return }
            
            if response {
                var feed = postList[index]
                feed.isSaved.toggle()
                postList[index] = feed
            } else {
                self.reloadList()
            }
        }
    }
}


// MARK: Poll
public extension LMFeedSearchPostViewModel {
    func didTapVoteCountButton(for postID: String, pollID: String, optionID: String?) {
        guard let poll = postList.first(where: { $0.postId == postID })?.pollAttachment else { return }
        
        if poll.isAnonymous {
            delegate.showMessage(with: "This being an anonymous poll, the names of the voters can not be disclosed.", message: nil)
        } else if poll.showResults || poll.expiryTime < Int(Date().timeIntervalSince1970) {
            let options = poll.options
            delegate.navigateToPollResultScreen(with: pollID, optionList: options, selectedOption: optionID)
        } else {
            delegate.showMessage(with: "The results will be visible after the poll has ended.", message: nil)
        }
    }
    
    func didTapAddOption(for postID: String, pollID: String) {
        guard let poll = postList.first(where: { $0.postId == postID }) else { return }
        
        let options = poll.pollAttachment?.options.map({ $0.option }) ?? []
        
        delegate.navigateToAddOptionPoll(with: postID, pollID: pollID, options: options)
    }
    
    func getPost(for id: String) {
        LMFeedPostOperation.shared.getPost(for: id, currentPage: 1, pageSize: 10) { [weak self] response in
            guard let self else { return }
            
            if response.success,
               let post = response.data?.post,
               let users = response.data?.users {
                let allTopics = response.data?.topics?.compactMap({ $0.value }) ?? []
                let widgets = response.data?.widgets?.compactMap({ $0.value }) ?? []
                
                
                guard let newData = LMFeedPostDataModel.init(post: post, users: users, allTopics: allTopics, widgets: widgets),
                      let index = postList.firstIndex(where: { $0.postId == id }) else { return }
                
                postList[index] = newData
                delegate.updatePost(post: LMFeedConvertToFeedPost.convertToViewModel(for: newData))
            }
        }
    }
    
    func optionSelected(for postID: String, pollID: String, option: String) {
        guard let index = postList.firstIndex(where: { $0.postId == postID }) else { return }
        
        var post = postList[index]
        
        guard var poll = post.pollAttachment else { return }
        
        var expiryTime = poll.expiryTime
        
        if !DateUtility.isEpochTimeInSeconds(expiryTime) {
            expiryTime = expiryTime / 1000
        }
        
        if expiryTime < Int(Date().timeIntervalSince1970) {
            delegate.showMessage(with: "Poll ended. Vote can not be submitted now.", message: nil)
            return
        } else if LMFeedConvertToFeedPost.isPollSubmitted(options: poll.options) {
            return
        } else if !LMFeedConvertToFeedPost.isMultiChoicePoll(pollSelectCount: poll.pollSelectCount, pollSelectType: poll.pollSelectType) {
            submitPollVote(for: postID, pollID: pollID, options: [option])
        } else {
            if let index = poll.userSelectedOptions.firstIndex(of: option) {
                poll.userSelectedOptions.remove(at: index)
            } else {
                poll.userSelectedOptions.append(option)
            }
            
            post.pollAttachment = poll
            postList[index] = post
            
            delegate.updatePost(post: LMFeedConvertToFeedPost.convertToViewModel(for: post))
        }
    }
    
    func pollSubmitButtonTapped(for postID: String, pollID: String) {
        guard let post = postList.first(where: { $0.postId == postID }),
              let poll = post.pollAttachment else { return }
        
        
        guard poll.pollSelectType.checkValidity(with: poll.userSelectedOptions.count, allowedCount: poll.pollSelectCount) else {
            delegate.showMessage(with: "Please select \(poll.pollSelectType.description.lowercased()) \(poll.pollSelectCount) options", message: nil)
            return
        }
        
        submitPollVote(for: postID, pollID: pollID, options: poll.userSelectedOptions)
    }
    
    func submitPollVote(for postID: String, pollID: String, options: [String]) {
        let request = SubmitPollVoteRequest
            .builder()
            .pollID(pollID)
            .votes(options)
            .build()
        
        LMFeedClient.shared.submitPollVoteRequest(request) { [weak self] response in
            if response.success {
                self?.getPost(for: postID)
            }
        }
    }
    
    func editPoll(for postID: String) {
        guard let index = postList.firstIndex(where: { $0.postId == postID }) else { return }
        
        var post = postList[index]
        
        guard var poll = post.pollAttachment else { return }
        
        var selectedOptions: [String] = []
        
        let count = poll.options.count
        
        for i in 0..<count {
            if poll.options[i].isSelected {
                selectedOptions.append(poll.options[i].id)
            }
            
            poll.options[i].isSelected = false
        }
        
        poll.userSelectedOptions = selectedOptions
        
        post.pollAttachment = poll
        
        postList[index] = post
        
        delegate.updatePost(post: LMFeedConvertToFeedPost.convertToViewModel(for: post))
    }
}
