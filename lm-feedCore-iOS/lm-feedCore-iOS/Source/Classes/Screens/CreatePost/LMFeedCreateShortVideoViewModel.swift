//
//  LMFeedCreateShortVideoViewModel.swift
//  lm-feedCore-iOS
//
//  Created by Arpit Verma on 16/05/25.
//

import Foundation
import Photos
import LikeMindsFeedUI
import LikeMindsFeed
import Photos
import PDFKit

public protocol LMFeedCreateShortVideoViewModelProtocol: LMBaseViewControllerProtocol {
    func showVideo(video: [LMFeedMediaProtocol])
    func resetMediaView()
    func openMediaPicker(_ mediaType: PostCreationAttachmentType, isFirstPick: Bool, allowedNumber: Int, selectedAssets: [PHAsset])
    func updateTopicView(with data: LMFeedTopicView.ContentModel)
    func navigateToTopicView(with topics: [LMFeedTopicDataModel])
}

public class LMFeedCreateShortVideoViewModel {
    public struct Attachment {
        let url: URL
        let data: Data
        let mediaType: PostCreationAttachmentType
        let asset: PHAsset?
        let width: Int?
        let height: Int?
        
        public init(url: URL, data: Data, mediaType: PostCreationAttachmentType, asset: PHAsset? = nil, width: Int? = nil, height: Int? = nil) {
            self.url = url
            self.data = data
            self.mediaType = mediaType
            self.asset = asset
            self.height = height
            self.width = width
        }
    }
    
    // MARK: Data Variables
    public weak var delegate: LMFeedCreateShortVideoViewModelProtocol?
    private var media: [Attachment]
    private var currentMediaSelectionType: PostCreationAttachmentType
    public let maxMedia: Int
    private var isShowTopicFeed: Bool
    private var selectedTopics: [LMFeedTopicDataModel]
    
    init(delegate: LMFeedCreateShortVideoViewModelProtocol?) {
        currentMediaSelectionType = .none
        media = []
        isShowTopicFeed = false
        selectedTopics = []
        maxMedia = 1 // Only one video allowed for reels
        self.delegate = delegate
    }
    
    public static func createModule() throws -> LMFeedCreateShortVideoScreen {
        guard LMFeedCore.isInitialized else { throw LMFeedError.feedNotInitialized }
        let viewcontroller = Components.shared.createShortVideoScreen.init()
        let viewModel = LMFeedCreateShortVideoViewModel(delegate: viewcontroller)
        viewcontroller.viewModel = viewModel
        return viewcontroller
    }
    
    public func createReel(with caption: String) {
        guard let videoAttachment = media.first else {
            delegate?.showError(with: "Please select a video", isPopVC: false)
            return
        }
        
        if videoAttachment.url.getFileSize() > LMNumbersConstant.shared.maxFileSizeInBytes {
            delegate?.showError(with: String(format: LMStringConstants.shared.maxUploadSizeErrorMessage, LMNumbersConstant.shared.maxFileSizeInMB), isPopVC: false)
            return
        }
        
        let filePath = "files/reel/\(LocalPreferences.userObj?.clientUUID ?? "user")/\(Int(Date().timeIntervalSince1970))/"
        
        let attachment = LMFeedCreatePostOperation.LMAWSRequestModel(
            url: videoAttachment.url,
            data: videoAttachment.data,
            fileName: videoAttachment.url.lastPathComponent,
            awsFilePath: filePath,
            contentType: .video,
            width: videoAttachment.width,
            height: videoAttachment.height
        )
        
        LMFeedCreatePostOperation.shared.createPost(
            with: caption,
            heading: nil,
            topics: selectedTopics.map({ $0.topicID }),
            files: [attachment],
            linkPreview: nil,
            poll: nil,
            meta: ["is_reel": true]
        )
        
        delegate?.popViewController(animated: true)
    }
}

// MARK: Assets Handling
public extension LMFeedCreateShortVideoViewModel {
    func selectVideo() {
        updateCurrentSelection(to: .video)
    }
    
    func handleAssets(assets: [(PHAsset, URL, Data)]) {
        media.removeAll(keepingCapacity: true)
        
        // Only take the first video asset
        if let videoAsset = assets.first(where: { $0.0.mediaType == .video }) {
            media.append(.init(
                url: videoAsset.1,
                data: videoAsset.2,
                mediaType: .video,
                asset: videoAsset.0,
                width: videoAsset.0.pixelWidth,
                height: videoAsset.0.pixelHeight
            ))
        }
        
        reloadMedia()
    }
    
    func removeAsset(url: String) {
        media.removeAll(where: { $0.url.absoluteString == url })
        reloadMedia()
    }
    
    func updateCurrentSelection(to type: PostCreationAttachmentType) {
        currentMediaSelectionType = type
        let selectedMedia = media.compactMap { $0.asset }
        delegate?.openMediaPicker(type, isFirstPick: media.isEmpty, allowedNumber: maxMedia, selectedAssets: selectedMedia)
    }
    
    func reloadMedia() {
        var mediaData: [LMFeedMediaProtocol] = []
        
        currentMediaSelectionType = media.isEmpty ? .none : currentMediaSelectionType
        
        media.forEach { medium in
            if medium.mediaType == .video {
                let timestamp = Date().millisecondsSince1970
                mediaData.append(LMFeedVideoCollectionCell.ContentModel(
                    videoURL: medium.url.absoluteString,
                    isFilePath: medium.url.isFileURL,
                    postID: "-\(timestamp)",
                    width: medium.width,
                    height: medium.height
                ))
            }
        }
        
        delegate?.resetMediaView()
        delegate?.showVideo(video: mediaData)
    }
}

// MARK: Topics Handling
extension LMFeedCreateShortVideoViewModel {
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
            let data: LMFeedTopicView.ContentModel = .init(
                topics: selectedTopics.map({ .init(topic: $0.topicName, topicID: $0.topicID) }),
                isSelectFlow: selectedTopics.isEmpty,
                isEditFlow: !selectedTopics.isEmpty,
                isSepratorShown: true
            )
            
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
