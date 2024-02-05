//
//  LMFeedReportContentViewModel.swift
//  lm-feedCore-iOS
//
//  Created by Devansh Mohata on 31/01/24.
//

import LikeMindsFeed

public final class LMFeedReportContentViewModel {
    weak var delegate: LMFeedReportContentViewModelProtocol?
    var entityID: String
    var contentType: ReportEntityType
    var reportTags: [(String, Int)]
    var selectedTag: Int
    let otherTagID: Int
    
    init(delegate: LMFeedReportContentViewModelProtocol?, entityID: String, contentType: Bool?) {
        self.delegate = delegate
        self.entityID = entityID
        self.reportTags = []
        self.selectedTag = -1
        self.otherTagID = 11
        
        if contentType == true {
            self.contentType = .post
        } else if contentType == false {
            self.contentType = .comment
        } else {
            self.contentType = .reply
        }
    }
    
    public static func createModule(entityID: String, isPost: Bool?) throws -> LMFeedReportContentViewController {
        guard LMFeedMain.isInitialized else { throw LMFeedError.feedNotInitialized }
        let viewcontroller = Components.shared.reportScreen.init()
        let viewmodel = Self.init(delegate: viewcontroller, entityID: entityID, contentType: isPost)
        
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
        
        delegate?.showHideLoaderView(isShow: true)
        
        LMFeedPostOperation.shared.reportContent(
            with: selectedTag,
            reason: reason ?? tagName.0,
            entityID: entityID,
            entityType: contentType,
            reporterUUID: userUUID
        ) { [weak self] response in
            guard let self else { return }
            delegate?.showHideLoaderView(isShow: false)
            
            switch response {
            case .success():
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
}
