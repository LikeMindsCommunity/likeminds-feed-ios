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
    public struct DataModel {
        let userName: String
        let date: String
        let media: [MediaModel]

        public init(userName: String, senDate: String, media: [MediaModel]) {
            self.userName = userName
            self.date = senDate
            self.media = media
        }
        
        public struct MediaModel {
            let mediaType: MediaType
            let thumbnailURL: String?
            let mediaURL: String
            
            public init(mediaType: MediaType, thumbnailURL: String?, mediaURL: String) {
                self.mediaType = mediaType
                self.thumbnailURL = thumbnailURL
                self.mediaURL = mediaURL
            }
        }
    }
    
    let data: DataModel
    var startIndex: Int?
    weak var delegate: LMMediaViewModelDelegate?
    
    init(data: DataModel, startIndex: Int, delegate: LMMediaViewModelDelegate?) {
        self.data = data
        self.startIndex = startIndex
        self.delegate = delegate
    }
    
    public static func createModule(with data: DataModel, startIndex: Int = 0) -> LMFeedMediaPreviewScreen {
        let viewController = LMFeedMediaPreviewScreen()
        let viewModel = Self.init(data: data, startIndex: startIndex, delegate: viewController)
        
        viewController.viewModel = viewModel
        return viewController
    }
    
    public func showMediaPreview() {
        let viewData: [LMFeedMediaPreviewContentModel] = data.media.map {
            .init(mediaURL: $0.mediaURL, thumbnailURL: $0.thumbnailURL, isVideo: $0.mediaType == .video)
        }
        
        delegate?.showImages(with: viewData, userName: data.userName, date: data.date)
    }
    
    public func scrollToMediaPreview() {
        guard let startIndex else { return }
        delegate?.scrollToIndex(index: startIndex)
        self.startIndex = nil
    }
}
