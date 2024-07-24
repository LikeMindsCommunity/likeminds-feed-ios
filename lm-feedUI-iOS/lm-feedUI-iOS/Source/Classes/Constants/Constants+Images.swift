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

public extension Constants {
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
        public var paperclipIcon = loadImage(with: "paperclip")
        public var createPostIcon = loadImage(with: "createPostIcon")
        public var emptyViewIcon = loadImage(with: "emptyView")
        public var docImageIcon = loadImage(with: "docTexImage")
        public var addPollIcon = loadImage(with: "addpoll")
        
        public var ellipsisIcon = loadSystemImage(with: "ellipsis")
        public var ellipsisCircleIcon = loadSystemImage(with: "ellipsis.circle")
        public var paperplaneFilled = loadSystemImage(with: "paperplane.fill")
        public var paperplaneIcon = loadSystemImage(with: "paperplane")
        public var micIcon = loadSystemImage(with: "mic")
        public var micFillIcon = loadSystemImage(with: "mic.fill")
        public var audioIcon = loadSystemImage(with: "headphones")
        public var photoPlusIcon = loadImage(with: "photo.badge.plus")
        public var videoSystemIcon = loadSystemImage(with: "video.fill")
        public var copyIcon = loadSystemImage(with: "doc.on.doc")
        
        public var gifBadgeIcon = loadImage(with: "gifBadge")
        
        public var lockFillIcon = loadSystemImage(with: "lock.fill")
        public var annoucementIcon = loadSystemImage(with: "speaker.zzz.fill")
        public var personCircleFillIcon = loadSystemImage(with: "person.circle.fill")
        public var muteFillIcon = loadSystemImage(with: "speaker.slash.fill")
        public var tagFillIcon = loadSystemImage(with: "tag.fill")
        public var rightArrowIcon = loadSystemImage(with: "chevron.right")
        public var checkmarkCircleIcon = loadSystemImage(with: "checkmark.circle")
        public var leftArrowIcon = loadSystemImage(with: "chevron.left")
        public var downChevronArrowIcon = loadSystemImage(with: "chevron.down")
        public var upChevronArrowIcon = loadSystemImage(with: "chevron.up")
        
        public var cameraIcon = loadSystemImage(with: "camera")
        public var playIcon = loadSystemImage(with: "play.circle")
        public var pauseCircleIcon = loadSystemImage(with: "pause.circle")
        public var goForwardIcon = loadSystemImage(with: "goforward.10")
        public var goBackwardIcon = loadSystemImage(with: "gobackward.10")
        public var playFill = loadSystemImage(with: "play.fill")
        public var pauseIcon = loadSystemImage(with: "pause.fill")
        public var linkCircleFillIcon = loadSystemImage(with: "link.circle.fill")
        public var linkIcon = loadSystemImage(with: "link")
        public var messageIcon = loadSystemImage(with: "message")
        public var person2Icon = loadSystemImage(with: "person.2")
        public var pinCircleFillIcon = loadSystemImage(with: "pin.circle.fill")
        public var pinCircleIcon = loadSystemImage(with: "pin.circle")
        public var downArrowIcon = loadSystemImage(with: "arrow.down")
        public var sendButton = loadSystemImage(with: "paperplane.circle.fill")
        public var stopRecordButton = loadSystemImage(with: "stop.circle")
        public var deleteIcon = loadSystemImage(with: "trash.fill")
        public var playFilled = loadSystemImage(with: "play.fill")
        public var playCircleFilled = loadSystemImage(with: "play.circle.fill")
        public var pauseCircleFilled = loadSystemImage(with: "pause.circle.fill")
        public var replyIcon = loadSystemImage(with: "arrowshape.turn.up.backward.fill")
        public var pollIcon = loadSystemImage(with: "chart.bar.xaxis")
        public var trashIcon = loadSystemImage(with: "trash")
        
        
        public var docPlusIcon = loadSystemImage(with: "doc.badge.plus")
        public var clockIcon = loadSystemImage(with: "clock")
        public var checkmarkIcon = loadSystemImage(with: "checkmark")
        public var retryIcon = loadSystemImage(with: "exclamationmark.circle.fill")
        
        public var noDataImage = loadImage(with: "noDataImage")
        public var bubbleReceived = loadImage(with: "bubble_received")
        public var bubbleSent = loadImage(with: "bubble_sent")
        public var gifBadge = loadImage(with: "gifBadge")
        public var addMoreEmojiIcon = loadImage(with: "addMoreEmoticons")
        public var circleFill = loadSystemImage(with: "circle.fill")
        public var newDMIcon = loadImage(with: "newdm-icon")
    }
}
