//
//  LMFeedQnAPostListViewModel.swift
//  LikeMindsFeedCore
//
//  Created by Devansh Mohata on 23/07/24.
//

import Foundation

public class LMFeedQnAPostListViewModel: LMFeedBasePostListViewModel {
    public static func createModule(with delegate: LMFeedPostListVCFromProtocol?) throws -> LMFeedQnAPostListScreen {
        guard LMFeedCore.isInitialized else { throw LMFeedError.feedNotInitialized }
        
        let viewController = Components.shared.qnaPostListScreen.init()
        let viewModel: LMFeedQnAPostListViewModel = .init(delegate: viewController)
        
        viewController.viewModel = viewModel
        viewController.delegate = delegate
        return viewController
    }
}
