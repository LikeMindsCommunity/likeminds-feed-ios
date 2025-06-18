import LikeMindsFeed

public final class LMFeedVideoReportViewModel {
    private let reportViewModel: LMFeedReportViewModel
    weak var delegate: LMFeedReportViewModelProtocol?
    
    init(delegate: LMFeedReportViewModelProtocol?, postID: String, commentID: String?, replyCommentID: String?, creatorUUID: String) {
        self.delegate = delegate
        self.reportViewModel = LMFeedReportViewModel(delegate: delegate, postID: postID, commentID: commentID, replyCommentID: replyCommentID, creatorUUID: creatorUUID)
    }
    
    public func fetchReportTags() {
        reportViewModel.fetchReportTags()
    }
    
    public func updateSelectedTag(with id: Int) {
        reportViewModel.updateSelectedTag(with: id)
    }
    
    public func reportContent(reason: String?) {
        guard let userUUID = LocalPreferences.userObj?.sdkClientInfo?.uuid,
        let tagName = reportViewModel.reportTags.first(where: { $0.1 == reportViewModel.selectedTag }) else { return }
        
        let reasonName = reason ?? tagName.0
        
        delegate?.showHideLoaderView(isShow: true, backgroundColor: .clear)
        
        LMFeedPostOperation.shared.reportContent(
            with: reportViewModel.selectedTag,
            reason: reasonName,
            entityID: reportViewModel.entityID,
            entityType: reportViewModel.contentType,
            reporterUUID: userUUID
        ) { [weak self] response in
            guard let self else { return }
            delegate?.showHideLoaderView(isShow: false)
            
            switch response {
            case .success():
                reportViewModel.handleTrackEvent(reason: reasonName)
                
                // Show thank you message instead of alert
                if let videoReportScreen = delegate as? LMFeedVideoReportScreen {
                    videoReportScreen.showThankYouMessage()
                }
                
            case .failure(let error):
                delegate?.showError(with: error.localizedDescription, isPopVC: true)
            }
        }
    }
} 