//
//  LMFeedQnAFeedViewModel.swift
//  LikeMindsFeedCore
//
//  Created by Devansh Mohata on 06/08/24.
//

public class LMFeedQnAFeedViewModel: LMFeedBaseUniversalFeedViewModel {
    public static func createModule() throws -> LMFeedQnAFeedScreen {
        guard LMFeedCore.isInitialized else { throw LMFeedError.feedNotInitialized }
        
        let viewController = Components.shared.qnaUniversalFeed.init()
        let viewModel = LMFeedQnAFeedViewModel(delegate: viewController)
        
        viewController.viewModel = viewModel
        return viewController
    }
}
