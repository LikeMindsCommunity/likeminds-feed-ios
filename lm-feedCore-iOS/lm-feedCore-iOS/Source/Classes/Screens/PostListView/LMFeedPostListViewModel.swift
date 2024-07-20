//
//  LMFeedPostListViewModel.swift
//  likeminds-feed-iOS
//
//  Created by Devansh Mohata on 02/01/24.
//

import LikeMindsFeedUI
import LikeMindsFeed

// MARK: LMUniversalFeedViewModelProtocol
public protocol LMFeedPostListViewModelProtocol: LMBaseViewControllerProtocol {
    func loadPosts(with data: [LMFeedPostContentModel], index: IndexSet?, reloadNow: Bool)
    func showHideFooterLoader(isShow: Bool)
    func showActivityLoader()
    func navigateToEditScreen(for postID: String)
    func navigateToDeleteScreen(for postID: String)
    func navigateToReportScreen(for postID: String, creatorUUID: String)
    func updateHeader(with data: [LMFeedPostContentModel], section: Int)
    func navigateToPollResultScreen(with pollID: String, optionList: [LMFeedPollDataModel.Option], selectedOption: String?)
    func navigateToAddOptionPoll(with postID: String, pollID: String, options: [String])
}

public class LMFeedPostListViewModel {
    public var currentPage: Int
    public var pageSize: Int
    public var selectedTopics: [String] = []
    public var isLastPostReached: Bool = false
    public var isFetchingFeed: Bool = false
    public var postList: [LMFeedPostDataModel] = []
    
    public weak var delegate: LMFeedPostListViewModelProtocol?
    
    init(delegate: LMFeedPostListViewModelProtocol) {
        self.currentPage = 1
        self.pageSize = 10
        self.selectedTopics = []
        self.isLastPostReached = false
        self.isFetchingFeed = false
        self.postList = []
        self.delegate = delegate
    }
    
    public static func createModule(with delegate: LMFeedPostListVCFromProtocol?) throws -> LMFeedPostListScreen {
        guard LMFeedCore.isInitialized else { throw LMFeedError.feedNotInitialized }
        
        let viewController = Components.shared.feedListScreen.init()
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
                convertToViewData()
                isFetchingFeed = false
                return
            }
            
            self.isLastPostReached = posts.isEmpty
            self.currentPage += 1
            
            
            let topics: [TopicFeedResponse.TopicResponse] = response.data?.topics?.compactMap {
                $0.value
            } ?? []
            
            let widgets = response.data?.widgets?.compactMap({ $0.value }) ?? []
            
            let filteredComments = response.data?.filteredComments ?? [:]
            
            let convertedData: [LMFeedPostDataModel] = posts.compactMap { post in
                return .init(post: post, users: users, allTopics: topics, widgets: widgets, filteredComments: filteredComments)
            }
            
            self.postList.append(contentsOf: convertedData)
            self.convertToViewData()
            
            isFetchingFeed = false
        }
    }
    
    func convertToViewData(for section: IndexSet? = nil, reloadNow: Bool = true) {
        var convertedViewData: [LMFeedPostContentModel] = []
        
        DispatchQueue.global(qos: .background).async { [weak self] in
            self?.postList.forEach { post in
                convertedViewData.append(LMFeedConvertToFeedPost.convertToViewModel(for: post))
            }
            
            DispatchQueue.main.async {
                self?.delegate?.loadPosts(with: convertedViewData, index: section, reloadNow: reloadNow)
            }
        }
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
                convertToViewData(for: IndexSet(integer: index), reloadNow: false)
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
                convertToViewData(for: IndexSet(integer: index), reloadNow: false)
            }
        }
    }
}


// MARK: Toggle Post Pin
public extension LMFeedPostListViewModel {
    func togglePostPin(for postID: String) {
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
                
                var convertedViewData: [LMFeedPostContentModel] = []
                
                postList.forEach { post in
                    convertedViewData.append(LMFeedConvertToFeedPost.convertToViewModel(for: post))
                }
                
                delegate?.updateHeader(with: convertedViewData, section: index)
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
        
        alert.addAction(.init(title: "Cancel", style: .default))
        
        delegate?.presentAlert(with: alert, animated: true)
    }
}


// MARK: Delete Post
public extension LMFeedPostListViewModel {
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
        guard let index = postList.firstIndex(where: { $0.postId == postID }) else { return }
        _ = postList.remove(at: index)
        convertToViewData()
    }
}

// MARK: Update Post Content
public extension LMFeedPostListViewModel {
    func updatePostData(for post: LMFeedPostDataModel) {
        guard let index = postList.firstIndex(where: { $0.postId == post.postId }) else { return }
        postList[index] = post
        convertToViewData(for: .init(integer: index))
    }
}


// MARK: Poll
public extension LMFeedPostListViewModel {
    func didTapVoteCountButton(for postID: String, pollID: String, optionID: String?) {
        guard let poll = postList.first(where: { $0.postId == postID })?.pollAttachment else { return }
        
        if poll.isAnonymous {
            delegate?.showMessage(with: "This being an anonymous poll, the names of the voters can not be disclosed.", message: nil)
        } else if poll.showResults || poll.expiryTime < Int(Date().timeIntervalSince1970) {
            let options = poll.options
            delegate?.navigateToPollResultScreen(with: pollID, optionList: options, selectedOption: optionID)
        } else {
            delegate?.showMessage(with: "The results will be visible after the poll has ended.", message: nil)
        }
    }
    
    func didTapAddOption(for postID: String, pollID: String) {
        guard let poll = postList.first(where: { $0.postId == postID }) else { return }
        
        let options = poll.pollAttachment?.options.map({ $0.option }) ?? []
        
        delegate?.navigateToAddOptionPoll(with: postID, pollID: pollID, options: options)
    }
    
    func getPost(for id: String) {
        LMFeedPostOperation.shared.getPost(for: id, currentPage: 1, pageSize: 10) { [weak self] response in
            guard let self else { return }
            
            if response.success,
               let post = response.data?.post,
               let users = response.data?.users {
                let allTopics = response.data?.topics?.compactMap({ $0.value }) ?? []
                let widgets = response.data?.widgets?.compactMap({ $0.value }) ?? []
                
                guard let newData = LMFeedPostDataModel.init(post: post, users: users, allTopics: allTopics, widgets: widgets, filteredComments: [:]),
                      let index = postList.firstIndex(where: { $0.postId == id }) else { return }
                
                postList[index] = newData
                convertToViewData(for: .init(integer: index))
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
            delegate?.showMessage(with: "Poll ended. Vote can not be submitted now.", message: nil)
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
            
            convertToViewData(for: .init(integer: index))
        }
    }
    
    func pollSubmitButtonTapped(for postID: String, pollID: String) {
        guard let post = postList.first(where: { $0.postId == postID }),
              let poll = post.pollAttachment else { return }
        
        
        guard poll.pollSelectType.checkValidity(with: poll.userSelectedOptions.count, allowedCount: poll.pollSelectCount) else {
            delegate?.showMessage(with: "Please select \(poll.pollSelectType.description.lowercased()) \(poll.pollSelectCount) options", message: nil)
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
        
        convertToViewData(for: .init(integer: index))
    }
}
