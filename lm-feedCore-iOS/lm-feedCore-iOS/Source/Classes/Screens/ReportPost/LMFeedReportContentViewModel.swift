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
    var isPost: Bool
    var reportTags: [(String, Int)]
    var selectedTag: Int
    let otherTagID: Int
    
    init(delegate: LMFeedReportContentViewModelProtocol?, entityID: String, isPost: Bool) {
        self.delegate = delegate
        self.entityID = entityID
        self.isPost = isPost
        self.reportTags = []
        self.selectedTag = -1
        self.otherTagID = 11
    }
    
    public static func createModule(entityID: String, isPost: Bool) throws -> LMFeedReportContentViewController {
        guard LMFeedMain.isInitialized else { throw LMFeedError.feedNotInitialized }
        let viewcontroller = Components.shared.reportScreen.init()
        let viewmodel = Self.init(delegate: viewcontroller, entityID: entityID, isPost: isPost)
        
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
}
