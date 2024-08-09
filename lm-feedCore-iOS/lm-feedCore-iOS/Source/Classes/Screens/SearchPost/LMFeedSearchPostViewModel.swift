//
//  LMFeedSearchPostViewModel.swift
//  LikeMindsFeedCore
//
//  Created by Devansh Mohata on 29/06/24.
//

public class LMFeedSearchPostViewModel: LMFeedBaseSearchPostViewModel {
    public static func createModule() throws -> LMFeedSearchPostScreen {
        guard LMFeedCore.isInitialized else { throw LMFeedError.feedNotInitialized }
        
        let viewcontroller = Components.shared.searchPostScreen.init()
        let viewModel = LMFeedSearchPostViewModel(delegate: viewcontroller)
        
        viewcontroller.viewModel = viewModel
        return viewcontroller
    }
}
