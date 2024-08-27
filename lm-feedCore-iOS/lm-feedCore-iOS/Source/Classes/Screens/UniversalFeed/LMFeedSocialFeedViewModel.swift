//
//  LMFeedSocialFeedViewModel.swift
//  likeminds-feed-iOS
//
//  Created by Devansh Mohata on 28/12/23.
//
import LikeMindsFeedUI
import LikeMindsFeed

public class LMFeedSocialFeedViewModel: LMFeedBaseUniversalFeedViewModel {
    public static func createModule() throws -> LMFeedSocialFeedScreen {
        guard LMFeedCore.isInitialized else { throw LMFeedError.feedNotInitialized }
        
        let viewController = Components.shared.universalFeedScreen.init()
        let viewModel = LMFeedSocialFeedViewModel(delegate: viewController)
        
        viewController.viewModel = viewModel
        return viewController
    }
}
