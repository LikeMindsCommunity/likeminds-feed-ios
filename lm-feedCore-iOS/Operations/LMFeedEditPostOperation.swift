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
    
    func editPostWithAttachments(postID: String, postCaption: String?, topics: [String], documents: [LMFeedPostDataModel.DocumentAttachment], media: [LMFeedPostDataModel.ImageVideoAttachment], linkAttachment: LMFeedPostDataModel.LinkAttachment?) {
        let attachments = handleAttachments(documents: documents, media: media, linkAttachment: linkAttachment)
        
        let editPostRequest = EditPostRequest.builder()
            .postId(postID)
            .text(postCaption)
            .attachments(attachments)
            .addTopics(topics)
            .build()
        LMFeedClient.shared.editPost(editPostRequest) { response in
            if response.success,
               let data = response.data?.post,
               let users = response.data?.users,
               let post = LMFeedPostDataModel(post: data, users: users, allTopics: []) {
                NotificationCenter.default.post(name: .LMPostEdited, object: post)
            } else {
                NotificationCenter.default.post(name: .LMPostEditError, object: LMFeedError.postEditFailed(error: response.errorMessage))
            }
        }
    }
    
    func handleAttachments(documents: [LMFeedPostDataModel.DocumentAttachment], media: [LMFeedPostDataModel.ImageVideoAttachment], linkAttachment: LMFeedPostDataModel.LinkAttachment?) -> [Attachment] {
        var attachments: [Attachment] = []
        
        media.forEach { medium in
            switch medium.isVideo {
            case true:
                let attachmentMeta = AttachmentMeta()
                    .attachmentUrl(medium.url)
                    .size(medium.size)
                    .name(medium.name)
                    .duration(medium.duration ?? 0)
                
                
                let attachment = Attachment()
                    .attachmentType(.video)
                    .attachmentMeta(attachmentMeta)
                
                attachments.append(attachment)
            case false:
                let attachmentMeta = AttachmentMeta()
                    .attachmentUrl(medium.url)
                    .size(medium.size)
                    .name(medium.name)
                
                let attachment = Attachment()
                    .attachmentType(.image)
                    .attachmentMeta(attachmentMeta)
                
                attachments.append(attachment)
            }
        }
        
        documents.forEach { document in
            let attachmentMeta = AttachmentMeta()
                .attachmentUrl(document.url)
                .size(document.size ?? 0)
                .pageCount(document.pageCount ?? 0)
                .name(document.name)
                .format(document.format ?? ".pdf")
            
            let attachment = Attachment()
                .attachmentType(.image)
                .attachmentMeta(attachmentMeta)
            
            attachments.append(attachment)
        }
        
        
        if let linkAttachment {
            let ogTags = OGTags()
                .image(linkAttachment.previewImage ?? "")
                .title(linkAttachment.title ?? "")
                .description(linkAttachment.description ?? "")
                .url(linkAttachment.url)
            
            let attachmentMeta = AttachmentMeta()
                .ogTags(ogTags)
            
            let attachment = Attachment()
                .attachmentType(.link)
                .attachmentMeta(attachmentMeta)
            
            attachments.append(attachment)
        }
        
        return attachments
    }
}
