//
//  LMFeedDeleteReviewViewModel.swift
//  lm-feedCore-iOS
//
//  Created by Devansh Mohata on 30/01/24.
//

import LikeMindsFeed

public final class LMFeedDeleteReviewViewModel {
    weak var delegate: LMFeedDeleteReviewViewModelProtocol?
    var tags: [(name: String, id: Int)] = []
    var postID: String
    var commentID: String?
    
    private let popupTitle = "Delete %@?"
    private let popupMessage = "Are you sure you want to delete this %@? This action cannot be reversed."
    
    init(delegate: LMFeedDeleteReviewViewModelProtocol? = nil, postID: String, commentID: String?) {
        self.delegate = delegate
        self.tags = []
        self.postID = postID
        self.commentID = commentID
    }
    
    public static func createModule(postID: String, commentID: String? = nil) -> LMFeedDeleteReviewScreen? {
        guard LMFeedMain.isInitialized else { return nil }
        let viewcontroller = Components.shared.deleteReviewScreen.init()
        let viewmodel = Self.init(delegate: viewcontroller, postID: postID, commentID: commentID)
        
        viewcontroller.viewmodel = viewmodel
        return viewcontroller
    }
    
    func fetchReportTags(type: Int) {
        let request = GetReportTagRequest.builder()
            .type(type)
            .build()
        LMFeedClient.shared.getReportTags(request) { [weak self] response in
            guard let self else { return }
            
            if response.success,
               let apiTags = response.data?.reportTags {
                tags = apiTags.compactMap { tag -> (String, Int)? in
                    guard let id = tag.id,
                          let name = tag.name else { return nil }
                    return (name, id)
                }
            }
            
            if !tags.isEmpty || !response.success {
                delegate?.showError(with: response.errorMessage ?? LMStringConstants.shared.genericErrorMessage, isPopVC: true)
                return
            }
            
            processTags()
        }
    }
    
    func processTags() {
        delegate?.showTags(
            with: tags.map({ $0.name }),
            title: String(format: popupTitle, commentID != nil ? "Comment" : "Post"),
            subtitle: String(format: popupMessage, commentID != nil ? "Comment" : "Post")
        )
    }
    
    func updateSelectedReason(with reason: String) {
        delegate?.setNewReason(with: reason, isShowTextField: reason.lowercased() == "others")
    }
}
