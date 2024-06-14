//
//  Constants+Strings.swift
//  LMFramework
//
//  Created by Devansh Mohata on 07/12/23.
//

import Foundation

public extension Constants {
    struct Strings {
        private init() { }
        
        // Shared Instance
        public static var shared = Strings()
        
        public var taggingCharacter: Character = "@"
        
        public var like = "Like"
        public var likes = "Likes"
        public var reply = "Reply"
        public var replies = "Replies"
        
        public var allTopics = "All Topics"
        
        public var comment = "Comment"
        public var comments = "Comments"
        public var noCommentsFound = "No Comments Found"
        public var beFirstComment = "Be the first one to create a comment"
        
        public var noPostsFound = "No posts to show"
        public var beFirstPost = "Be the first on to post here"
        public var newPost = "New Post"
        
        public var noResultsFound = "No Results Found!"
        public var noNotificationFound = "Oops! You don't have any notifications yet."
        
        public var searchTopic = "Search Topic"
        public var selectTopic = "Select Topic"
        
        public var deleteComment = "Delete Comment?"
        public var deleteCommentReview = "Are you sure you want to delete this comment? This action cannot be reversed."
        
        public var submitVote = "Submti Vote"
    }
}
