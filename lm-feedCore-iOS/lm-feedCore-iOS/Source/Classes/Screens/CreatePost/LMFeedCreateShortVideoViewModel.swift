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
    private var selectedTopics: [LMFeedTopicDataModel]
    
    init(delegate: LMFeedCreateShortVideoViewModelProtocol?) {
        currentMediaSelectionType = .none
        media = []
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
        var attachments: [LMFeedCreatePostOperation.LMAWSRequestModel] = []
        let filePath = "files/post/\(LocalPreferences.userObj?.clientUUID ?? "user")/\(Int(Date().timeIntervalSince1970))/"
        
        media.forEach { medium in
            if medium.url.getFileSize() > LMNumbersConstant.shared.maxFileSizeInBytes {
                delegate?.showError(with: String(format: LMStringConstants.shared.maxUploadSizeErrorMessage, LMNumbersConstant.shared.maxFileSizeInMB), isPopVC: false)
                return
            }
            
            attachments.append(.init(url: medium.url, data: medium.data, fileName: medium.url.lastPathComponent, awsFilePath: filePath, contentType: medium.mediaType, width: medium.width, height: medium.height))
        }
        
        LMFeedCreatePostOperation.shared.createPost(with: caption, heading: nil, topics: selectedTopics.map({ $0.topicID }), files: attachments, linkPreview: nil, poll: nil, meta: nil)
        delegate?.popViewController(animated: true)
    }
}

// MARK: Assets Handling
public extension LMFeedCreateShortVideoViewModel {
    
    func handleAssets(assets: [(PHAsset, URL, Data)]) {
        media.removeAll(keepingCapacity: true)
        
        // Only take the first video asset
        if let videoAsset = assets.first(where: { $0.0.mediaType == .video }) {
            media.append(.init(
                url: videoAsset.1,
                data: videoAsset.2,
                mediaType: .reel,
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
    
    
    func reloadMedia() {
        var mediaData: [LMFeedMediaProtocol] = []
        
        currentMediaSelectionType = media.isEmpty ? .none : currentMediaSelectionType
        
        media.forEach { medium in
            if medium.mediaType == .reel {
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
