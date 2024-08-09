//
//  LMFeedPostListViewModel.swift
//  likeminds-feed-iOS
//
//  Created by Devansh Mohata on 02/01/24.
//

import LikeMindsFeedUI
import LikeMindsFeed


public class LMFeedPostListViewModel: LMFeedBasePostListViewModel {
    public static func createModule(with delegate: LMFeedPostListVCFromProtocol?) throws -> LMFeedPostListScreen {
        guard LMFeedCore.isInitialized else { throw LMFeedError.feedNotInitialized }
        
        let viewController = Components.shared.feedListScreen.init()
        let viewModel = LMFeedPostListViewModel.init(delegate: viewController)
        
        viewController.viewModel = viewModel
        viewController.delegate = delegate
        
        return viewController
    }
}
