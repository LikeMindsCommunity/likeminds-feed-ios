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
    
    let data: LMFeedPostDataModel
    var startIndex: Int?
    weak var delegate: LMMediaViewModelDelegate?
    
    init(data: LMFeedPostDataModel, startIndex: Int, delegate: LMMediaViewModelDelegate?) {
        self.data = data
        self.startIndex = startIndex
        self.delegate = delegate
    }
    
    public static func createModule(with data: LMFeedPostDataModel, startIndex: Int = 0) -> LMFeedMediaPreviewScreen? {
        let viewController = LMFeedMediaPreviewScreen()
        let viewModel = Self.init(data: data, startIndex: startIndex, delegate: viewController)
        viewController.viewModel = viewModel
        return viewController
    }
    
    public func showMediaPreview() {
        let viewData: [LMFeedMediaPreviewContentModel] = data.imageVideoAttachment.map {
            .init(mediaURL: $0.url, isVideo: $0.isVideo)
        }
        
        delegate?.showImages(with: viewData, userName: data.userDetails.userName, date: data.createTime)
    }
    
    public func scrollToMediaPreview() {
        guard let startIndex else { return }
        delegate?.scrollToIndex(index: startIndex)
        self.startIndex = nil
    }
}
