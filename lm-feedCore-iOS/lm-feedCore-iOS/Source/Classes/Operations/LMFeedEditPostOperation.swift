//
//  LMFeedEditPostOperation.swift
//  lm-feedCore-iOS
//
//  Created by Devansh Mohata on 27/01/24.
//

import LikeMindsFeed

final class LMFeedEditPostOperation {
    private init(){}

    static let shared = LMFeedEditPostOperation()
    
    func editPostWithAttachments(postID: String, heading: String?, postCaption: String?, topics: [String], documents: [LMFeedPostDataModel.DocumentAttachment], media: [LMFeedPostDataModel.ImageVideoAttachment], linkAttachment: LMFeedPostDataModel.LinkAttachment?, poll: LMFeedPollDataModel?) {
        let attachments = handleAttachments(documents: documents, media: media, linkAttachment: linkAttachment, poll: poll)
        
        let editPostRequest = EditPostRequest.builder()
            .postId(postID)
            .heading(heading)
            .text(postCaption)
            .attachments(attachments)
            .addTopics(topics)
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
    }
    
    func handleAttachments(documents: [LMFeedPostDataModel.DocumentAttachment], media: [LMFeedPostDataModel.ImageVideoAttachment], linkAttachment: LMFeedPostDataModel.LinkAttachment?, poll: LMFeedPollDataModel?) -> [Attachment] {
        var attachments: [Attachment] = []
        
        media.forEach { medium in
            switch medium.isVideo {
            case true:
                var attachmentMeta = AttachmentMeta.Builder()
                attachmentMeta = attachmentMeta.attachmentUrl(medium.url)
                attachmentMeta = attachmentMeta.size(medium.size)
                attachmentMeta = attachmentMeta.name(medium.name)
                attachmentMeta = attachmentMeta.duration(medium.duration ?? 0)
                
                
                let attachment = Attachment()
                    .attachmentType(.video)
                    .attachmentMeta(attachmentMeta.build())
                
                attachments.append(attachment)
            case false:
                var attachmentMeta = AttachmentMeta.Builder()
                attachmentMeta = attachmentMeta.attachmentUrl(medium.url)
                attachmentMeta = attachmentMeta.size(medium.size)
                attachmentMeta = attachmentMeta.name(medium.name)
                
                let attachment = Attachment()
                    .attachmentType(.image)
                    .attachmentMeta(attachmentMeta.build())
                
                attachments.append(attachment)
            }
        }
        
        documents.forEach { document in
            var attachmentMeta = AttachmentMeta.Builder()
            attachmentMeta = attachmentMeta.attachmentUrl(document.url)
            attachmentMeta = attachmentMeta.size(document.size ?? 0)
            attachmentMeta = attachmentMeta.pageCount(document.pageCount ?? 0)
            attachmentMeta = attachmentMeta.name(document.name)
            attachmentMeta = attachmentMeta .format(document.format ?? ".pdf")
            
            let attachment = Attachment()
                .attachmentType(.doc)
                .attachmentMeta(attachmentMeta.build())
            
            attachments.append(attachment)
        }
        
        
        if let linkAttachment {
            let ogTags = OGTags()
                .image(linkAttachment.previewImage ?? "")
                .title(linkAttachment.title ?? "")
                .description(linkAttachment.description ?? "")
                .url(linkAttachment.url)
            
            var attachmentMeta = AttachmentMeta.Builder()
            attachmentMeta = attachmentMeta.ogTags(ogTags)
            
            let attachment = Attachment()
                .attachmentType(.link)
                .attachmentMeta(attachmentMeta.build())
            
            attachments.append(attachment)
        }
        
        if let poll {
            var attachmentMeta = AttachmentMeta.Builder()
            attachmentMeta = attachmentMeta.entityID(poll.id)
            attachmentMeta = attachmentMeta.title(poll.question)
            attachmentMeta = attachmentMeta.expiryTime(poll.expiryTime)
            attachmentMeta = attachmentMeta.pollOptions(poll.options.map({ $0.option }))
            attachmentMeta = attachmentMeta.multiSelectState(poll.pollSelectType.apiKey)
            attachmentMeta = attachmentMeta.pollType(poll.isInstantPoll ? "instant" : "deferred")
            attachmentMeta = attachmentMeta.multSelectNo(poll.pollSelectCount)
            attachmentMeta = attachmentMeta.isAnonymous(poll.isAnonymous)
            attachmentMeta = attachmentMeta.allowAddOptions(poll.allowAddOptions)
            
            let attachmentRequest = Attachment()
                .attachmentType(.poll)
                .attachmentMeta(attachmentMeta.build())
            
            attachments.append(attachmentRequest)
        }
        
        return attachments
    }
}
