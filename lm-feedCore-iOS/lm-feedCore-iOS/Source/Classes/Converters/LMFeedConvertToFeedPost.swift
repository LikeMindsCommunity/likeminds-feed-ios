//
//  LMFeedConvertToFeedPost.swift
//  likeminds-feed-iOS
//
//  Created by Devansh Mohata on 03/01/24.
//

import LikeMindsFeed
import LikeMindsFeedUI

public struct LMFeedConvertToFeedPost {
    public static func convertToViewModel(for post: LMFeedPostDataModel)
        -> LMFeedPostContentModel
    {
        let documents = convertToDocument(from: post.documentAttachment)
        let media = convertToMediaProtocol(
            from: post.imageVideoAttachment, postID: post.postId)
        var linkPreview: LMFeedLinkPreview.ContentModel?
        let pollPreview = convertToPollModel(from: post)

        let widgets = convertToWidget(from: post.widgetAttachment)

        var topResponse: LMFeedCommentContentModel?

        if let topResponseData = post.topResponse {
            topResponse = convertToCommentModel(from: topResponseData)
        }

        if let link = post.linkAttachment {
            linkPreview = .init(
                linkPreview: link.previewImage, title: link.title,
                description: link.description, url: link.url)
        }

        var postType = LMFeedPostType.text

        if !media.isEmpty {
            postType = .media
        } else if !documents.isEmpty {
            postType = .documents
        } else if linkPreview != nil {
            postType = .link
        } else if pollPreview != nil {
            postType = .poll
        } else if !widgets.isEmpty {
            postType = .widget
        } else if !post.postContent.trimmingCharacters(
            in: .whitespacesAndNewlines
        ).isEmpty
            || !post.postQuestion.trimmingCharacters(
                in: .whitespacesAndNewlines
            ).isEmpty
        {
            postType = .text
        } else {
            postType = .other
        }

        let transformedData = LMFeedPostContentModel(
            postType: postType,
            postID: post.postId,
            userUUID: post.userDetails.userUUID,
            headerData: convertToHeaderViewData(from: post),
            postQuestion: post.postQuestion,
            postText: post.postContent,
            topics: convertToTopicViewData(from: post.topics),
            footerData: convertToFooterViewData(from: post),
            totalCommentCount: post.commentCount,
            documents: documents,
            widgets: widgets,
            linkPreview: linkPreview,
            mediaData: media,
            pollWidget: pollPreview,
            topResponse: topResponse,
            mediaHaveSameAspectRatio: post.mediaHaveSameAspectRatio,
            aspectRatio: post.aspectRatio,
            createdAt: post.createTime
        )

        return transformedData
    }

    private static func convertToTopicViewData(
        from topics: [LMFeedTopicDataModel]
    ) -> LMFeedTopicView.ContentModel {
        let mappedTopics: [LMFeedTopicCollectionCellDataModel] = topics.map {
            .init(topic: $0.topicName, topicID: $0.topicID)
        }

        return .init(topics: mappedTopics)
    }

    public static func convertToHeaderViewData(from data: LMFeedPostDataModel)
        -> LMFeedPostHeaderView.ContentModel
    {
        let widgets: [LMFeedWidgetContentModel] =
            convertToWidget(from: data.widgetAttachment)

        return .init(
            profileImage: data.userDetails.userProfileImage,
            authorName: data.userDetails.userName,
            authorTag: data.userDetails.customTitle,
            subtitle: "\(data.createTime)\(data.isEdited ? " • Edited" : "")",
            isPinned: data.isPinned,
            showMenu: !data.postMenu.isEmpty,
            widgets: widgets
        )
    }

    public static func convertToFooterViewData(from data: LMFeedPostDataModel)
        -> LMFeedPostFooterView.ContentModel
    {
        var loggedInUser: LMFeedUserModel?

        if let user = LikeMindsFeed.UserDetails.userDetails {
            loggedInUser = .init(
                userName: user.name ?? "User",
                userUUID: user.sdkClientInfo?.uuid ?? "uuid",
                userProfileImage: user.imageUrl, customTitle: user.customTitle)
        }

        let widgets: [LMFeedWidgetContentModel] =
            convertToWidget(from: data.widgetAttachment)

        return .init(
            isSaved: data.isSaved,
            isLiked: data.isLiked,
            likeCount: data.likeCount,
            commentCount: data.commentCount,
            likeText: LMStringConstants.shared.likeVariable,
            commentText: LMStringConstants.shared.commentVariable,
            user: loggedInUser,
            widgets: widgets
        )
    }

    public static func convertToDocument(
        from data: [LMFeedPostDataModel.DocumentAttachment]
    ) -> [LMFeedDocumentPreview.ContentModel] {
        data.compactMap { datum in
            guard let url = URL(string: datum.url) else { return nil }

            return .init(
                title: datum.name,
                documentURL: url,
                size: datum.size,
                pageCount: datum.pageCount,
                docType: datum.format
            )
        }
    }

    public static func convertToWidget(from data: [LMFeedWidgetDataModel])
        -> [LMFeedWidgetContentModel]
    {
        data.compactMap { widget in
            var lmMeta: LMFeedLMMetaContentModel?
            if let widgetLMMeta = widget.lmMeta {
                var pollOptions: [LMFeedPollOptionContentModel]?

                pollOptions = widgetLMMeta.options.map {
                    option in
                    return LMFeedPollOptionContentModel(
                        id: option.id, text: option.text,
                        isSelected: option.isSelected,
                        percentage: option.percentage, uuid: option.uuid,
                        voteCount: option.voteCount)
                }

                lmMeta = LMFeedLMMetaContentModel(
                    options: pollOptions ?? [],
                    pollAnswerText: widgetLMMeta.pollAnswerText,
                    isShowResult: widgetLMMeta.isShowResult,
                    voteCount: widgetLMMeta.voteCount)
            }

            return LMFeedWidgetContentModel.init(
                id: widget.id, parentEntityID: widget.parentEntityID,
                parentEntityType: widget.parentEntityType,
                metadata: widget.metadata, createdAt: widget.createdAt,
                updatedAt: widget.updatedAt, lmMeta: lmMeta)
        }
    }

    public static func convertToMediaProtocol(
        from data: [LMFeedPostDataModel.ImageVideoAttachment], postID: String
    ) -> [LMFeedMediaProtocol] {
        data.map { datum in
            if datum.isVideo {
                return LMFeedVideoCollectionCell.ContentModel(
                    videoURL: datum.url, postID: postID, width: datum.width,
                    height: datum.height)
            } else {
                return LMFeedImageCollectionCell.ContentModel(
                    image: datum.url, width: datum.width, height: datum.height)
            }
        }
    }

    public static func convertToUserModel(from user: LMFeedUserDataModel)
        -> LMFeedUserModel
    {
        .init(
            userName: user.userName, userUUID: user.userUUID,
            userProfileImage: user.userProfileImage,
            customTitle: user.customTitle)
    }
}

// MARK: Comment Specific
extension LMFeedConvertToFeedPost {
    public static func convertToCommentModel(
        for comments: [LMFeedCommentDataModel]
    ) -> [LMFeedCommentContentModel] {
        comments.enumerated().map { index, comment in
            return convertToCommentModel(from: comment)
        }
    }

    public static func convertToCommentModel(
        from comment: LMFeedCommentDataModel
    ) -> LMFeedCommentContentModel {
        var replies: [LMFeedCommentContentModel] = []

        comment.replies.forEach { reply in
            replies.append(convertToCommentModel(from: reply))
        }

        return .init(
            author: convertToUserModel(from: comment.userDetail),
            commentId: comment.commentID,
            tempCommentId: comment.temporaryCommentID,
            comment: comment.commentText,
            commentTime: comment.createdAtFormatted,
            likeCount: comment.likeCount,
            totalReplyCount: comment.totalRepliesCount,
            replies: replies,
            isEdited: comment.isEdited,
            isLiked: comment.isLiked,
            likeKeyword: LMStringConstants.shared.likeVariable
        )
    }
}

// MARK: Poll Specific
extension LMFeedConvertToFeedPost {
    /// Converts an `LMFeedPostDataModel` object to a `LMFeedDisplayPollView.ContentModel` object.
    ///
    /// - Parameter data: An `LMFeedPostDataModel` object containing the poll data.
    /// - Returns: A `LMFeedDisplayPollView.ContentModel` object representing the poll, or `nil` if the input data does not contain a poll attachment.
    public static func convertToPollModel(from data: LMFeedPostDataModel) -> LMFeedDisplayPollView.ContentModel? {
        // Ensure the poll attachment exists in the provided data
        guard let pollAttachment = data.pollAttachment else { return nil }
        
        // Extract key attributes from the poll attachment
        let postID = pollAttachment.postID
        let pollID = pollAttachment.id
        let optionCount = pollAttachment.options.count
        
        // Determine if the poll has been submitted
        let isPollSubmitted = isPollSubmitted(options: pollAttachment.options)
        
        // Determine if the poll has ended
        let isPollEnded = hasPollEnded(time: pollAttachment.expiryTime)
        
        // Check if the poll is multi-choice
        let isMultiChoice = isMultiChoicePoll(
            pollSelectCount: pollAttachment.pollSelectCount,
            pollSelectType: pollAttachment.pollSelectType
        )
        
        // Determine if the "Submit" button should be shown
        let isShowSubmitButton = isShowSubmitButton(
            isPollEnded: isPollEnded,
            isMultiChoice: isMultiChoice,
            isPollSubmitted: isPollSubmitted
        )
        
        // Determine if the "Add Option" button should be shown
        let allowAddOptions = isShowAddOptionButton(
            isInstantPoll: pollAttachment.isInstantPoll,
            isPollSubmitted: isPollSubmitted,
            isAllowAddOption: pollAttachment.allowAddOptions,
            isPollEnded: isPollEnded,
            optionCount: optionCount
        )
        
        // Map the poll options to the display model
        let options: [LMFeedDisplayPollOptionWidget.ContentModel] = pollAttachment.options.map({
            .init(
                pollId: pollID,
                optionId: $0.id,
                option: $0.option,
                addedBy: pollAttachment.allowAddOptions ? $0.addedBy.userName : nil,
                voteCount: $0.voteCount,
                votePercentage: $0.percentage,
                isSelected: $0.isSelected || pollAttachment.userSelectedOptions.contains($0.id),
                showVoteCount: pollAttachment.showResults,
                showProgressBar: pollAttachment.showResults && (isPollEnded || isPollSubmitted),
                showTickButton: ($0.isSelected || pollAttachment.userSelectedOptions.contains($0.id)) && (isMultiChoice || !pollAttachment.isInstantPoll)
            )
        })
        
        // Return the constructed poll content model
        return .init(
            postID: postID,
            pollID: pollID,
            question: pollAttachment.question,
            answerText: pollAttachment.pollDisplayText,
            options: options,
            expiryDate: Date(
                timeIntervalSince1970: Double(pollAttachment.expiryTime / 1000)),
            optionState: pollAttachment.pollSelectType.description,
            optionCount: pollAttachment.pollSelectCount,
            isAnonymousPoll: pollAttachment.isAnonymous,
            isInstantPoll: pollAttachment.isInstantPoll,
            allowAddOptions: allowAddOptions,
            isShowSubmitButton: isShowSubmitButton,
            isShowEditVote: !isPollEnded && isPollSubmitted
                && !pollAttachment.isInstantPoll
        )
    }
    
    /// Determines if a poll has been submitted by checking if any option is selected.
    ///
    /// - Parameter options: An array of `LMFeedPollDataModel.Option` objects representing the poll options.
    /// - Returns: A Boolean value indicating whether at least one option has been selected (`true`) or not (`false`).
    public static func isPollSubmitted(options: [LMFeedPollDataModel.Option]) -> Bool {
        options.contains(where: { $0.isSelected })
    }
    
    /// Checks whether a poll has ended based on the given time.
    ///
    /// - Parameter time: The end time of the poll, provided as an epoch timestamp.
    ///                   This can either be in seconds or milliseconds.
    /// - Returns: A Boolean value indicating whether the current time has surpassed the poll's end time (`true`) or not (`false`).
    public static func hasPollEnded(time: Int) -> Bool {
        if DateUtility.isEpochTimeInSeconds(time) {
            Int(Date().timeIntervalSince1970) > time
        } else {
            Int(Date().timeIntervalSince1970) > (time / 1000)
        }
    }

    /// Determines if the poll allows multiple choices based on the selection count and selection type.
    ///
    /// - Parameters:
    ///   - pollSelectCount: The number of choices a user can select.
    ///   - pollSelectType: The type of poll selection, represented by `LMFeedPollSelectState`.
    /// - Returns: A Boolean value indicating whether the poll is a multi-choice poll (`true`) or a single-choice poll (`false`).
    public static func isMultiChoicePoll(pollSelectCount: Int, pollSelectType: LMFeedPollSelectState) -> Bool {
        !(pollSelectType == .exactly && pollSelectCount == 1)
    }
    
    /// Determines whether the "Submit" button should be shown for a poll.
    ///
    /// - Parameters:
    ///   - isPollEnded: A Boolean value indicating if the poll has ended.
    ///   - isMultiChoice: A Boolean value indicating if the poll allows multiple choices.
    ///   - isPollSubmitted: A Boolean value indicating if the poll has already been submitted.
    /// - Returns: A Boolean value indicating whether the "Submit" button should be displayed (`true`) or not (`false`).
    public static func isShowSubmitButton(isPollEnded: Bool, isMultiChoice: Bool, isPollSubmitted: Bool) -> Bool {
        !(isPollEnded || !isMultiChoice || isPollSubmitted)
    }
    
    /// Determines whether the "Add Option" button should be shown in a poll.
    ///
    /// - Parameters:
    ///   - isInstantPoll: A Boolean value indicating if the poll is an instant poll.
    ///   - isPollSubmitted: A Boolean value indicating if the poll has already been submitted.
    ///   - isAllowAddOption: A Boolean value indicating if adding options is allowed for the poll.
    ///   - isPollEnded: A Boolean value indicating if the poll has ended.
    ///   - optionCount: The current number of options in the poll.
    /// - Returns: A Boolean value indicating whether the "Add Option" button should be displayed (`true`) or not (`false`).
    public static func isShowAddOptionButton(isInstantPoll: Bool, isPollSubmitted: Bool, isAllowAddOption: Bool, isPollEnded: Bool, optionCount: Int) -> Bool {
        var isAllowed = true

        if isInstantPoll {
            isAllowed = !isPollSubmitted
        }

        return isAllowAddOption && !isPollEnded && isAllowed && optionCount < 10
    }
}
