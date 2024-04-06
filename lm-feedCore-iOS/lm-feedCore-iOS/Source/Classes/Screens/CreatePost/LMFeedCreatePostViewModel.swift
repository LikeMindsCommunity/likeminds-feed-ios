//
//  LMFeedCreatePostViewModel.swift
//  lm-feedCore-iOS
//
//  Created by Devansh Mohata on 18/01/24.
//

import LikeMindsFeedUI
import LikeMindsFeed
import Photos
import PDFKit

public protocol LMFeedCreatePostViewModelProtocol: LMBaseViewControllerProtocol { 
    func showMedia(documents: [LMFeedDocumentPreview.ViewModel], isShowAddMore: Bool, isShowBottomTab: Bool)
    func showMedia(media: [LMFeedMediaProtocol], isShowAddMore: Bool, isShowBottomTab: Bool)
    func resetMediaView()
    func openMediaPicker(_ mediaType: PostCreationAttachmentType, isFirstPick: Bool, allowedNumber: Int)
    func updateTopicView(with data: LMFeedTopicView.ViewModel)
    func navigateToTopicView(with topics: [LMFeedTopicDataModel])
    func setupLinkPreview(with data: LMFeedLinkPreview.ViewModel?)
}

public final class LMFeedCreatePostViewModel {
    public struct Attachment {
        let url: URL
        let data: Data
        let mediaType: PostCreationAttachmentType
        
        public init(url: URL, data: Data, mediaType: PostCreationAttachmentType) {
            self.url = url
            self.data = data
            self.mediaType = mediaType
        }
    }
    
    // MARK: Data Variables
    public weak var delegate: LMFeedCreatePostViewModelProtocol?
    private var media: [Attachment]
    private var currentMediaSelectionType: PostCreationAttachmentType
    public let maxMedia: Int
    private var isShowTopicFeed: Bool
    private var debounceForDecodeLink: Timer?
    private var selectedTopics: [LMFeedTopicDataModel]
    private var linkPreview: LMFeedPostDataModel.LinkAttachment?
    private var showLinkPreview: Bool {
        willSet {
            if !newValue {
                linkPreview = nil
            }
        }
    }
    
    init(delegate: LMFeedCreatePostViewModelProtocol?) {
        currentMediaSelectionType = .none
        media = []
        isShowTopicFeed = false
        selectedTopics = []
        showLinkPreview = true
        maxMedia = LMNumbersConstant.shared.maxFilesToUpload
        self.delegate = delegate
    }
    
    public static func createModule() throws -> LMFeedCreatePostViewController {
        guard LMFeedCore.isInitialized else { throw LMFeedError.feedNotInitialized }
        let viewcontroller = Components.shared.createPostScreen.init()
        let viewModel = LMFeedCreatePostViewModel(delegate: viewcontroller)
        
        viewcontroller.viewModel = viewModel
        return viewcontroller
    }
    
    func createPost(with text: String) {
        var attachments: [LMFeedCreatePostOperation.LMAWSRequestModel] = []
        let filePath = "files/post/\(LocalPreferences.userObj?.clientUUID ?? "user")/\(Int(Date().timeIntervalSince1970))/"
        
        media.forEach { medium in
            if medium.url.getFileSize() > LMNumbersConstant.shared.maxFileSizeInBytes {
                delegate?.showError(with: String(format: LMStringConstants.shared.maxUploadSizeErrorMessage, LMNumbersConstant.shared.maxFileSizeInMB), isPopVC: false)
                return
            }
            
            attachments.append(.init(url: medium.url, data: medium.data, fileName: medium.url.lastPathComponent, awsFilePath: filePath, contentType: medium.mediaType))
        }
        
        LMFeedCreatePostOperation.shared.createPost(with: text, topics: selectedTopics.map({ $0.topicID }), files: attachments, linkPreview: linkPreview)
        delegate?.popViewController(animated: true)
    }
}


// MARK: Assets Arena
public extension LMFeedCreatePostViewModel {
    func handleAssets(assets: [(PHAssetMediaType, URL, Data)]) {
        assets.forEach { asset in
            if asset.0 == .image {
                media.append(.init(url: asset.1, data: asset.2, mediaType: .image))
            } else if asset.0 == .video {
                media.append(.init(url: asset.1, data: asset.2, mediaType: .video))
            }
        }
        
        reloadMedia()
    }
    
    func removeAsset(url: String) {
        media.removeAll(where: { $0.url.absoluteString == url })
        reloadMedia()
    }
    
    func handleAssets(assets: [URL]) {
        assets.prefix(maxMedia - media.count).forEach { asset in
            if !media.contains(where: { $0.url == asset }),
               asset.startAccessingSecurityScopedResource(),
               let data = try? Data(contentsOf: asset) {
                media.append(.init(url: asset, data: data, mediaType: .document))
                asset.stopAccessingSecurityScopedResource()
            }
        }
        reloadMedia()
    }
    
    func updateCurrentSelection(to type: PostCreationAttachmentType) {
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
    
    func reloadMedia() {
        var docData: [LMFeedDocumentPreview.ViewModel] = []
        var mediaData: [LMFeedMediaProtocol] = []
        
        currentMediaSelectionType = media.isEmpty ? .none : currentMediaSelectionType
        
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
                        documentURL: medium.url,
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
        case .image, .video, .none:
            delegate?.showMedia(media: mediaData, isShowAddMore: !media.isEmpty && media.count < maxMedia, isShowBottomTab: media.isEmpty)
        case .document:
            delegate?.showMedia(documents: docData, isShowAddMore: !media.isEmpty && media.count < maxMedia, isShowBottomTab: media.isEmpty)
        }
    }
    
    func getNumberOfPages(from url: URL) -> Int? {
        PDFDocument(url: url)?.pageCount
    }
}


// MARK: Link Detection
extension LMFeedCreatePostViewModel {
    func handleLinkDetection(in text: String) {
        guard showLinkPreview,
              media.isEmpty,
              currentMediaSelectionType == .none else {
            delegate?.setupLinkPreview(with: nil)
            return
        }
        
        guard let link = text.detectLink(),
              linkPreview?.url != link else { return }
        
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
        self.showLinkPreview = false
    }
}


// MARK: Topics Arena
extension LMFeedCreatePostViewModel {
    func getTopics() {
        delegate?.showHideLoaderView(isShow: true)
        let request = TopicFeedRequest.builder()
            .setEnableState(true)
            .build()
        
        LMFeedClient.shared.getTopicFeed(request) { [weak self] response in
            self?.delegate?.showHideLoaderView(isShow: false)
            self?.isShowTopicFeed = !(response.data?.topics?.isEmpty ?? true)
            self?.setupTopicFeed()
        }
    }
    
    func setupTopicFeed() {
        if isShowTopicFeed {
            let data: LMFeedTopicView.ViewModel = .init(topics: selectedTopics.map({ .init(topic: $0.topicName, topicID: $0.topicID) }),
                                                        isSelectFlow: selectedTopics.isEmpty,
                                                        isEditFlow: !selectedTopics.isEmpty,
                                                        isSepratorShown: true)
            
            delegate?.updateTopicView(with: data)
        }
    }
    
    func didTapTopicSelection() {
        delegate?.navigateToTopicView(with: selectedTopics)
    }
    
    func updateTopicFeed(with topics: [LMFeedTopicDataModel]) {
        self.selectedTopics = topics
        setupTopicFeed()
    }
}
