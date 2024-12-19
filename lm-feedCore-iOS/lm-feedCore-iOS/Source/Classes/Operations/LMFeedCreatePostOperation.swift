//
//  LMFeedCreatePostOperation.swift
//  lm-feedCore-iOS
//
//  Created by Devansh Mohata on 23/01/24.
//

import AVFoundation
import LikeMindsFeed
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

    private init() {}

    static let shared = LMFeedCreatePostOperation()
    var attachmentList: [LMAWSRequestModel] = []
    let dispatchGroup = DispatchGroup()

    func createPost(
        with content: String, heading: String? = nil, topics: [String],
        files: [LMAWSRequestModel],
        linkPreview: LMFeedPostDataModel.LinkAttachment?,
        poll: LMFeedCreatePollDataModel?,
        meta: [String: Any]? = nil
    ) {
        postMessageForPostCreationStart(files.first)

        // Var to store custom widget attachment
        var customWidgetAttachment: Attachment?

        // If meta is provided, create a Attachment of type .widget
        // and store it in a variable to be used for createPost() method
        if meta != nil {
            var customWidgetAttachmentMetaBuilder = AttachmentMeta.Builder()

            // Create attachment meta using the given meta object
            customWidgetAttachmentMetaBuilder =
                customWidgetAttachmentMetaBuilder.meta(meta)

            // Create an attachment of type .widget
            customWidgetAttachment = Attachment().attachmentType(.widget)
                .attachmentMeta(customWidgetAttachmentMetaBuilder.build())
        }

        if let linkPreview {

            var attachmentMetaBuilder = AttachmentMeta.Builder()

            attachmentMetaBuilder =
                attachmentMetaBuilder
                .ogTags(
                    .init()
                        .image(linkPreview.previewImage ?? "")
                        .title(linkPreview.title ?? "")
                        .description(linkPreview.description ?? "")
                        .url(linkPreview.url))

            let attachmentRequest = Attachment()
                .attachmentType(.link)
                .attachmentMeta(attachmentMetaBuilder.build())

            // Store list of attachments
            var attachmentList = [attachmentRequest]

            // If custom widget is provided,
            // add the earlier created custom widget attachment into
            // the attachments list
            if let customWidgetAttachment {
                attachmentList.append(customWidgetAttachment)
            }

            createPost(
                with: content, heading: heading,
                attachments: attachmentList, topics: topics)

        } else if let poll {

            var attachmentMetaBuilder = AttachmentMeta.Builder()

            attachmentMetaBuilder = attachmentMetaBuilder.title(
                poll.pollQuestion)
            attachmentMetaBuilder = attachmentMetaBuilder.expiryTime(
                Int(poll.expiryTime.timeIntervalSince1970 * 1000))
            attachmentMetaBuilder = attachmentMetaBuilder.pollOptions(
                poll.pollOptions)
            attachmentMetaBuilder = attachmentMetaBuilder.multiSelectState(
                poll.selectState.apiKey)
            attachmentMetaBuilder = attachmentMetaBuilder.pollType(
                poll.isInstantPoll ? "instant" : "deferred")
            attachmentMetaBuilder = attachmentMetaBuilder.multSelectNo(
                poll.selectStateCount)
            attachmentMetaBuilder = attachmentMetaBuilder.isAnonymous(
                poll.isAnonymous)
            attachmentMetaBuilder = attachmentMetaBuilder.allowAddOptions(
                poll.allowAddOptions)

            let attachmentRequest = Attachment()
                .attachmentType(.poll)
                .attachmentMeta(attachmentMetaBuilder.build())

            // Store list of attachments
            var attachmentList = [attachmentRequest]

            // If custom widget is provided,
            // add the earlier created custom widget attachment into
            // the attachments list
            if let customWidgetAttachment {
                attachmentList.append(customWidgetAttachment)
            }

            createPost(
                with: content, heading: heading,
                attachments: attachmentList, topics: topics)

        } else if !files.isEmpty {
            var tempFiles = files

            for i in 0..<files.count {
                dispatchGroup.enter()
                let file = files[i]
                LMAWSManager.shared.uploadfile(
                    fileData: file.data,
                    fileName: "\(file.awsFilePath)\(file.fileName)",
                    contenType: file.contentType.contentType, progress: nil
                ) { [weak self] response, error in
                    if error == nil {
                        tempFiles[i].awsURL = response
                    }
                    self?.dispatchGroup.leave()
                }
            }

            dispatchGroup.notify(queue: .global(qos: .background)) {
                [weak self] in
                guard let self else { return }
                var attachments: [Attachment] = []

                for file in tempFiles {
                    switch file.contentType {
                    case .image:
                        if let attachment = imageAttachmentData(
                            attachment: file)
                        {
                            attachments.append(attachment)
                        }
                    case .video:
                        if let attachment = videoAttachmentData(
                            attachment: file)
                        {
                            attachments.append(attachment)
                        }
                    case .document:
                        if let attachment = fileAttachmentData(attachment: file)
                        {
                            attachments.append(attachment)
                        }
                    case .none, .poll:
                        break
                    }
                }

                guard tempFiles.count == attachments.count else {
                    postMessageForCompleteCreatePost(
                        with: "Files Upload Error!")
                    return
                }

                // If custom widget is provided,
                // add the earlier created custom widget attachment into
                // the attachments list
                if let customWidgetAttachment {
                    attachments.append(customWidgetAttachment)
                }

                self.createPost(
                    with: content, heading: heading, attachments: attachments,
                    topics: topics)
            }
        } else {
            // Create an empty list of attachments
            var attachmentList = [Attachment]()

            // If custom widget is provided,
            // add the earlier created custom widget attachment into
            // the attachments list
            if let customWidgetAttachment {
                attachmentList.append(customWidgetAttachment)
            }

            createPost(
                with: content, heading: heading, attachments: attachmentList,
                topics: topics
            )
        }
    }

    private func createPost(
        with content: String, heading: String?, attachments: [Attachment],
        topics: [String]
    ) {
        var addPostRequest = AddPostRequest.Builder()

        addPostRequest = addPostRequest.heading(heading)
        addPostRequest = addPostRequest.text(content)
        addPostRequest = addPostRequest.attachments(attachments)
        addPostRequest = addPostRequest.topics(topics)

        LMFeedClient.shared.addPost(addPostRequest.build()) {
            [weak self] response in
            guard response.success else {
                self?.postMessageForCompleteCreatePost(
                    with: response.errorMessage)
                return
            }
            NotificationCenter.default.post(name: .LMPostCreated, object: nil)
        }
    }

    func imageAttachmentData(attachment: LMAWSRequestModel) -> Attachment? {
        guard let awsURL = attachment.awsURL,
            !awsURL.isEmpty
        else { return nil }

        var size: Int?

        if let attr = try? FileManager.default.attributesOfItem(
            atPath: attachment.url.absoluteString)
        {
            size = attr[.size] as? Int
        }

        var attachmentMeta = AttachmentMeta.Builder()

        attachmentMeta = attachmentMeta.attachmentUrl(awsURL)
        attachmentMeta = attachmentMeta.size(size ?? 0)
        attachmentMeta = attachmentMeta.name(attachment.fileName)

        if let width = attachment.width {
            attachmentMeta = attachmentMeta.width(width)
        }

        if let height = attachment.height {
            attachmentMeta = attachmentMeta.height(height)
        }

        let attachmentRequest = Attachment()
            .attachmentType(.image)
            .attachmentMeta(attachmentMeta.build())
        return attachmentRequest
    }

    func videoAttachmentData(attachment: LMAWSRequestModel) -> Attachment? {
        guard let awsURL = attachment.awsURL,
            !awsURL.isEmpty
        else { return nil }

        var size: Int?
        if let attr = try? FileManager.default.attributesOfItem(
            atPath: attachment.url.absoluteString)
        {
            size = attr[.size] as? Int
        }

        let asset = AVAsset(url: attachment.url)
        let duration = asset.duration
        let durationTime = CMTimeGetSeconds(duration)

        var attachmentMeta = AttachmentMeta.Builder()

        attachmentMeta = attachmentMeta.attachmentUrl(awsURL)
        attachmentMeta = attachmentMeta.size(size ?? 0)
        attachmentMeta = attachmentMeta.name(attachment.fileName)
        attachmentMeta = attachmentMeta.duration(Int(durationTime))

        if let width = attachment.width {
            attachmentMeta = attachmentMeta.width(width)
        }

        if let height = attachment.height {
            attachmentMeta = attachmentMeta.height(height)
        }

        let attachmentRequest = Attachment()
            .attachmentType(.video)
            .attachmentMeta(attachmentMeta.build())

        return attachmentRequest
    }

    func fileAttachmentData(attachment: LMAWSRequestModel) -> Attachment? {
        guard let awsURL = attachment.awsURL,
            !awsURL.isEmpty
        else { return nil }

        _ = attachment.url.startAccessingSecurityScopedResource()
        var size: Int?
        if let attr = try? FileManager.default.attributesOfItem(
            atPath: attachment.url.path)
        {
            size = attr[.size] as? Int
        }

        var pageCount: Int?
        if let pdf = PDFDocument(url: attachment.url) {
            pageCount = pdf.pageCount
        }
        attachment.url.stopAccessingSecurityScopedResource()

        var attachmentMeta = AttachmentMeta.Builder()
        attachmentMeta = attachmentMeta.attachmentUrl(awsURL)
        attachmentMeta = attachmentMeta.size(size ?? 0)
        attachmentMeta = attachmentMeta.name(attachment.fileName)
        attachmentMeta = attachmentMeta.pageCount(pageCount ?? 0)
        attachmentMeta = attachmentMeta.format("pdf")

        let attachmentRequest = Attachment()
            .attachmentType(.doc)
            .attachmentMeta(attachmentMeta.build())

        return attachmentRequest
    }

    func postMessageForCompleteCreatePost(with error: String?) {
        DispatchQueue.main.async {
            NotificationCenter.default.post(
                name: .LMPostCreateError,
                object: LMFeedError.postCreationFailed(error: error))
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
                } catch {}
            case .video:
                do {
                    let asset = AVAsset(url: file.url)
                    let imgGenerator = AVAssetImageGenerator(asset: asset)
                    imgGenerator.appliesPreferredTrackTransform = true
                    let cgImage = try imgGenerator.copyCGImage(
                        at: .zero, actualTime: nil)
                    image = UIImage(cgImage: cgImage)
                } catch {}
            case .document:
                if let pdf = PDFDocument(url: file.url),
                    let pdfPage = pdf.page(at: 0)
                {
                    let pdfPageSize = pdfPage.bounds(for: .mediaBox)
                    let renderer = UIGraphicsImageRenderer(
                        size: pdfPageSize.size)

                    image = renderer.image { ctx in
                        UIColor.white.set()
                        ctx.fill(pdfPageSize)
                        ctx.cgContext.translateBy(
                            x: 0.0, y: pdfPageSize.size.height)
                        ctx.cgContext.scaleBy(x: 1.0, y: -1.0)

                        pdfPage.draw(with: .mediaBox, to: ctx.cgContext)
                    }
                }
            case .none, .poll:
                break
            }
        }

        NotificationCenter.default.post(
            name: .LMPostCreationStarted, object: image)
    }
}
