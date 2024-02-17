//
//  LMFeedEditPostViewModel.swift
//  lm-feedCore-iOS
//
//  Created by Devansh Mohata on 25/01/24.
//

import LikeMindsFeed
import lm_feedUI_iOS

public protocol LMFeedEditPostViewModelProtocol: LMBaseViewControllerProtocol {
    func navigateToTopicView(with topics: [String])
    func setupData(with userData: LMFeedCreatePostHeaderView.ViewDataModel, text: String)
    func setupDocumentPreview(with data: [LMFeedDocumentPreview.ViewModel])
    func setupLinkPreview(with data: LMFeedLinkPreview.ViewModel?)
    func setupMediaPreview(with mediaCells: [LMFeedMediaProtocol])
    func setupTopicFeed(with data: LMFeedTopicView.ViewModel)
}

public final class LMFeedEditPostViewModel {
    private let dispatchGroup: DispatchGroup
    private let postID: String
    
    private var documents: [LMFeedPostDataModel.DocumentAttachment]
    private var linkPreview: LMFeedPostDataModel.LinkAttachment?
    private var media: [LMFeedPostDataModel.ImageVideoAttachment]
    
    private var debounceForDecodeLink: Timer?
    private var errorMessage: String
    private var isShowLinkPreview: Bool
    private var isShowTopicFeed: Bool
    private var postDetail: LMFeedPostDataModel?
    private var selectedTopics: [LMFeedTopicDataModel]
    
    private weak var delegate: LMFeedEditPostViewModelProtocol?
    
    init(postID: String, delegate: LMFeedEditPostViewModelProtocol) {
        self.dispatchGroup = DispatchGroup()
        self.postID = postID
        
        self.documents = []
        self.media = []
        
        self.errorMessage = LMStringConstants.shared.genericErrorMessage
        self.isShowLinkPreview = true
        self.isShowTopicFeed = false
        self.selectedTopics = []

        self.delegate = delegate
    }
    
    public static func createModule(for postID: String) -> LMFeedEditPostViewController? {
        guard LMFeedMain.isInitialized else { return nil }
        
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
    
    func updateTopicFeed(with topics: [LMFeedTopicDataModel]) {
        self.selectedTopics = topics
        setupTopicFeed()
    }
    
    private func convertToViewModel() {
        guard let postDetail else {
            self.delegate?.showError(with: errorMessage, isPopVC: true)
            return
        }
        
        selectedTopics = postDetail.topics
        documents = postDetail.documentAttachment
        media = postDetail.imageVideoAttachment
        
        isShowLinkPreview = documents.isEmpty && media.isEmpty
        
        let headerData: LMFeedCreatePostHeaderView.ViewDataModel = .init(profileImage: postDetail.userDetails.userProfileImage, username: postDetail.userDetails.userName)
        
        delegate?.setupData(with: headerData, text: postDetail.postContent)
        
        
        if !media.isEmpty {
            let mediaCells = LMFeedConvertToFeedPost.convertToMediaProtocol(from: media)
            delegate?.setupMediaPreview(with: mediaCells)
        } else if !documents.isEmpty {
            let documentCells = LMFeedConvertToFeedPost.convertToDocument(from: documents)
            delegate?.setupDocumentPreview(with: documentCells)
        } else if let linkData = postDetail.linkAttachment {
            linkPreview = .init(url: linkData.url, title: linkData.title, description: linkData.description, previewImage: linkData.previewImage)
            convertToLinkViewData()
        }
        
        if isShowTopicFeed || !selectedTopics.isEmpty {
            setupTopicFeed()
        }
    }
    
    private func setupTopicFeed() {
        let topics: [LMFeedTopicCollectionCellDataModel] = selectedTopics.map({ .init(topic: $0.topicName, topicID: $00.topicID) })
        let topicData: LMFeedTopicView.ViewModel = .init(topics: topics, isSelectFlow: isShowTopicFeed && topics.isEmpty, isEditFlow: isShowTopicFeed && !topics.isEmpty, isSepratorShown: true)
        delegate?.setupTopicFeed(with: topicData)
    }
}


// MARK: Link Preview Handling
extension LMFeedEditPostViewModel {
    func handleLinkDetection(in text: String) {
        guard let link = text.detectLink() else {
            linkPreview = nil
            delegate?.setupLinkPreview(with: nil)
            return
        }
        
        guard isShowLinkPreview else { return }
        
        debounceForDecodeLink?.invalidate()
        
        debounceForDecodeLink = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { [weak self] _ in
            let request = DecodeUrlRequest.builder()
                .link(link)
                .build()
            
            LMFeedClient.shared.decodeUrl(request) { [weak self] response in
                if response.success,
                    let ogTags = response.data?.oGTags {
                    self?.linkPreview = .init(url: ogTags.url ?? link, title: ogTags.title, description: ogTags.description, previewImage: ogTags.image)
                } else {
                    self?.linkPreview = nil
                }
                self?.convertToLinkViewData()
            }
        }
    }
    
    func convertToLinkViewData() {
        guard let linkPreview else {
            delegate?.setupLinkPreview(with: nil)
            return
        }
        
        let linkViewModel: LMFeedLinkPreview.ViewModel = .init(
            linkPreview: linkPreview.previewImage,
            title: linkPreview.title,
            description: linkPreview.description,
            url: linkPreview.url
        )
        
        delegate?.setupLinkPreview(with: linkViewModel)
    }
    
    func hideLinkPreview() {
        isShowLinkPreview = false
    }
}


// MARK: Update Post
extension LMFeedEditPostViewModel {
    func updatePost(with text: String) {
        let disabledTopics = selectedTopics.filter({ !$0.isEnabled }).map({ $0.topicName })
        
        guard disabledTopics.isEmpty else {
            delegate?.showError(with: "Following Topics are disabled - \(disabledTopics.joined(separator: ", "))", isPopVC: false)
            return
        }
        
        LMFeedEditPostOperation.shared.editPostWithAttachments(postID: postID, postCaption: text, topics: selectedTopics.map({ $0.topicID }), documents: documents, media: media, linkAttachment: linkPreview)
    }
}

