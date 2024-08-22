//
//  LMMediaPreviewViewModel.swift
//  LikeMindsFeedCore
//
//  Created by Anurag Tyagi on 24/07/24.
//

import Foundation

import LikeMindsFeedUI
import LikeMindsFeed

public protocol LMMediaViewModelDelegate: AnyObject {
    func showImages(with media: [LMFeedMediaPreviewContentModel], userName: String, date: String)
    func scrollToIndex(index: Int)
}

public final class LMFeedMediaPreviewViewModel {
    
    let data: LMFeedPostContentModel
    var startIndex: Int?
    weak var delegate: LMMediaViewModelDelegate?
    
    init(data: LMFeedPostContentModel, startIndex: Int, delegate: LMMediaViewModelDelegate?) {
        self.data = data
        self.startIndex = startIndex
        self.delegate = delegate
    }
    
    public static func createModule(with data: LMFeedPostContentModel, postID: String, startIndex: Int = 0) throws -> LMFeedMediaPreviewScreen {
        guard LMFeedCore.isInitialized else { throw LMFeedError.feedNotInitialized }
        
        let viewController = LMFeedMediaPreviewScreen()
        let viewModel = Self.init(data: data, startIndex: startIndex, delegate: viewController)
        viewController.viewModel = viewModel
        return viewController
    }
    
    public func showMediaPreview() {
        let viewData: [LMFeedMediaPreviewContentModel] = data.mediaData.compactMap {
            if let mediaData = $0 as? LMFeedImageCollectionCell.ContentModel {
                return .init(mediaURL: mediaData.image, isVideo: false, postID: data.postID, index: startIndex ?? 0, width: mediaData.width, height: mediaData.height)
            } else if let mediaData = $0 as? LMFeedVideoCollectionCell.ContentModel {
                return .init(mediaURL: mediaData.videoURL , isVideo: true, postID: data.postID, index: startIndex ?? 0, width: mediaData.width, height: mediaData.height)
            }
            return nil
        }
        // TODO: Add created at date
        delegate?.showImages(with: viewData, userName: data.headerData.authorName, date: "")
    }
    
    public func scrollToMediaPreview() {
        guard let startIndex else { return }
        delegate?.scrollToIndex(index: startIndex)
        self.startIndex = nil
    }
}
