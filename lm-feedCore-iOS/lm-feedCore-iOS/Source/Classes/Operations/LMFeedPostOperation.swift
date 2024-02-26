//
//  LMFeedPostOperation.swift
//  lm-feedCore-iOS
//
//  Created by Devansh Mohata on 27/01/24.
//

import LikeMindsFeed

final public class LMFeedPostOperation {
    private init() { }
    static let shared = LMFeedPostOperation()
    
    func getFeed(currentPage: Int, pageSize: Int, selectedTopics: [String], completion: ((LMResponse<GetFeedResponse>) -> Void)?) {
        var request = GetFeedRequest.builder()
            .page(currentPage)
            .pageSize(pageSize)
        
        if !selectedTopics.isEmpty {
            request = request
                .topics(selectedTopics)
                .build()
        }
        
        LMFeedClient.shared.getFeed(request) { response in
            completion?(response)
        }
    }
    
    func getPost(for postID: String, currentPage: Int, pageSize: Int, completion: ((LMResponse<GetPostResponse>) -> Void)?) {
        let request = GetPostRequest.builder()
            .postId(postID)
            .page(currentPage)
            .pageSize(pageSize)
            .build()
        
        LMFeedClient.shared.getPost(request) { response in
            completion?(response)
        }
    }
    
    func likePost(for postId: String, completion: ((Bool) -> Void)?) {
        let request = LikePostRequest.builder()
            .postId(postId)
            .build()
        
        LMFeedClient.shared.likePost(request) { response in
            completion?(response.success)
        }
    }
    
    func savePost(for postId: String, completion: ((Bool) -> Void)?) {
        let request = SavePostRequest.builder()
            .postId(postId)
            .build()
        
        LMFeedClient.shared.savePost(request) { response in
            completion?(response.success)
        }
    }
    
    func pinUnpinPost(postId: String, completion: ((Bool) -> Void)?) {
        let request = PinPostRequest.builder()
            .postId(postId)
            .build()
        
        LMFeedClient.shared.pinPost(request) { response in
            completion?(response.success)
        }
    }
    
    func deletePost(postId: String, reason: String?, completion: ((Result<Void, LMFeedError>) -> Void)?) {
        let request = DeletePostRequest.builder()
            .postId(postId)
            .deleteReason(reason)
            .build()
        LMFeedClient.shared.deletePost(request) { response in
            if response.success {
                completion?(.success(()))
            } else {
                completion?(.failure(.postDeleteFailed(error: response.errorMessage)))
            }
        }
    }
}


// MARK: Comment Arena
public extension LMFeedPostOperation {
    func postReplyOnPost(for postID: String, with comment: String, createdAt: Int, completion: ((LMResponse<GetCommentResponse>) -> Void)?) {
        let request = AddCommentRequest.builder()
            .postId(postID)
            .text(comment)
            .tempId("\(createdAt)")
            .build()
        
        LMFeedClient.shared.addComment(request) { response in
            completion?(response)
        }
    }
    
    func postReplyOnComment(for postID: String, with comment: String, commentID: String, createdAt: Int, completion: ((LMResponse<ReplyCommentResponse>) -> Void)?) {
        let request = ReplyCommentRequest.builder()
            .postId(postID)
            .commentId(commentID)
            .text(comment)
            .tempId("\(createdAt)")
            .build()
        
        LMFeedClient.shared.replyComment(request) { response in
            completion?(response)
        }
    }
    
    func getCommentReplies(for postID: String, commentID: String, currentPage: Int, pageSize: Int = 5, completion: ((LMResponse<GetCommentResponse>) -> Void)?) {
        let request = GetCommentRequest.builder()
            .postId(postID)
            .commentId(commentID)
            .page(currentPage)
            .pageSize(pageSize)
            .build()
        
        LMFeedClient.shared.getComment(request) { response in
            completion?(response)
        }
    }
    
    func likeComment(for postID: String, commentID: String, completion: ((Bool) -> Void)?) {
        let request = LikeCommentRequest
            .builder()
            .postId(postID)
            .commentId(commentID)
            .build()
        
        LMFeedClient.shared.likeComment(request) { response in
            completion?(response.success)
        }
    }
    
    func deleteComment(for postID: String, having commentID: String, reason: String?, completion: ((Result<Void, LMFeedError>) -> Void)?) {
        let request = DeleteCommentRequest.builder()
            .postId(postID)
            .commentId(commentID)
            .deleteReason(reason)
            .build()
        
        LMFeedClient.shared.deleteComment(request) { response in
            if response.success {
                completion?(.success(()))
            } else {
                completion?(.failure(.commentDeleteFailed(error: response.errorMessage)))
            }
        }
    }
    
    func editComment(for postID: String, commentID: String, comment: String, completion: ((LMResponse<EditCommentResponse>) -> Void)?) {
        let request = EditCommentRequest.builder()
            .postId(postID)
            .commentId(commentID)
            .text(comment)
            .build()
        
        LMFeedClient.shared.editComment(request) { response in
            completion?(response)
        }
    }
}


public extension LMFeedPostOperation {
    func reportContent(with tagID: Int, reason: String, entityID: String, entityType: ReportEntityType, reporterUUID: String, completion: ((Result<Void, LMFeedError>) -> Void)?) {
        let request = ReportRequest.builder()
            .entityId(entityID)
            .entityType(entityType)
            .uuid(reporterUUID)
            .tagId(tagID)
            .reason(reason)
            .build()
        
        LMFeedClient.shared.report(request) { response in
            var result: Result<Void, LMFeedError>
            if response.success {
                result = .success(())
            } else {
                result = .failure(.reportFailed(error: response.errorMessage))
            }
            
            completion?(result)
        }
    }
}
