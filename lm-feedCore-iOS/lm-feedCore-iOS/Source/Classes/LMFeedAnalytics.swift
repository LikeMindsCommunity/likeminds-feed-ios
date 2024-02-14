//
//  LMFeedAnalytics.swift
//  lm-feedCore-iOS
//
//  Created by Devansh Mohata on 05/02/24.
//

// MARK: LMFeedAnalyticsEventName
public enum LMFeedAnalyticsEventName: CustomStringConvertible {
    // Notification Analytics
    case notificationPageOpened,
         notificationRemoved,
         notificationMuted
    
    // Feed Analytics
    case feedOpened
    
    
    // Post Creation Analytics
    case postCreationStarted,
         postCreationAttachmentClicked,
         postCreationUserTagged,
         postCreationLinkAttached,
         postCreationImageAttached,
         postCreationVideoAttached,
         postCreationDocumentAttached,
         postCreationCompleted
    
    
    // Post Analytics
    case postPinned,
         postUnpinned,
         postEdited,
         postReported,
         postDeleted,
         postLikeListOpened
    
    
    // Comment Analytics
    case commentListOpened,
         commentDeleted,
         commentReported,
         commentPosted,
         commentReplyPosted,
         commentReplyDeleted,
         commentReplyReported
    
    
    public var description: String {
        switch self {
        case .notificationPageOpened:
            return "Notification page opened"
        case .notificationRemoved:
            return "Notification removed"
        case .notificationMuted:
            return "Notification muted"
        
        case .feedOpened:
            return "Feed opened"
            
        case .postCreationStarted:
            return "Post creation started"
        case .postCreationAttachmentClicked:
            return "Clicked on Attachment"
        case .postCreationUserTagged:
            return "User tagged in a post"
        case .postCreationLinkAttached:
            return "Link attached in the post"
        case .postCreationImageAttached:
            return "Image attached to post"
        case .postCreationVideoAttached:
            return "Video attached to post"
        case .postCreationDocumentAttached:
            return "Document attached in post"
        case .postCreationCompleted:
            return "Post creation completed"
            
        case .postPinned:
            return "Post pinned"
        case .postUnpinned:
            return "Post unpinned"
        case .postEdited:
            return "Post edited"
        case .postReported:
            return "Post reported"
        case .postDeleted:
            return "Post deleted"
        case .postLikeListOpened:
            return "Like list open"
            
        case .commentListOpened:
            return "Comment list open"
        case .commentDeleted:
            return "Comment deleted"
        case .commentReported:
            return "Comment reported"
        case .commentPosted:
            return "Comment posted"
        case .commentReplyPosted:
            return "Reply posted"
        case .commentReplyDeleted:
            return "Reply deleted"
        case .commentReplyReported:
            return "Reply reported"
        }
    }
}


// MARK: LMFeedAnalyticsProtocol
public protocol LMFeedAnalyticsProtocol {
    func trackEvent(for eventName: LMFeedAnalyticsEventName, eventProperties: [String: AnyHashable])
}