//
//  LMFeedPostListViewModel.swift
//  LikeMindsFeedCore
//
//  Created by Devansh Mohata on 23/07/24.
//

import Foundation

public final class LMFeedPostListViewModel: LMFeedBasePostListViewModel {
    public static func createModule(with delegate: LMFeedPostListVCFromProtocol?) throws -> LMFeedPostListScreen {
        guard LMFeedCore.isInitialized else { throw LMFeedError.feedNotInitialized }
        
        let viewController = Components.shared.feedListScreen.init()
        let viewModel: LMFeedPostListViewModel = .init(delegate: viewController)
        
        viewController.viewModel = viewModel
        viewController.delegate = delegate
        return viewController
    }
}
