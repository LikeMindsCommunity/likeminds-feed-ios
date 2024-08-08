//
//  LMFeedQnASearchPostViewModel.swift
//  LikeMindsFeedCore
//
//  Created by Devansh Mohata on 06/08/24.
//

public class LMFeedQnASearchPostViewModel: LMFeedBaseSearchPostViewModel {
    public static func createModule() throws -> LMFeedQnASearchPostScreen {
        guard LMFeedCore.isInitialized else { throw LMFeedError.feedNotInitialized }
        
        let viewcontroller = Components.shared.qnaSearchPostScreen.init()
        let viewModel = LMFeedQnASearchPostViewModel(delegate: viewcontroller)
        viewModel.searchType = "heading"
        
        viewcontroller.viewModel = viewModel
        return viewcontroller
    }
}
