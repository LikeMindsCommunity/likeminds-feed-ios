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
    
    init(delegate: LMFeedCreatePostViewModelProtocol?) {
        currentMediaSelectionType = .none
        media = []
        self.delegate = delegate
    }
    
    public static func createModule() -> LMFeedCreatePostViewController {
        let viewcontroller = Components.shared.createPostScreen.init()
        let viewModel = LMFeedCreatePostViewModel(delegate: viewcontroller)
        
        viewcontroller.viewModel = viewModel
        return viewcontroller
    }
    
    public func handleAssets(asset: URL, type: PHAssetMediaType) {
        if type == .image {
            media.append(.init(url: asset, mediaType: .image))
        } else if type == .video {
            media.append(.init(url: asset, mediaType: .video))
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
