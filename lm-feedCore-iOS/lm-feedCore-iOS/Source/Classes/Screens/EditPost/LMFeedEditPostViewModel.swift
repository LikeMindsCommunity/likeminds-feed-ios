//
//  LMFeedEditPostViewModel.swift
//  lm-feedCore-iOS
//
//  Created by Devansh Mohata on 25/01/24.
//

import LikeMindsFeed
import LikeMindsFeedUI

public protocol LMFeedEditPostViewModelProtocol: LMBaseViewControllerProtocol {
    func navigateToTopicView(with topics: [LMFeedTopicDataModel])
    func setupData(with userData: LMFeedCreatePostHeaderView.ContentModel, question: String, text: String)
    func setupDocumentPreview(with data: [LMFeedDocumentPreview.ContentModel])
    func setupLinkPreview(with data: LMFeedLinkPreview.ContentModel?)
    func setupMediaPreview(with mediaCells: [LMFeedMediaProtocol])
    func setupPollPreview(with poll: LMFeedCreateDisplayPollView.ContentModel)
    func setupTopicFeed(with data: LMFeedTopicView.ContentModel)
}

public final class LMFeedEditPostViewModel {
    private let dispatchGroup: DispatchGroup
    private let postID: String
    
    private var documents: [LMFeedPostDataModel.DocumentAttachment]
    private var linkPreview: LMFeedPostDataModel.LinkAttachment?
    private var media: [LMFeedPostDataModel.ImageVideoAttachment]
    private var pollPreview: LMFeedPollDataModel?
    
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
    
    public static func createModule(for postID: String) -> LMFeedEditPostScreen? {
        guard LMFeedCore.isInitialized else { return nil }
        
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
            let widgets = response.data?.widgets ?? [:]
            
            self.postDetail = .init(post: data, users: users, allTopics: allTopics, widgets: widgets, filteredComments: [:])
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
        delegate?.navigateToTopicView(with: selectedTopics)
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
        pollPreview = postDetail.pollAttachment
        
        isShowLinkPreview = documents.isEmpty && media.isEmpty
        
        let headerData: LMFeedCreatePostHeaderView.ContentModel = .init(profileImage: postDetail.userDetails.userProfileImage, username: postDetail.userDetails.userName)
        
        delegate?.setupData(with: headerData, question: postDetail.postQuestion, text: postDetail.postContent)
        
        
        if !media.isEmpty {
            let mediaCells = LMFeedConvertToFeedPost.convertToMediaProtocol(from: media, postID: postDetail.postId)
            delegate?.setupMediaPreview(with: mediaCells)
        } else if !documents.isEmpty {
            let documentCells = LMFeedConvertToFeedPost.convertToDocument(from: documents)
            delegate?.setupDocumentPreview(with: documentCells)
        } else if let linkData = postDetail.linkAttachment {
            linkPreview = .init(url: linkData.url, title: linkData.title, description: linkData.description, previewImage: linkData.previewImage)
            convertToLinkViewData()
        } else if let poll = postDetail.pollAttachment {
            let convertedData = convertToPollPreview(from: poll)
            delegate?.setupPollPreview(with: convertedData)
        }
        
        if isShowTopicFeed || !selectedTopics.isEmpty {
            setupTopicFeed()
        }
    }
    
    private func setupTopicFeed() {
        let topics: [LMFeedTopicCollectionCellDataModel] = selectedTopics.map({ .init(topic: $0.topicName, topicID: $00.topicID) })
        let topicData: LMFeedTopicView.ContentModel = .init(topics: topics, isSelectFlow: isShowTopicFeed && topics.isEmpty, isEditFlow: isShowTopicFeed && !topics.isEmpty, isSepratorShown: true)
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
        
        let linkViewModel: LMFeedLinkPreview.ContentModel = .init(
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
    
    func convertToPollPreview(from poll: LMFeedPollDataModel) -> LMFeedCreateDisplayPollView.ContentModel {
        .init(
            question: poll.question,
            showEditIcon: false,
            showCrossIcon: false,
            expiryDate: Date(timeIntervalSince1970: TimeInterval(poll.expiryTime / 1000)),
            optionState: poll.pollSelectType.description,
            optionCount: poll.pollSelectCount,
            options: poll.options.map {
                .init(option: $0.option, addedBy: poll.allowAddOptions ? $0.addedBy.userName : nil)
            }
        )
    }
}


// MARK: Update Post
extension LMFeedEditPostViewModel {
    func updatePost(with text: String, question: String) {
        let disabledTopics = selectedTopics.filter({ !$0.isEnabled }).map({ $0.topicName })
        
        guard disabledTopics.isEmpty else {
            delegate?.showError(with: "Following Topics are disabled - \(disabledTopics.joined(separator: ", "))", isPopVC: false)
            return
        }
        
        LMFeedEditPostOperation.shared.editPostWithAttachments(
            postID: postID, 
            heading: question,
            postCaption: text,
            topics: selectedTopics.map({ $0.topicID }),
            documents: documents,
            media: media,
            linkAttachment: linkPreview,
            poll: pollPreview
        )
        delegate?.popViewController(animated: true)
    }
}

