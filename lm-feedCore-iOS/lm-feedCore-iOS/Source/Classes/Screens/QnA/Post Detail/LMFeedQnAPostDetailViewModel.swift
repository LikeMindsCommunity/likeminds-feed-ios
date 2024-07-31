//
//  LMFeedQnAPostDetailViewModel.swift
//  LikeMindsFeedCore
//
//  Created by Devansh Mohata on 31/07/24.
//

import Foundation

public final class LMFeedQnAPostDetailViewModel: LMFeedBasePostDetailViewModel {
    public static func createModule(
        for postID: String,
        openCommentSection: Bool = false,
        scrollToCommentSection: Bool = false
    ) -> LMFeedQnAPostDetailScreen? {
        guard LMFeedCore.isInitialized else { return nil }
        let viewController = Components.shared.qnaPostDetailScreen.init()
        let viewModel: LMFeedPostDetailViewModel = .init(postID: postID, delegate: viewController, openCommentSection: openCommentSection, scrollToCommentSection: scrollToCommentSection)
        
        viewController.viewModel = viewModel
        return viewController
    }
}
