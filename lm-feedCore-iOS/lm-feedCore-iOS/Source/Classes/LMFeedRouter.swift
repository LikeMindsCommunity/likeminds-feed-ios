//
//  LMFeedRouter.swift
//  lm-feedCore-iOS
//
//  Created by Devansh Mohata on 28/01/24.
//

import LikeMindsFeedUI

public final class LMFeedRouter {
    enum RouteHostURL: String {
        case routeToPost = "post"
        case routeToPostDetail = "post_detail"
        case routeToCreatePost = "create_post"
    }
    
    public static func fetchRoute(from cta: String, completion: ((Result<LMViewController, LMFeedError>) -> Void)) {
        guard let route = cta.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
        let url = URL(string: route),
        let host = url.host,
        let screen = RouteHostURL(rawValue: host) else {
            completion(.failure(.routeError(error: "Route URL can't be decoded")))
            return
        }
        
        switch screen {
        case .routeToPost,
                .routeToPostDetail:
            let params = fetchPostID(from: url)
            guard let postID = params.postID,
                  let viewcontroller = LMFeedPostDetailViewModel.createModule(for: postID, scrollToCommentSection: params.commentID != nil) else {
                completion(.failure(.routeError(error: "Can't extract `post_id` from the route")))
                return
            }
            
            completion(.success(viewcontroller))
        case .routeToCreatePost:
            completion(.failure(.routeError(error: "Route Not Implemented")))
        }
    }
    
    private static func fetchPostID(from route: URL) -> (postID: String?, commentID: String?) {
        let params = route.queryParameters
        return (params["post_id"], params["comment_id"])
    }
}
