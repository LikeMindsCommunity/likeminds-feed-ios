//
//  Notification+Extension.swift
//  lm-feedCore-iOS
//
//  Created by Devansh Mohata on 27/01/24.
//

import Foundation

public extension Notification.Name {
    static let LMPostCreationStarted = Notification.Name("LMPostCreationStarted")
    static let LMPostCreated = Notification.Name("LMPostCreated")
    static let LMPostCreateError = NSNotification.Name("LMPostCreateError")
    
    static let LMPostEdited = Notification.Name("LMPostEdited")
    static let LMPostEditError = NSNotification.Name("LMPostEditError")
    
    static let LMPostUpdate = Notification.Name("LMPostUpdate")
    
    static let LMPostDeleted = Notification.Name("LMPostDeleted")
    static let LMCommentDeleted = Notification.Name("LMCommentDeleted")
}
