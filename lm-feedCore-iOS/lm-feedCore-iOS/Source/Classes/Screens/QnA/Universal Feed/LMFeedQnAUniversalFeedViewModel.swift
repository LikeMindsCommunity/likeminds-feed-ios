//
//  LMFeedQnAUniversalFeedViewModel.swift
//  LikeMindsFeedCore
//
//  Created by Devansh Mohata on 06/08/24.
//

public class LMFeedQnAUniversalFeedViewModel: LMFeedBaseUniversalFeedViewModel {
    public static func createModule() throws -> LMFeedQnAUniversalFeed {
        guard LMFeedCore.isInitialized else { throw LMFeedError.feedNotInitialized }
        
        let viewController = Components.shared.qnaUniversalFeed.init()
        let viewModel = LMFeedQnAUniversalFeedViewModel(delegate: viewController)
        
        viewController.viewModel = viewModel
        return viewController
    }
}
