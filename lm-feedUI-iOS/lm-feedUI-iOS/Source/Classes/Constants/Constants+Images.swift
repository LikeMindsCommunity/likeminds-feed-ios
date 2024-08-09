//
//  Constants+Images.swift
//  LMFramework
//
//  Created by Devansh Mohata on 12/12/23.
//

import UIKit

extension UIImage {
    convenience init?(named name: String, in bundle: Bundle) {
        self.init(named: name, in: bundle, compatibleWith: nil)
    }
}

public extension LMFeedConstants {
    struct Images {
        private init() { }
        
        /// Need For These Methods - A Develeoper can also set custom images in these variables we need to make sure that dev is not setting these images as nil, so get non-optional value of UIImage without force unwrapping.
        static func loadImage(with imageName: String) -> UIImage {
            UIImage(named: imageName, in: Bundle.LMBundleIdentifier) ?? .circleImage
        }
        
        static func loadSystemImage(with imageName: String) -> UIImage {
            UIImage(systemName: imageName) ?? .circleImage
        }
        
        // Shared Instance
        public static var shared = Images()
        
        // Images
        public var heart = loadSystemImage(with: "heart")
        public var heartFilled = loadSystemImage(with: "heart.fill")
        public var commentIcon = loadSystemImage(with: "message")
        public var bookmark = loadSystemImage(with: "bookmark")
        public var bookmarkFilled = loadSystemImage(with: "bookmark.fill")
        public var shareIcon = loadSystemImage(with: "arrowshape.turn.up.right")
        public var xmarkIcon = loadSystemImage(with: "xmark")
        public var crossIcon = loadSystemImage(with: "xmark.circle")
        public var ellipsis = loadSystemImage(with: "ellipsis")
        public var planeIconFilled = loadSystemImage(with: "paperplane.fill")
        public var downArrow = loadSystemImage(with: "arrow.down")
        public var downArrowFilled = loadSystemImage(with: "arrowtriangle.down.fill")
        public var menuIcon = loadSystemImage(with: "line.3.horizontal")
        public var personIcon = loadSystemImage(with: "person")
        public var checkmarkIconFilled = loadSystemImage(with: "checkmark.circle.fill")
        public var plusIcon = loadSystemImage(with: "plus")
        public var plusCircleIcon = loadSystemImage(with: "plus.circle")
        public var notificationBell = loadSystemImage(with: "bell.fill")
        public var documentsIcon = loadSystemImage(with: "doc.fill")
        public var galleryIcon = loadSystemImage(with: "photo")
        public var equalIcon = loadSystemImage(with: "equal")
        public var chevronDownIcon = loadSystemImage(with: "chevron.down")
        public var chevronUpIcon = loadSystemImage(with: "chevron.up")
        public var searchIcon = loadSystemImage(with: "magnifyingglass")
        
        public var pencilIcon = loadImage(with: "editIcon")
        public var pdfIcon = loadImage(with: "pdfIcon")
        public var placeholderImage = loadImage(with: "placeholderImage")
        public var brokenLink = loadImage(with: "brokenLink")
        public var videoIcon = loadImage(with: "videoIcon")
        public var paperclipIcon = loadImage(with: "paperClip")
        public var createPostIcon = loadImage(with: "createPostIcon")
        public var emptyViewIcon = loadImage(with: "emptyView")
        public var docImageIcon = loadImage(with: "docTexImage")
        public var addPollIcon = loadImage(with: "addpoll")
        public var upvoteIcon = loadImage(with: "upvote")
        public var upvoteFilledIcon = loadImage(with: "upvotefilled")
    }
}
