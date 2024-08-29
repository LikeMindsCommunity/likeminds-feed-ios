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
         poll,
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
        case .poll:
            return "poll"
        }
    }
}

final class LMFeedCreatePostOperation {
    struct LMAWSRequestModel {
        let url: URL
        let data: Data
        let fileName: String
        let awsFilePath: String
        let contentType: PostCreationAttachmentType
        var awsURL: String?
        var width: Int?
        var height: Int?
    }
    
    private init(){}

    static let shared = LMFeedCreatePostOperation()
    var attachmentList: [LMAWSRequestModel] = []
    let dispatchGroup = DispatchGroup()
    
    
    func createPost(with content: String, heading: String? = nil, topics: [String], files: [LMAWSRequestModel], linkPreview: LMFeedPostDataModel.LinkAttachment?, poll: LMFeedCreatePollDataModel?) {
        postMessageForPostCreationStart(files.first)
        
        if let linkPreview {
            let attachmentMeta = AttachmentMeta()
                .ogTags(.init()
                    .image(linkPreview.previewImage ?? "")
                    .title(linkPreview.title ?? "")
                    .description(linkPreview.description ?? "")
                    .url(linkPreview.url))
            
            let attachmentRequest = Attachment()
                .attachmentType(.link)
                .attachmentMeta(attachmentMeta)
            
            createPost(with: content, heading: heading, attachments: [attachmentRequest], topics: topics)
        } else if let poll {
            let attachmentMeta = AttachmentMeta()
                .title(poll.pollQuestion)
                .expiryTime(Int(poll.expiryTime.timeIntervalSince1970 * 1000))
                .pollOptions(poll.pollOptions)
                .multiSelectState(poll.selectState.apiKey)
                .pollType(poll.isInstantPoll ? "instant" : "deferred")
                .multSelectNo(poll.selectStateCount)
                .isAnonymous(poll.isAnonymous)
                .allowAddOptions(poll.allowAddOptions)
            
            let attachmentRequest = Attachment()
                .attachmentType(.poll)
                .attachmentMeta(attachmentMeta)
            
            createPost(with: content, heading: heading, attachments: [attachmentRequest], topics: topics)
        } else if !files.isEmpty {
            var tempFiles = files
            
            for i in 0..<files.count {
                dispatchGroup.enter()
                let file = files[i]
                LMAWSManager.shared.uploadfile(fileData: file.data, fileName: "\(file.awsFilePath)\(file.fileName)", contenType: file.contentType.contentType, progress: nil) { [weak self] response, error in
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
                    case .none, .poll:
                        break
                    }
                }
                
                guard tempFiles.count == attachments.count else {
                    postMessageForCompleteCreatePost(with: "Files Upload Error!")
                    return
                }
                self.createPost(with: content, heading: heading, attachments: attachments, topics: topics)
            }
        } else {
            createPost(with: content, heading: heading, attachments: [], topics: topics)
        }
    }
    
    private func createPost(with content: String, heading: String?, attachments: [Attachment], topics: [String]) {
        let addPostRequest = AddPostRequest.builder()
            .heading(heading)
            .text(content)
            .attachments(attachments)
            .addTopics(topics)
            .build()
        
        LMFeedClient.shared.addPost(addPostRequest) { [weak self] response in
            guard response.success else {
                self?.postMessageForCompleteCreatePost(with: response.errorMessage)
                return
            }
            NotificationCenter.default.post(name: .LMPostCreated, object: nil)
        }
    }
    
    func imageAttachmentData(attachment: LMAWSRequestModel) -> Attachment? {
        guard let awsURL = attachment.awsURL,
              !awsURL.isEmpty else { return nil }
        
        var size: Int?
        
        if let attr = try? FileManager.default.attributesOfItem(atPath: attachment.url.absoluteString) {
            size = attr[.size] as? Int
        }
        
        var attachmentMeta = AttachmentMeta()
            .attachmentUrl(awsURL)
            .size(size ?? 0)
            .name(attachment.fileName)
        
        if let width = attachment.width {
            attachmentMeta = attachmentMeta.width(width)
        }
        
        if let height = attachment.height {
            attachmentMeta = attachmentMeta.height(height)
        }
        
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
        
        var attachmentMeta = AttachmentMeta()
            .attachmentUrl(awsURL)
            .size(size ?? 0)
            .name(attachment.fileName)
            .duration(Int(durationTime))
        
        if let width = attachment.width {
            attachmentMeta = attachmentMeta.width(width)
        }
        
        if let height = attachment.height {
            attachmentMeta = attachmentMeta.height(height)
        }
        
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
            NotificationCenter.default.post(name: .LMPostCreateError, object: LMFeedError.postCreationFailed(error: error))
        }
    }
    
    func postMessageForPostCreationStart(_ file: LMAWSRequestModel?) {
        var image: UIImage?
        
        if let file {
            switch file.contentType {
            case .image:
                do {
                    let data = try Data(contentsOf: file.url)
                    image = UIImage(data: data)
                } catch { }
            case .video:
                do {
                    let asset = AVAsset(url: file.url)
                    let imgGenerator = AVAssetImageGenerator(asset: asset)
                    imgGenerator.appliesPreferredTrackTransform = true
                    let cgImage = try imgGenerator.copyCGImage(at: .zero, actualTime: nil)
                    image = UIImage(cgImage: cgImage)
                } catch { }
            case .document:
                if let pdf = PDFDocument(url: file.url),
                   let pdfPage = pdf.page(at: 0) {
                    let pdfPageSize = pdfPage.bounds(for: .mediaBox)
                    let renderer = UIGraphicsImageRenderer(size: pdfPageSize.size)
                    
                    image = renderer.image { ctx in
                        UIColor.white.set()
                        ctx.fill(pdfPageSize)
                        ctx.cgContext.translateBy(x: 0.0, y: pdfPageSize.size.height)
                        ctx.cgContext.scaleBy(x: 1.0, y: -1.0)
                        
                        pdfPage.draw(with: .mediaBox, to: ctx.cgContext)
                    }
                }
            case .none, .poll:
                break
            }
        }
        
        NotificationCenter.default.post(name: .LMPostCreationStarted, object: image)
    }
}
