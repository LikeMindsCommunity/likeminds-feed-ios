//
//  LMFeedPostDetailViewModel.swift
//  LikeMindsFeedCore
//
//  Created by Devansh Mohata on 31/07/24.
//


public final class LMFeedPostDetailViewModel: LMFeedBasePostDetailViewModel {
    public static func createModule(
        for postID: String,
        openCommentSection: Bool = false,
        scrollToCommentSection: Bool = false
    ) -> LMFeedPostDetailScreen? {
        guard LMFeedCore.isInitialized else { return nil }
        let viewController = Components.shared.postDetailScreen.init()
        let viewModel: LMFeedPostDetailViewModel = .init(postID: postID, delegate: viewController, openCommentSection: openCommentSection, scrollToCommentSection: scrollToCommentSection)
        
        viewController.viewModel = viewModel
        return viewController
    }
}
