//
//  LMFeedCreatePostOperation.swift
//  lm-feedCore-iOS
//
//  Created by Devansh Mohata on 23/01/24.
//

import LikeMindsFeed
import AVFoundation
import PDFKit

public enum PostCreationAttachmentType {
    case image,
         video,
         document,
         none
    
    var contentType: String {
        switch self {
        case .image:
            return "image"
        case .video:
            return "video"
        case .document:
            return "document"
        case .none:
            return ""
        }
    }
}

final class LMFeedCreatePostOperation {
    struct LMAWSRequestModel {
        let url: URL
        let fileName: String
        let awsFilePath: String
        let contentType: PostCreationAttachmentType
        var awsURL: String?
    }
    
    private init(){}

    static let shared = LMFeedCreatePostOperation()
    var attachmentList: [LMAWSRequestModel] = []
    let dispatchGroup = DispatchGroup()
    
    
    func createPost(with content: String, topics: [String], files: [LMAWSRequestModel], linkPreview: LMFeedLinkPreviewDataModel?) {
        if let linkPreview {
            let attachmentMeta = AttachmentMeta()
                .ogTags(.init()
                    .image(linkPreview.imagePreview ?? "")
                    .title(linkPreview.title ?? "")
                    .description(linkPreview.description ?? "")
                    .url(linkPreview.url))
            
            let attachmentRequest = Attachment()
                .attachmentType(.link)
                .attachmentMeta(attachmentMeta)
            
            createPost(with: content, attachments: [attachmentRequest], topics: topics)
        } else if !files.isEmpty {
            var tempFiles = files
            
            for i in 0..<files.count {
                dispatchGroup.enter()
                let file = files[i]
                LMAWSManager.shared.uploadfile(fileUrl: file.url, fileName: "\(file.awsFilePath)\(file.fileName)", contenType: file.contentType.contentType, progress: nil) { [weak self] response, error in
                    if error == nil {
                        tempFiles[i].awsURL = response
                    }
                    self?.dispatchGroup.leave()
                }
            }
                        
            dispatchGroup.notify(queue: .global(qos: .background)) { [weak self] in
                guard let self else { return }
                var attachments: [Attachment] = []
                
                for file in tempFiles {
                    switch file.contentType {
                    case .image:
                        if let attachment = imageAttachmentData(attachment: file) {
                            attachments.append(attachment)
                        }
                    case .video:
                        if let attachment = videoAttachmentData(attachment: file) {
                            attachments.append(attachment)
                        }
                    case .document:
                        if let attachment = fileAttachmentData(attachment: file) {
                            attachments.append(attachment)
                        }
                    case .none:
                        break
                    }
                }
                
                guard tempFiles.count == attachments.count else { return }
                self.createPost(with: content, attachments: attachments, topics: topics)
            }
        } else {
            createPost(with: content, attachments: [], topics: topics)
        }
    }
    
    private func createPost(with content: String, attachments: [Attachment], topics: [String]) {
        let addPostRequest = AddPostRequest.builder()
            .text(content)
            .attachments(attachments)
            .addTopics(topics)
            .build()
        
        LMFeedClient.shared.addPost(addPostRequest) { [weak self] response in
            guard response.success else {
                self?.postMessageForCompleteCreatePost(with: response.errorMessage)
                return
            }
            print("Post Creation Successful")
        }
    }
    
    func imageAttachmentData(attachment: LMAWSRequestModel) -> Attachment? {
        guard let awsURL = attachment.awsURL,
              !awsURL.isEmpty else { return nil }
        
        var size: Int?
        
        if let attr = try? FileManager.default.attributesOfItem(atPath: attachment.url.absoluteString) {
            size = attr[.size] as? Int
        }
        
        let attachmentMeta = AttachmentMeta()
            .attachmentUrl(awsURL)
            .size(size ?? 0)
            .name(attachment.fileName)
        
        let attachmentRequest = Attachment()
            .attachmentType(.image)
            .attachmentMeta(attachmentMeta)
        return attachmentRequest
    }
    
    func videoAttachmentData(attachment: LMAWSRequestModel) -> Attachment? {
        guard let awsURL = attachment.awsURL,
              !awsURL.isEmpty else { return nil }
        
        var size: Int?
        if let attr = try? FileManager.default.attributesOfItem(atPath: attachment.url.absoluteString) {
            size = attr[.size] as? Int
        }
        
        let asset = AVAsset(url: attachment.url)
        let duration = asset.duration
        let durationTime = CMTimeGetSeconds(duration)
        
        let attachmentMeta = AttachmentMeta()
            .attachmentUrl(awsURL)
            .size(size ?? 0)
            .name(attachment.fileName)
            .duration(Int(durationTime))
        
        let attachmentRequest = Attachment()
            .attachmentType(.video)
            .attachmentMeta(attachmentMeta)
        
        return attachmentRequest
    }
    
    func fileAttachmentData(attachment: LMAWSRequestModel) -> Attachment? {
        guard let awsURL = attachment.awsURL,
              !awsURL.isEmpty else { return nil }
        
        _ = attachment.url.startAccessingSecurityScopedResource()
        var size: Int?
        if let attr = try? FileManager.default.attributesOfItem(atPath: attachment.url.path) {
            size = attr[.size] as? Int
        }
        
        var pageCount: Int?
        if let pdf = PDFDocument(url: attachment.url) {
            pageCount = pdf.pageCount
        }
        attachment.url.stopAccessingSecurityScopedResource()
        
        let attachmentMeta = AttachmentMeta()
            .attachmentUrl(awsURL)
            .size(size ?? 0)
            .name(attachment.fileName)
            .pageCount(pageCount ?? 0)
            .format("pdf")
        
        let attachmentRequest = Attachment()
            .attachmentType(.doc)
            .attachmentMeta(attachmentMeta)
        
        return attachmentRequest
    }
    
    func postMessageForCompleteCreatePost(with error: String?) {
        DispatchQueue.main.async {
            print("Something went wrong")
//            NotificationCenter.default.post(name: .postCreationCompleted, object: error)
        }
    }
}
