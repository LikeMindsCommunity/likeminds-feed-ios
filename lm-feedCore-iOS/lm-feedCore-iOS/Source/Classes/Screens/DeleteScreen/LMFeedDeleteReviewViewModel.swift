//
//  LMFeedDeleteReviewViewModel.swift
//  lm-feedCore-iOS
//
//  Created by Devansh Mohata on 30/01/24.
//

import LikeMindsFeed

public final class LMFeedDeleteReviewViewModel {
    weak var delegate: LMFeedDeleteReviewViewModelProtocol?
    var postID: String
    var commentID: String?
    
    private let popupTitle = "Delete %@?"
    private let popupMessage = "Are you sure you want to delete this %@? This action cannot be reversed."
    
    init(delegate: LMFeedDeleteReviewViewModelProtocol? = nil, postID: String, commentID: String?) {
        self.delegate = delegate
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
            
            var tags: [String] = []
            
            if response.success,
               let apiTags = response.data?.reportTags {
                tags = apiTags.compactMap { tag in
                    guard let name = tag.name else { return nil }
                    return (name)
                }
            }
            
            if tags.isEmpty || !response.success {
                delegate?.showError(with: response.errorMessage ?? LMStringConstants.shared.genericErrorMessage, isPopVC: true)
                return
            }
            
            processTags(tags: tags)
        }
    }
    
    func processTags(tags: [String]) {
        delegate?.showTags(
            with: tags,
            title: String(format: popupTitle, commentID != nil ? "Comment" : "Post"),
            subtitle: String(format: popupMessage, commentID != nil ? "Comment" : "Post")
        )
    }
    
    func updateSelectedReason(with reason: String) {
        delegate?.setNewReason(with: reason, isShowTextField: reason.lowercased() == "others")
    }
    
    func initateDeleteAction(with reason: String) {
        if commentID != nil {
            deleteComment(with: reason)
        } else {
            deletePost(with: reason)
        }
    }
    
    func deletePost(with reason: String) {
        LMFeedPostOperation.shared.deletePost(postId: postID, reason: reason) { [weak self] response in
            guard let self else { return }
            switch response {
            case .success():
                NotificationCenter.default.post(name: .LMPostDeleted, object: postID)
                delegate?.popViewController(animated: false)
            case .failure(let error):
                delegate?.showError(with: error.localizedDescription, isPopVC: true)
            }
        }
    }
    
    func deleteComment(with reason: String) {
        guard let commentID else { return }
        LMFeedPostOperation.shared.deleteComment(for: postID, having: commentID, reason: reason) { [weak self] response in
            guard let self else { return }
            switch response {
            case .success():
                NotificationCenter.default.post(name: .LMCommentDeleted, object: (postID, commentID))
                delegate?.popViewController(animated: false)
            case .failure(let error):
                delegate?.showError(with: error.localizedDescription, isPopVC: true)
            }
        }
    }
}
