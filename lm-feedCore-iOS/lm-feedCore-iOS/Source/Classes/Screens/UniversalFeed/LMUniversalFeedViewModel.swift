//
//  LMUniversalFeedViewModel.swift
//  likeminds-feed-iOS
//
//  Created by Devansh Mohata on 28/12/23.
//

import LikeMindsFeedUI
import LikeMindsFeed



public class LMUniversalFeedViewModel: LMFeedBaseUniversalFeedViewModel {
    public static func createModule() throws -> LMUniversalFeedScreen {
        guard LMFeedCore.isInitialized else { throw LMFeedError.feedNotInitialized }
        
        let viewController = Components.shared.universalFeedScreen.init()
        let viewModel = LMUniversalFeedViewModel(delegate: viewController)
        
        viewController.viewModel = viewModel
        return viewController
    }
}
