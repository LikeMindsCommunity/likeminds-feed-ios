//
//  LMFeedReportContentViewModel.swift
//  lm-feedCore-iOS
//
//  Created by Devansh Mohata on 31/01/24.
//

import LikeMindsFeed

public final class LMFeedReportContentViewModel {
    weak var delegate: LMFeedReportContentViewModelProtocol?
    let postID: String
    let commentID: String?
    let replyCommentID: String?
    let contentType: ReportEntityType
    let creatorUUID: String
    var reportTags: [(String, Int)]
    var selectedTag: Int
    let otherTagID: Int
    
    var entityID: String {
        replyCommentID ?? commentID ?? postID
    }
    
    init(delegate: LMFeedReportContentViewModelProtocol?, postID: String, commentID: String?, replyCommentID: String?, creatorUUID: String) {
        self.delegate = delegate
        self.reportTags = []
        self.selectedTag = -1
        self.otherTagID = 11
        
        self.postID = postID
        self.commentID = commentID
        self.replyCommentID = replyCommentID
        self.creatorUUID = creatorUUID
        
        if replyCommentID != nil {
            self.contentType = .reply
        } else if commentID != nil {
            self.contentType = .comment
        } else {
            self.contentType = .post
        }
    }
    
    public static func createModule(creatorUUID: String, postID: String, commentID: String? = nil, replyCommentID: String? = nil) throws -> LMFeedReportContentViewController {
        guard LMFeedCore.isInitialized else { throw LMFeedError.feedNotInitialized }
        let viewcontroller = Components.shared.reportScreen.init()
        let viewmodel = Self.init(delegate: viewcontroller, postID: postID, commentID: commentID, replyCommentID: replyCommentID, creatorUUID: creatorUUID)
        
        viewcontroller.viewmodel = viewmodel
        return viewcontroller
    }
    
    func fetchReportTags() {
        delegate?.showHideLoaderView(isShow: true)
        
        let request = GetReportTagRequest.builder()
            .type(3)
            .build()
        
        LMFeedClient.shared.getReportTags(request) { [weak self] response in
            guard let self else { return }
            delegate?.showHideLoaderView(isShow: false)
            
            var tempTags: [(String, Int)] = []
            
            if response.success,
               let apiTags = response.data?.reportTags {
                tempTags = apiTags.compactMap { tagger -> (String, Int)? in
                    if let tagID = tagger.id,
                       let name = tagger.name {
                        return (name, tagID)
                    }
                    return nil
                }
            }
            
            if tempTags.isEmpty {
                delegate?.showError(with: response.errorMessage ?? LMStringConstants.shared.genericErrorMessage, isPopVC: true)
                return
            }
            
            reportTags = tempTags
            delegate?.updateView(with: reportTags, selectedTag: selectedTag, showTextView: selectedTag == otherTagID)
        }
    }
    
    func updateSelectedTag(with id: Int) {
        selectedTag = id
        delegate?.updateView(with: reportTags, selectedTag: selectedTag, showTextView: selectedTag == otherTagID)
    }
    
    func reportContent(reason: String?) {
        guard let userUUID = LocalPreferences.userObj?.sdkClientInfo?.uuid,
        let tagName = reportTags.first(where: { $0.1 == selectedTag }) else { return }
        
        let reasonName = reason ?? tagName.0
        
        delegate?.showHideLoaderView(isShow: true, backgroundColor: .clear)
        
        LMFeedPostOperation.shared.reportContent(
            with: selectedTag,
            reason: reasonName,
            entityID: entityID,
            entityType: contentType,
            reporterUUID: userUUID
        ) { [weak self] response in
            guard let self else { return }
            delegate?.showHideLoaderView(isShow: false)
            
            switch response {
            case .success():
                handleTrackEvent(reason: reasonName)
                
                let contentTitle = contentType == .post ? "Post" : "Comment"
                let title = "\(contentTitle) is reported for review"
                let message = "Our team will look into your feedback and will take appropriate action on this \(contentTitle)"
                
                let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
                    self?.delegate?.popViewController(animated: true)
                })
                
                delegate?.presentAlert(with: alert, animated: true)
            case .failure(let error):
                delegate?.showError(with: error.localizedDescription, isPopVC: true)
            }
        }
    }
    
    func handleTrackEvent(reason: String) {
        switch contentType {
        case .post:
            LMFeedCore.analytics?.trackEvent(for: .postReported, eventProperties: [
                "created_by_id": creatorUUID,
                "post_id": entityID,
                "report_reason": reason,
                "post_type": "text"
            ])
        case .comment:
            LMFeedCore.analytics?.trackEvent(for: .commentReported, eventProperties: [
                "post_id": postID,
                "user_id": creatorUUID,
                "comment_id": entityID,
                "reason": reason
            ])
        case .reply:
            LMFeedCore.analytics?.trackEvent(for: .commentReplyReported, eventProperties: [
                "post_id": postID,
                "user_id": creatorUUID,
                "comment_id": commentID ?? "",
                "comment_reply_id": entityID,
                "reason": reason
            ])
        default:
            break
        }
    }
}
