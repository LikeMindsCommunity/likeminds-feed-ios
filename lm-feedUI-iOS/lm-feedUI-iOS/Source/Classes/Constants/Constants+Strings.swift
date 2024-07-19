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
        public var reply = "Reply"
        public var replies = "Replies"
        
        public var allTopics = "All Topics"
        
        public var noResultsFound = "No Results Found!"
        public var noNotificationFound = "Oops! You don't have any notifications yet."
        
        public var searchTopic = "Search Topic"
        public var selectTopic = "Select Topic"
        
        public var submitVote = "Submit Vote"
        public var submit = "Submit"
    }
}
