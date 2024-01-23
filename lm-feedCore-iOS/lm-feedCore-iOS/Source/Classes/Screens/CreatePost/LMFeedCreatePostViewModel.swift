//
//  LMFeedCreatePostViewModel.swift
//  lm-feedCore-iOS
//
//  Created by Devansh Mohata on 18/01/24.
//

import lm_feedUI_iOS
import LikeMindsFeed
import Photos
import PDFKit

public protocol LMFeedCreatePostViewModelProtocol: LMBaseViewControllerProtocol { 
    func showMedia(documents: [LMFeedDocumentPreview.ViewModel], isShowAddMore: Bool, isShowBottomTab: Bool)
    func showMedia(media: [LMFeedMediaProtocol], isShowAddMore: Bool, isShowBottomTab: Bool)
    func resetMediaView()
    func openMediaPicker(_ mediaType: LMFeedCreatePostViewModel.AttachmentType, isFirstPick: Bool, allowedNumber: Int)
    func updateTopicView(with data: LMFeedTopicView.ViewModel)
    func navigateToTopicView(with topics: [String])
    func setupLinkPreview(with data: LMFeedLinkPreview.ViewModel?)
}

public final class LMFeedCreatePostViewModel {
    public struct Attachment {
        let url: URL
        let mediaType: AttachmentType
        
        public init(url: URL, mediaType: AttachmentType) {
            self.url = url
            self.mediaType = mediaType
        }
    }
    
    public enum AttachmentType {
        case image,
             video,
             document,
             none
    }
    
    // MARK: Data Variables
    public var media: [Attachment]
    public var currentMediaSelectionType: AttachmentType
    public weak var delegate: LMFeedCreatePostViewModelProtocol?
    public var maxMedia = 10
    public var isShowTopicFeed: Bool
    public var showLinkPreview: Bool
    public var debounceForDecodeLink: Timer?
    public var linkPreview: LMFeedLinkPreviewDataModel?
    public var selectedTopics: [(topic: String, topicID: String)]
    
    init(delegate: LMFeedCreatePostViewModelProtocol?) {
        currentMediaSelectionType = .none
        media = []
        isShowTopicFeed = false
        selectedTopics = []
        showLinkPreview = true
        self.delegate = delegate
    }
    
    public static func createModule() -> LMFeedCreatePostViewController {
        let viewcontroller = Components.shared.createPostScreen.init()
        let viewModel = LMFeedCreatePostViewModel(delegate: viewcontroller)
        
        viewcontroller.viewModel = viewModel
        return viewcontroller
    }
    
    func getTopics() {
        let request = TopicFeedRequest.builder()
            .setEnableState(true)
            .build()
        
        LMFeedClient.shared.getTopicFeed(request) { [weak self] response in
            self?.isShowTopicFeed = !(response.data?.topics?.isEmpty ?? true)
            self?.setupTopicFeed()
        }
    }
    
    func setupTopicFeed() {
        if isShowTopicFeed {
            let data: LMFeedTopicView.ViewModel = .init(topics: selectedTopics.map({ .init(topic: $0.topic, topicID: $0.topicID) }),
                                                        isSelectFlow: selectedTopics.isEmpty,
                                                        isEditFlow: !selectedTopics.isEmpty,
                                                        isSepratorShown: true)
            
            delegate?.updateTopicView(with: data)
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
    
    public func handleAssets(assets: [(PHAsset, URL)]) {
        assets.forEach { asset in
            if !media.contains(where: { $0.url == asset.1 }) {
                if asset.0.mediaType == .image {
                    media.append(.init(url: asset.1, mediaType: .image))
                } else if asset.0.mediaType == .video {
                    media.append(.init(url: asset.1, mediaType: .video))
                }
            }
        }
        
        reloadMedia()
    }
    
    public func removeAsset(url: String) {
        media.removeAll(where: { $0.url.absoluteString == url })
        reloadMedia()
    }
    
    public func handleAssets(assets: [URL]) {
        
        assets.prefix(maxMedia - media.count).forEach { asset in
            if !media.contains(where: { $0.url == asset }) {
                media.append(.init(url: asset, mediaType: .document))
            }
        }
        reloadMedia()
    }
    
    func reloadMedia() {
        var docData: [LMFeedDocumentPreview.ViewModel] = []
        var mediaData: [LMFeedMediaProtocol] = []
        
        if media.isEmpty {
            currentMediaSelectionType = .none
        }
        
        media.forEach { medium in
            switch medium.mediaType {
            case .image:
                mediaData.append(LMFeedImageCollectionCell.ViewModel(image: medium.url.absoluteString, isFilePath: medium.url.isFileURL))
            case .video:
                mediaData.append(LMFeedVideoCollectionCell.ViewModel(videoURL: medium.url.absoluteString, isFilePath: medium.url.isFileURL))
            case .document:
                docData.append(
                    .init(
                        title: medium.url.deletingPathExtension().lastPathComponent,
                        documentURL: medium.url.absoluteString,
                        size: medium.url.getFileSize(),
                        pageCount: getNumberOfPages(from: medium.url),
                        docType: medium.url.pathExtension,
                        isShowCrossButton: true
                    )
                )
            case .none:
                break
            }
        }
        
        delegate?.resetMediaView()
        
        switch currentMediaSelectionType {
        case .image, .video:
            delegate?.showMedia(media: mediaData, isShowAddMore: !media.isEmpty && media.count < maxMedia, isShowBottomTab: media.isEmpty)
        case .document:
            delegate?.showMedia(documents: docData, isShowAddMore: !media.isEmpty && media.count < maxMedia, isShowBottomTab: media.isEmpty)
        case .none:
            break
        }
    }
    
    func getNumberOfPages(from url: URL) -> Int? {
        guard url.isFileURL else { return nil }
        if let pdfDocument = PDFDocument(url: url) {
            return pdfDocument.pageCount
        } else {
            return nil
        }
    }
    
    func updateCurrentSelection(to type: AttachmentType) {
        currentMediaSelectionType = type
        delegate?.openMediaPicker(type, isFirstPick: media.isEmpty, allowedNumber: maxMedia - media.count)
    }
    
    func addMoreButtonClicked() {
        switch currentMediaSelectionType {
        case .image, .video, .document:
            delegate?.openMediaPicker(currentMediaSelectionType, isFirstPick: media.isEmpty, allowedNumber: maxMedia - media.count)
        case .none:
            break
        }
    }
}


// MARK: Link Detection
extension LMFeedCreatePostViewModel {
    func handleLinkDetection(in text: String) {
        guard showLinkPreview,
              currentMediaSelectionType == .none,
              let link = text.detectLink() else {
            delegate?.setupLinkPreview(with: nil)
            return }
        
        debounceForDecodeLink?.invalidate()
        
        debounceForDecodeLink = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { [weak self] _ in
            let request = DecodeUrlRequest.builder()
                .link(link)
                .build()
            
            LMFeedClient.shared.decodeUrl(request) { [weak self] response in
                if response.success,
                    let ogTags = response.data?.oGTags {
                    self?.linkPreview = .init(url: link, imagePreview: ogTags.image, title: ogTags.title, description: ogTags.description)
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
            linkPreview: linkPreview.imagePreview,
            title: linkPreview.title,
            description: linkPreview.description,
            url: linkPreview.url
        )
        
        delegate?.setupLinkPreview(with: linkViewModel)
    }
    
    func hideLinkPreview() {
        self.showLinkPreview = false
    }
}
