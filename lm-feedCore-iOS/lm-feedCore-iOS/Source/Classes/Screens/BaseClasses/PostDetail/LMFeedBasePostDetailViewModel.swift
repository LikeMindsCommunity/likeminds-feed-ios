//
//  LMFeedPostDetailViewModel.swift
//  likeminds-feed-iOS
//
//  Created by Devansh Mohata on 03/01/24.
//

import LikeMindsFeed
import LikeMindsFeedUI

public class LMFeedBasePostDetailViewModel {
    public let postID: String
    public var currentPage: Int
    public var pageSize: Int
    public var isFetchingData: Bool
    public var isDataAvailable: Bool
    public var postDetail: LMFeedPostDataModel?
    public var commentList: [LMFeedCommentDataModel]
    public var replyToComment: LMFeedCommentDataModel?
    public var editCommentIndex: (commentID: String, indexPath: IndexPath)?
    public var openCommentSection: Bool
    public var scrollToCommentSection: Bool
    public weak var delegate: LMFeedBasePostDetailViewModelProtocol?

    public init(
        postID: String, delegate: LMFeedBasePostDetailViewModelProtocol?,
        openCommentSection: Bool, scrollToCommentSection: Bool
    ) {
        self.postID = postID
        self.commentList = []
        self.currentPage = 1
        self.pageSize = 20
        self.isFetchingData = false
        self.isDataAvailable = true
        self.openCommentSection = openCommentSection
        self.scrollToCommentSection = scrollToCommentSection
        self.delegate = delegate
    }

    func findCommentIndex(
        for commentID: String, from comments: [LMFeedCommentDataModel]
    ) -> (comment: LMFeedCommentDataModel, index: IndexPath)? {
        for (idx, comment) in comments.enumerated() {
            if comment.commentID == commentID {
                return (comment, IndexPath(row: NSNotFound, section: idx))
            }

            for (innerIdx, innerComment) in comment.replies.enumerated() {
                if innerComment.commentID == commentID {
                    return (
                        innerComment, IndexPath(row: innerIdx, section: idx)
                    )
                }
            }
        }

        return nil
    }

    func getMemberState() {
        LMFeedClient.shared.getMemberState { [weak self] result in
            guard let self else { return }

            if result.success,
                let memberState = result.data
            {
                LocalPreferences.memberState = memberState
            }

            delegate?.updateCommentStatus(
                isEnabled: LocalPreferences.memberState?.memberRights?.contains(
                    where: { $0.state == .commentOrReplyOnPost }) ?? false)
        }
    }

    func allowPostLikeView() -> Bool {
        postDetail?.likeCount ?? 0 > 0
    }

    func allowCommentLikeView(for commentId: String) -> Bool {
        if let comment = findCommentIndex(for: commentId, from: commentList) {
            return comment.comment.likeCount > 0
        }
        return false
    }

    func notifyObjectChange() {
        guard let postDetail else { return }
        NotificationCenter.default.post(name: .LMPostUpdate, object: postDetail)
    }

    func updatePostData(data: LMFeedPostDataModel?) {
        postDetail = data
        notifyObjectChange()
    }

    func updatePost(
        data: LMFeedPostDataModel, onlyHeader: Bool = false,
        onlyFooter: Bool = false
    ) {
        updatePostData(data: data)
        delegate?.updatePost(
            post: LMFeedConvertToFeedPost.convertToViewModel(for: data),
            onlyHeader: onlyHeader, onlyFooter: onlyFooter)
    }
}

// MARK: Get Post Details
extension LMFeedPostDetailViewModel {
    public func getPost(isInitialFetch: Bool) {
        if isInitialFetch {
            currentPage = 1
            isFetchingData = false
            isDataAvailable = true
        }

        guard !isFetchingData,
            isDataAvailable
        else { return }

        self.isFetchingData = true

        LMFeedPostOperation.shared.getPost(
            for: postID, currentPage: currentPage, pageSize: pageSize
        ) { [weak self] response in
            defer {
                self?.isFetchingData = false
            }

            guard let self else { return }

            if response.success,
                let post = response.data?.post,
                let users = response.data?.users
            {
                let allTopics =
                    response.data?.topics?.compactMap({ $0.value }) ?? []
                let widgets = response.data?.widgets ?? [:]

                if currentPage == 1 {
                    commentList.removeAll(keepingCapacity: true)
                }

                let data = LMFeedPostDataModel.init(
                    post: post, users: users, allTopics: allTopics,
                    widgets: widgets)

                guard let data else { return }

                self.updatePostData(data: data)

                let newComments: [LMFeedCommentDataModel] =
                    post.replies?.enumerated().compactMap { index, comment in
                        guard let user = users[comment.uuid ?? ""] else {
                            return nil
                        }
                        return .init(comment: comment, user: user)
                    } ?? []

                commentList.append(contentsOf: newComments)

                let newPostConverted =
                    LMFeedConvertToFeedPost.convertToViewModel(for: data)
                let newCommentsConverted =
                    LMFeedConvertToFeedPost.convertToCommentModel(
                        for: newComments)

                delegate?.showPostDetails(
                    with: newPostConverted, comments: newCommentsConverted,
                    isInitialPage: currentPage == 1)
                handleCommentScroll()

                currentPage += 1
            } else if postDetail == nil {
                delegate?.showError(
                    with: response.errorMessage
                        ?? LMStringConstants.shared.genericErrorMessage,
                    isPopVC: true)
            }
        }
    }

    public func handleCommentScroll() {
        if openCommentSection || scrollToCommentSection {
            delegate?.handleCommentScroll(
                openCommentSection: openCommentSection,
                scrollToCommentSection: scrollToCommentSection)
            openCommentSection = false
            scrollToCommentSection = false
        }
    }
}

// MARK: Comment Shenanigans
extension LMFeedPostDetailViewModel {
    public func likeComment(for commentID: String, indexPath: IndexPath) {
        LMFeedPostOperation.shared.likeComment(
            for: postID, commentID: commentID
        ) { [weak self] response in
            guard let self else { return }

            if response,
                let answer = findCommentIndex(for: commentID, from: commentList)
            {
                var comment = answer.comment
                let commentIndex = answer.index
                let isLiked = comment.isLiked
                comment.isLiked = !isLiked
                comment.likeCount += !isLiked ? 1 : -1

                if commentIndex.row == NSNotFound {
                    commentList[commentIndex.section] = comment
                } else {
                    commentList[commentIndex.section].replies[
                        commentIndex.row] = comment
                }
            } else {
                let comment = commentList[indexPath.section - 1]
                delegate?.updateComment(
                    comment: LMFeedConvertToFeedPost.convertToCommentModel(
                        from: comment))
            }
        }
    }

    public func getCommentReplies(commentId: String, isClose: Bool) {
        guard
            let index = commentList.firstIndex(where: {
                $0.commentID == commentId
            })
        else { return }

        if isClose,
            !commentList[index].replies.isEmpty
        {
            commentList[index].replies.removeAll(keepingCapacity: true)
            delegate?.updateComment(
                comment: LMFeedConvertToFeedPost.convertToCommentModel(
                    from: commentList[index]))
            return
        }

        guard !isFetchingData else { return }
        self.isFetchingData = true

        let replyCurrentPage = (commentList[index].replies.count / 5) + 1

        LMFeedPostOperation.shared.getCommentReplies(
            for: postID, commentID: commentId, currentPage: replyCurrentPage
        ) { [weak self] response in
            guard let self else { return }
            isFetchingData = false

            guard let commentArray = response.data?.comment,
                let users = response.data?.users
            else {
                return
            }

            let newComments: [LMFeedCommentDataModel] =
                commentArray.replies?.enumerated().compactMap {
                    index, comment in
                    guard let user = users[comment.uuid ?? ""] else {
                        return nil
                    }
                    return .init(comment: comment, user: user)
                } ?? []

            newComments.forEach { newComment in
                if !self.commentList[index].replies.contains(where: {
                    $0.commentID == newComment.commentID
                        || $0.temporaryCommentID
                            == newComment.temporaryCommentID
                }) {
                    self.commentList[index].replies.append(newComment)
                }
            }

            delegate?.updateComment(
                comment: LMFeedConvertToFeedPost.convertToCommentModel(
                    from: commentList[index]))
        }
    }

    // MARK: Show Comment Menu
    public func showMenu(for commentID: String) {
        guard
            let (comment, idx) = findCommentIndex(
                for: commentID, from: commentList),
            !comment.menuItems.isEmpty
        else { return }

        let alert = UIAlertController(
            title: .none, message: .none, preferredStyle: .actionSheet)

        comment.menuItems.forEach { menu in
            switch menu.id {
            case .deleteComment:
                alert.addAction(
                    .init(title: menu.name, style: .destructive) {
                        [weak self] _ in
                        self?.handleDeleteComment(for: commentID)
                    })
            case .reportComment:
                alert.addAction(
                    .init(title: menu.name, style: .destructive) {
                        [weak self] _ in
                        guard let self else { return }
                        if idx.row == NSNotFound {
                            delegate?.navigateToReportScreen(
                                for: postID,
                                creatorUUID: comment.userDetail.userUUID,
                                commentID: commentID, replyCommentID: nil)
                        } else {
                            delegate?.navigateToReportScreen(
                                for: postID,
                                creatorUUID: comment.userDetail.userUUID,
                                commentID: commentList[idx.section].userDetail
                                    .userUUID, replyCommentID: commentID)
                        }
                    })
            case .editComment:
                alert.addAction(
                    .init(title: menu.name, style: .default) { [weak self] _ in
                        self?.editCommentIndex = (commentID, idx)
                        self?.delegate?.setEditCommentText(
                            with: comment.commentText)
                    })
            default:
                break
            }
        }

        alert.addAction(.init(title: "Cancel", style: .cancel))

        delegate?.presentAlert(with: alert, animated: true)
    }

    // MARK: Click on Reply Button
    public func replyToComment(having commentID: String?) {
        guard let commentID,
            let (comment, _) = findCommentIndex(
                for: commentID, from: commentList)
        else {
            replyToComment = nil
            return
        }

        replyToComment = comment
        delegate?.replyToComment(userName: comment.userDetail.userName)
    }

    // MARK: Send Comment Button
    public func sendButtonTapped(with comment: String) {
        if let editCommentIndex {
            editReply(
                with: comment, commentID: editCommentIndex.commentID,
                index: editCommentIndex.indexPath)
        } else {
            postReply(with: comment)
        }
    }

    public func editReply(
        with comment: String, commentID: String, index: IndexPath
    ) {
        LMFeedPostOperation.shared.editComment(
            for: postID, commentID: commentID, comment: comment
        ) { [weak self] response in
            self?.editCommentIndex = nil
            if response.success,
                let newCommentData = response.data?.comment,
                let user = response.data?.users?[newCommentData.uuid ?? ""],
                let newComment = LMFeedCommentDataModel(
                    comment: newCommentData, user: user)
            {

                if self?.commentList.indices.contains(index.section) == true {
                    if self?.commentList[index.section].replies.indices
                        .contains(index.row) == true
                    {
                        self?.commentList[index.section].replies[index.row] =
                            newComment
                    } else {
                        self?.commentList[index.section] = newComment
                    }
                }

                self?.delegate?.updateComment(
                    comment: LMFeedConvertToFeedPost.convertToCommentModel(
                        from: newComment))
                return
            } else {

                self?.delegate?.showError(
                    with: response.errorMessage
                        ?? LMStringConstants.shared.genericErrorMessage,
                    isPopVC: false)
            }
        }
    }

    public func postReply(with commentString: String) {
        guard let userInfo = LocalPreferences.userObj,
            let userName = userInfo.name,
            let uuid = userInfo.uuid
        else { return }

        let userObj = LMFeedUserDataModel(
            userName: userName, userUUID: uuid,
            userProfileImage: userInfo.imageUrl,
            customTitle: userInfo.customTitle)
        let time = Int(Date().millisecondsSince1970.rounded())

        let localComment: LMFeedCommentDataModel = .init(
            commentID: nil,
            userDetail: userObj,
            temporaryCommentID: "\(time)",
            createdAt: time,
            isLiked: false,
            likeCount: 0,
            isEdited: false,
            commentText: commentString,
            menuItems: [],
            totalRepliesCount: 0
        )

        if let replyToComment,
            let commentID = replyToComment.commentID,
            let (_, commentIndex) = findCommentIndex(
                for: commentID, from: commentList)
        {
            commentList[commentIndex.section].replies.insert(
                localComment, at: 0)
            commentList[commentIndex.section].totalRepliesCount += 1
            delegate?.updateComment(
                comment: LMFeedConvertToFeedPost.convertToCommentModel(
                    from: commentList[commentIndex.section]))
            postReplyOnComment(
                with: commentString, commentID: commentID,
                localComment: localComment)
        } else if var newPost = postDetail {
            newPost.commentCount += 1
            updatePost(data: newPost, onlyFooter: true)
            commentList.insert(localComment, at: 0)
            delegate?.insertComment(
                comment: LMFeedConvertToFeedPost.convertToCommentModel(
                    from: localComment), index: 0)
            postReplyOnPost(with: commentString, localComment: localComment)
        }

        replyToComment = nil
    }

    private func postReplyOnPost(
        with comment: String, localComment: LMFeedCommentDataModel
    ) {
        LMFeedPostOperation.shared.postReplyOnPost(
            for: postID, with: comment, createdAt: localComment.createdAt
        ) { [weak self] response in
            guard let self,
                response.success,
                let comment = response.data?.comment,
                let user = response.data?.users?[comment.uuid ?? ""],
                let newComment = LMFeedCommentDataModel.init(
                    comment: comment, user: user)
            else { return }

            LMFeedCore.analytics?.trackEvent(
                for: .commentPosted,
                eventProperties: [
                    "post_id": postID,
                    "comment_id": newComment.commentID,
                ])

            if let idx = commentList.firstIndex(where: {
                $0.temporaryCommentID == localComment.temporaryCommentID
            }) {
                commentList[idx] = newComment
                delegate?.updateComment(
                    comment: LMFeedConvertToFeedPost.convertToCommentModel(
                        from: newComment))
            }
        }
    }

    private func postReplyOnComment(
        with comment: String, commentID: String,
        localComment: LMFeedCommentDataModel
    ) {
        LMFeedPostOperation.shared.postReplyOnComment(
            for: postID, with: comment, commentID: commentID,
            createdAt: localComment.createdAt
        ) { [weak self] response in
            guard let self,
                response.success,
                let comment = response.data?.comment,
                let user = response.data?.users?[comment.uuid ?? ""],
                let newComment = LMFeedCommentDataModel.init(
                    comment: comment, user: user),
                let (parentComment, _) = findCommentIndex(
                    for: commentID, from: commentList)
            else { return }

            LMFeedCore.analytics?.trackEvent(
                for: .commentReplyPosted,
                eventProperties: [
                    "user_id": parentComment.userDetail.userUUID,
                    "post_id": postID,
                    "comment_id": commentID,
                    "comment_reply_id": newComment.commentID,
                ])

            if let idx = commentList.firstIndex(where: {
                $0.commentID == commentID
            }),
                let tempIdx = commentList[idx].replies.firstIndex(where: {
                    $0.temporaryCommentID == localComment.temporaryCommentID
                })
            {
                commentList[idx].replies[tempIdx] = newComment
                delegate?.updateComment(
                    comment: LMFeedConvertToFeedPost.convertToCommentModel(
                        from: commentList[idx]))
            }
        }
    }

    public func handleDeleteComment(for commentID: String) {
        guard
            let (comment, index) = findCommentIndex(
                for: commentID, from: commentList)
        else { return }

        // Case of Self Deletion
        if comment.userDetail.userUUID
            == LocalPreferences.userObj?.sdkClientInfo?.uuid
        {
            let alert = UIAlertController(
                title: LMStringConstants.shared.deleteComment,
                message: LMStringConstants.shared.deleteCommentMessage,
                preferredStyle: .alert)

            let deleteAction = UIAlertAction(
                title: "Delete", style: .destructive
            ) { [weak self] _ in
                self?.deleteComment(for: commentID, index: index, reason: nil)
            }

            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)

            alert.addAction(cancelAction)
            alert.addAction(deleteAction)

            delegate?.presentAlert(with: alert, animated: true)
        } else if LocalPreferences.memberState?.state == 1 {
            // State 1 means its a admin
            delegate?.navigateToDeleteScreen(for: postID, commentID: commentID)
        }

        // Analytics
        let eventName: LMFeedAnalyticsEventName =
            index.row == NSNotFound ? .commentDeleted : .commentReplyDeleted
        var analyticProperties: [String: String] = ["post_id": postID]

        if index.row == NSNotFound {
            analyticProperties["comment_id"] = commentID
        } else {
            analyticProperties["comment_id"] =
                commentList[index.section].commentID
            analyticProperties["comment_reply_id"] = commentID
        }

        LMFeedCore.analytics?.trackEvent(
            for: eventName, eventProperties: analyticProperties)
    }

    public func deleteComment(
        for commentID: String, index: IndexPath, reason: String?
    ) {
        LMFeedPostOperation.shared.deleteComment(
            for: postID, having: commentID, reason: reason
        ) { [weak self] response in
            guard let self else { return }

            switch response {
            case .success():
                checkIfCurrentPost(postID: postID, commentID: commentID)
            case .failure(let error):
                delegate?.showError(
                    with: error.localizedDescription, isPopVC: false)
            }
        }
    }
}

// MARK: Post Shenanigans
extension LMFeedPostDetailViewModel {
    // MARK: Like Post
    public func likePost(for postId: String) {
        LMFeedPostOperation.shared.likePost(for: postId) {
            [weak self] response in
            guard let self,
                var newPost = postDetail
            else { return }

            if response {
                let newState = !newPost.isLiked
                newPost.isLiked = newState
                newPost.likeCount += newState ? 1 : -1
            }

            updatePost(data: newPost, onlyFooter: true)
        }
    }

    // MARK: Save Post
    public func savePost(for postId: String) {
        LMFeedPostOperation.shared.savePost(for: postId) {
            [weak self] response in
            guard let self,
                var newPost = postDetail
            else { return }

            if response {
                newPost.isSaved.toggle()
            }

            updatePost(data: newPost, onlyFooter: true)
        }
    }

    // MARK: Un/Pin Post
    public func pinUnpinPost(postId: String) {
        LMFeedPostOperation.shared.pinUnpinPost(postId: postId) {
            [weak self] response in
            guard let self,
                var newPost = postDetail
            else { return }

            if response {
                newPost.isPinned.toggle()
                updatePinMenu()
            }

            updatePost(data: newPost, onlyHeader: true)
        }
    }

    public func updatePinMenu() {
        guard
            let index = postDetail?.postMenu.firstIndex(where: {
                $0.id == .pinPost || $0.id == .unpinPost
            })
        else { return }
        var newPost = postDetail
        if newPost?.isPinned == true {
            newPost?.postMenu[index] = .init(
                id: .unpinPost, name: LMStringConstants.shared.unpinThisPost)
        } else {
            newPost?.postMenu[index] = .init(
                id: .pinPost, name: LMStringConstants.shared.pinThisPost)
        }
    }

    // MARK: Show Post Menu
    public func showMenu(postID: String) {
        guard let postDetail else { return }

        let alert = UIAlertController(
            title: .none, message: .none, preferredStyle: .actionSheet)

        postDetail.postMenu.forEach { menu in
            switch menu.id {
            case .deletePost:
                alert.addAction(
                    .init(title: menu.name, style: .destructive) {
                        [weak self] _ in
                        self?.handleDeletePost()
                    })
            case .pinPost,
                .unpinPost:
                alert.addAction(
                    .init(title: menu.name, style: .default) { [weak self] _ in
                        self?.pinUnpinPost(postId: postID)

                        LMFeedCore.analytics?.trackEvent(
                            for: postDetail.isPinned
                                ? .postUnpinned : .postPinned,
                            eventProperties: [
                                "created_by_id": postDetail.userDetails
                                    .userUUID,
                                "post_id": postID,
                                "post_type": postDetail.getPostType(),
                            ])
                    })
            case .reportPost:
                alert.addAction(
                    .init(title: menu.name, style: .destructive) {
                        [weak self] _ in
                        self?.delegate?.navigateToReportScreen(
                            for: postID,
                            creatorUUID: postDetail.userDetails.userUUID,
                            commentID: nil, replyCommentID: nil)
                    })
            case .editPost:
                alert.addAction(
                    .init(title: menu.name, style: .default) { [weak self] _ in
                        self?.delegate?.navigateToEditPost(for: postID)

                        LMFeedCore.analytics?.trackEvent(
                            for: .postEdited,
                            eventProperties: [
                                "post_id": postID,
                                "post_type": postDetail.getPostType(),
                            ])
                    })
            default:
                break
            }
        }

        alert.addAction(.init(title: "Cancel", style: .cancel))

        delegate?.presentAlert(with: alert, animated: true)
    }

    public func handleDeletePost() {
        guard let postDetail else { return }
        // Case of Self Deletion
        if postDetail.userDetails.userUUID
            == LocalPreferences.userObj?.sdkClientInfo?.uuid
        {
            let alert = UIAlertController(
                title: LMStringConstants.shared.deletePost,
                message: LMStringConstants.shared.deletePostMessage,
                preferredStyle: .alert)

            let deleteAction = UIAlertAction(
                title: "Delete", style: .destructive
            ) { [weak self] _ in
                self?.deletePost(reason: nil)
            }

            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)

            alert.addAction(cancelAction)
            alert.addAction(deleteAction)

            delegate?.presentAlert(with: alert, animated: true)

            LMFeedCore.analytics?.trackEvent(
                for: .postDeleted,
                eventProperties: [
                    "user_state": "member",
                    "user_id": postDetail.userDetails.userUUID,
                    "post_id": postDetail.postId,
                    "post_type": postDetail.getPostType(),
                ])
        } else if LocalPreferences.memberState?.state == 1 {
            // State 1 means its a admin
            delegate?.navigateToDeleteScreen(for: postID, commentID: nil)

            LMFeedCore.analytics?.trackEvent(
                for: .postDeleted,
                eventProperties: [
                    "user_state": "CM",
                    "user_id": postDetail.userDetails.userUUID,
                    "post_id": postDetail.postId,
                    "post_type": postDetail.getPostType(),
                ])
        }
    }

    public func deletePost(reason: String?) {
        LMFeedPostOperation.shared.deletePost(postId: postID, reason: reason) {
            [weak self] response in
            guard let self else { return }
            switch response {
            case .success():
                NotificationCenter.default.post(
                    name: .LMPostDeleted, object: postID)
                delegate?.popViewController()
            case .failure(let error):
                delegate?.showError(
                    with: error.localizedDescription, isPopVC: false)
            }
        }
    }

    public func checkIfCurrentPost(postID: String, commentID: String? = nil) {
        guard self.postID == postID else { return }

        if let commentID,
            let (_, index) = findCommentIndex(for: commentID, from: commentList)
        {
            if index.row == NSNotFound {
                _ = commentList.remove(at: index.section)
                var newPost = postDetail
                newPost?.commentCount -= 1
                updatePost(data: newPost!, onlyFooter: true)
                delegate?.deleteComment(commentID: commentID)
            } else {
                commentList[index.section].replies.remove(at: index.row)
                commentList[index.section].totalRepliesCount -= 1
                delegate?.updateComment(
                    comment: LMFeedConvertToFeedPost.convertToCommentModel(
                        from: commentList[index.section]))
            }
            return
        }

        delegate?.popViewController(animated: false)
    }
}

// MARK: Poll
extension LMFeedPostDetailViewModel {
    public func didTapVoteCountButton(
        for postID: String, pollID: String, optionID: String?
    ) {
        guard let poll = postDetail?.pollAttachment else { return }

        if poll.isAnonymous {
            delegate?.showMessage(
                with:
                    "This being an anonymous poll, the names of the voters can not be disclosed.",
                message: nil)
            return
        } else if !poll.showResults
            || poll.expiryTime > Int(Date().timeIntervalSince1970)
        {
            delegate?.showMessage(
                with: "The results will be visible after the poll has ended.",
                message: nil)
            return
        }

        let options = poll.options
        delegate?.navigateToPollResultScreen(
            with: pollID, optionList: options, selectedOption: optionID)
    }

    public func optionSelected(
        for postID: String, pollID: String, option: String
    ) {
        guard var post = postDetail,
            var poll = post.pollAttachment
        else { return }

        if poll.expiryTime < Int(Date().timeIntervalSince1970) {
            delegate?.showMessage(
                with: "Poll ended. Vote can not be submitted now.", message: nil
            )
            return
        } else if LMFeedConvertToFeedPost.isPollSubmitted(options: poll.options)
        {
            return
        } else if !LMFeedConvertToFeedPost.isMultiChoicePoll(
            pollSelectCount: poll.pollSelectCount,
            pollSelectType: poll.pollSelectType)
        {
            submitPollVote(for: postID, pollID: pollID, options: [option])
        } else {
            if let index = poll.userSelectedOptions.firstIndex(of: option) {
                poll.userSelectedOptions.remove(at: index)
            } else {
                poll.userSelectedOptions.append(option)
            }

            post.pollAttachment = poll
            postDetail = post

            updatePost(data: post)
        }
    }

    public func pollSubmitButtonTapped(for postID: String, pollID: String) {
        guard let post = postDetail,
            let poll = post.pollAttachment
        else { return }

        guard
            poll.pollSelectType.checkValidity(
                with: poll.userSelectedOptions.count,
                allowedCount: poll.pollSelectCount)
        else {
            delegate?.showMessage(
                with:
                    "Please select \(poll.pollSelectType.description.lowercased()) \(poll.pollSelectCount) options",
                message: nil)
            return
        }

        submitPollVote(
            for: postID, pollID: pollID, options: poll.userSelectedOptions)
    }

    public func submitPollVote(
        for postID: String, pollID: String, options: [String]
    ) {
        let request =
            SubmitPollVoteRequest
            .builder()
            .pollID(pollID)
            .votes(options)
            .build()

        LMFeedClient.shared.submitPollVoteRequest(request) {
            [weak self] response in
            if response.success {
                self?.getPost(isInitialFetch: true)
            }
        }
    }

    public func editPoll(for postID: String) {
        guard var post = postDetail,
            var poll = post.pollAttachment
        else { return }

        var selectedOptions: [String] = []

        let count = poll.options.count

        for i in 0..<count {
            if poll.options[i].isSelected {
                selectedOptions.append(poll.options[i].id)
            }

            poll.options[i].isSelected = false
        }

        poll.userSelectedOptions = selectedOptions

        post.pollAttachment = poll

        postDetail = post

        updatePost(data: post)
    }

    public func didTapAddOption(for postID: String, pollID: String) {
        guard let poll = postDetail else { return }

        let options = poll.pollAttachment?.options.map({ $0.option }) ?? []

        delegate?.navigateToAddOptionPoll(
            with: postID, pollID: pollID, options: options)
    }
}
