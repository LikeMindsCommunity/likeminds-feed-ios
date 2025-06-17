import LikeMindsFeed
import LikeMindsFeedUI

public protocol LMFeedEditShortVideoViewModelProtocol: LMBaseViewControllerProtocol {
    func setupData(with userData: LMFeedCreatePostHeaderView.ContentModel, text: String)
    func setupMediaPreview(with mediaCells: [LMFeedVideoCollectionCell.ContentModel])
}

public final class LMFeedEditShortVideoViewModel {
    private let dispatchGroup: DispatchGroup
    private let postID: String
    
    private var media: [LMFeedPostDataModel.ImageVideoAttachment]
    private var errorMessage: String
    private var postDetail: LMFeedPostDataModel?
    
    private weak var delegate: LMFeedEditShortVideoViewModelProtocol?
    
    init(postID: String, delegate: LMFeedEditShortVideoViewModelProtocol) {
        self.dispatchGroup = DispatchGroup()
        self.postID = postID
        self.media = []
        self.errorMessage = LMStringConstants.shared.genericErrorMessage
        self.delegate = delegate
    }
    
    public static func createModule(for postID: String) -> LMFeedEditShortVideoScreen? {
        guard LMFeedCore.isInitialized else { return nil }
        
        let viewcontroller = Components.shared.editShortVideoScreen.init()
        let viewmodel = Self.init(postID: postID, delegate: viewcontroller)
        
        viewcontroller.viewmodel = viewmodel
        return viewcontroller
    }
    
    func getInitalData() {
        delegate?.showHideLoaderView(isShow: true)
        getPostDetails()
        
        dispatchGroup.notify(queue: .main) { [weak self] in
            self?.delegate?.showHideLoaderView(isShow: false)
            self?.convertToViewModel()
        }
    }
    
    private func getPostDetails() {
        dispatchGroup.enter()
        
        let request = GetPostRequest
            .builder()
            .postId(postID)
            .page(1)
            .pageSize(10)
            .build()
        
        LMFeedClient.shared.getPost(request) { [weak self] response in
            guard let self else { return }
            
            guard response.success,
                  let data = response.data?.post,
                  let users = response.data?.users else {
                errorMessage = response.errorMessage ?? errorMessage
                dispatchGroup.leave()
                return
            }
            
            let allTopics = response.data?.topics?.compactMap({ $0.value }) ?? []
            let widgets = response.data?.widgets ?? [:]
            
            self.postDetail = .init(post: data, users: users, allTopics: allTopics, widgets: widgets, filteredComments: [:])
            dispatchGroup.leave()
        }
    }
    
    private func convertToViewModel() {
        guard let postDetail else {
            self.delegate?.showError(with: errorMessage, isPopVC: true)
            return
        }
        
        // Filter only video attachments
        media = postDetail.imageVideoAttachment
        
        let headerData: LMFeedCreatePostHeaderView.ContentModel = .init(
            profileImage: postDetail.userDetails.userProfileImage,
            username: postDetail.userDetails.userName
        )
        
        delegate?.setupData(with: headerData, text: postDetail.postContent)
        
        if !media.isEmpty {
            let mediaCells = LMFeedConvertToFeedPost.convertToMediaProtocol(from: media, postID: postDetail.postId)
            let videoCells = mediaCells.compactMap { $0 as? LMFeedVideoCollectionCell.ContentModel }
            delegate?.setupMediaPreview(with: videoCells)
        }
    }
}

// MARK: Update Video
extension LMFeedEditShortVideoViewModel {
    func updateVideo(with text: String) {
       
        
        let attachments = handleAttachments(media: media)
        
        let editPostRequest = EditPostRequest.builder()
            .postId(postID)
            .heading(nil)
            .text(text)
            .attachments(attachments)
            .addTopics([])
            .build()
        
        LMFeedClient.shared.editPost(editPostRequest) { response in
            if response.success,
               let data = response.data?.post,
               let users = response.data?.users,
               
                let post = LMFeedPostDataModel(
                    post: data,
                    users: users,
                    allTopics: response.data?.topics?.compactMap({ $0.value }) ?? [],
                    widgets: response.data?.widgets ?? [:],
                    filteredComments: [:]
                ) {
                NotificationCenter.default.post(name: .LMPostEdited, object: post)
            } else {
                NotificationCenter.default.post(name: .LMPostEditError, object: LMFeedError.postEditFailed(error: response.errorMessage))
            }
        }
        delegate?.popViewController(animated: true)
    }
    
    func handleAttachments(media: [LMFeedPostDataModel.ImageVideoAttachment])-> [Attachment]{
        var attachments: [Attachment] = []
        media.forEach { medium in
            var attachmentMeta = AttachmentMeta.Builder()
            attachmentMeta = attachmentMeta.attachmentUrl(medium.url)
            attachmentMeta = attachmentMeta.size(medium.size)
            attachmentMeta = attachmentMeta.name(medium.name)
            attachmentMeta = attachmentMeta.duration(medium.duration ?? 0)
            
            
            
            let attachment = Attachment()
                .attachmentType(.reel)
                .attachmentMeta(attachmentMeta.build())
            attachments.append(attachment)
        }
        return attachments
    }
}
