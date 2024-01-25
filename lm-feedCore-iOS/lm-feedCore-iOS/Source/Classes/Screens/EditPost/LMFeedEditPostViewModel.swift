//
//  LMFeedEditPostViewModel.swift
//  lm-feedCore-iOS
//
//  Created by Devansh Mohata on 25/01/24.
//

import LikeMindsFeed
import lm_feedUI_iOS

public protocol LMFeedEditPostViewModelProtocol: LMBaseViewControllerProtocol { 
    func showErrorMessage(with message: String)
    func setupData(with userData: LMFeedCreatePostHeaderView.ViewDataModel, text: String, mediaCells: [LMFeedMediaProtocol], documentCells: [LMFeedDocumentPreview.ViewModel])
    func navigateToTopicView(with topics: [String])
    func setupTopicFeed(with data: LMFeedTopicView.ViewModel)
}

public final class LMFeedEditPostViewModel {
    public weak var delegate: LMFeedEditPostViewModelProtocol?
    public var postID: String
    public var isShowTopicFeed: Bool
    public var postDetail: LMFeedPostDataModel?
    let dispatchGroup: DispatchGroup
    private var errorMessage: String
    private var selectedTopics: [(topic: String, topicID: String)]
    
    init(postID: String, delegate: LMFeedEditPostViewModelProtocol) {
        self.postID = postID
        self.isShowTopicFeed = false
        self.delegate = delegate
        self.dispatchGroup = DispatchGroup()
        self.selectedTopics = []
        self.errorMessage = "Something Went Wrong"
    }
    
    public static func createModule(for postID: String) -> LMFeedEditPostViewController {
        let viewcontroller = Components.shared.editPostScreen.init()
        let viewmodel = Self.init(postID: postID, delegate: viewcontroller)
        
        viewcontroller.viewmodel = viewmodel
        return viewcontroller
    }
    
    func getInitalData() {
        delegate?.showHideLoaderView(isShow: true)
        getPostDetails()
        getTopics()
        
        dispatchGroup.notify(queue: .main) { [weak self] in
            self?.delegate?.showHideLoaderView(isShow: false)
            self?.convertToViewModel()
        }
    }
    
    private func getPostDetails() {
        dispatchGroup.enter()
        
        let request = GetPostRequest
            .builder()
            .postId(postID)
            .page(1)
            .pageSize(10)
            .build()
        
        LMFeedClient.shared.getPost(request) { [weak self] response in
            guard let self else { return }
            
            guard response.success,
                  let data = response.data?.post,
                  let users = response.data?.users else {
                errorMessage = response.errorMessage ?? errorMessage
                dispatchGroup.leave()
                return
            }
            
            let allTopics = response.data?.topics?.compactMap({ $0.value }) ?? []
            self.postDetail = .init(post: data, users: users, allTopics: allTopics)
            dispatchGroup.leave()
        }
    }
    
    private func getTopics() {
        dispatchGroup.enter()
        
        let request = TopicFeedRequest.builder()
            .setEnableState(true)
            .build()
        
        LMFeedClient.shared.getTopicFeed(request) { [weak self] response in
            self?.isShowTopicFeed = !(response.data?.topics?.isEmpty ?? true)
            self?.dispatchGroup.leave()
        }
    }
    
    func didTapTopicSelection() {
        let currentTopics = selectedTopics.map({ $0.topicID })
        delegate?.navigateToTopicView(with: currentTopics)
    }
    
    func updateTopicFeed(with topics: [(String, String)]) {
        self.selectedTopics = topics
        setupTopicFeed()
    }
    
    private func convertToViewModel() {
        guard let postDetail else {
            self.delegate?.showErrorMessage(with: errorMessage)
            return
        }
        
        selectedTopics = postDetail.topics.map { ($0.topic, $0.topicId) }
        
        let headerData: LMFeedCreatePostHeaderView.ViewDataModel = .init(profileImage: postDetail.userDetails.userProfileImage, username: postDetail.userDetails.userName)
        let mediaCells = LMFeedConvertToFeedPost.convertToMediaProtocol(from: postDetail.imageVideoAttachment)
        let documentCells = LMFeedConvertToFeedPost.convertToDocument(from: postDetail.documentAttachment)
        
        if isShowTopicFeed || !selectedTopics.isEmpty {
            setupTopicFeed()
        }
        
        delegate?.setupData(with: headerData, text: postDetail.postContent, mediaCells: mediaCells, documentCells: documentCells)
    }
    
    private func setupTopicFeed() {
        var topics: [LMFeedTopicCollectionCellDataModel] = selectedTopics.map({ .init(topic: $0.topic, topicID: $0.topicID) })
        let topicData: LMFeedTopicView.ViewModel = .init(topics: topics, isSelectFlow: isShowTopicFeed && topics.isEmpty, isEditFlow: isShowTopicFeed && !topics.isEmpty, isSepratorShown: true)
        delegate?.setupTopicFeed(with: topicData)
    }
}
