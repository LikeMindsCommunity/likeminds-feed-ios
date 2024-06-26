//
//  LMFeedError.swift
//  lm-feedCore-iOS
//
//  Created by Devansh Mohata on 24/01/24.
//

import Foundation

public enum LMFeedError: Error {
    case apiInitializationFailed(error: String?)
    case appAccessFalse
    case feedNotInitialized
    
    case commentDeleteFailed(error: String?),
         postDeleteFailed(error: String?)
    
    case postCreationFailed(error: String?)
    case postEditFailed(error: String?)
    
    case reportFailed(error: String?)
    
    case routeError(error: String?)

    case notificationRegisterationFailed(error: String?)
    case logoutFailed(error: String?)
    
    case addPollOptionFailed(error: String?)
    
    public var localizedDescription: String {
        switch self {
        case .apiInitializationFailed(let error),
                .commentDeleteFailed(let error),
                .notificationRegisterationFailed(let error),
                .logoutFailed(let error),
                .postCreationFailed(let error),
                .postDeleteFailed(let error),
                .postEditFailed(let error),
                .reportFailed(let error),
                .routeError(let error),
                .addPollOptionFailed(let error):
            return error ?? LMStringConstants.shared.genericErrorMessage
        case .appAccessFalse:
            return "User does not have right access for app usage"
        case .feedNotInitialized:
            return "LikeMinds Feed has not been initialized"
        }
    }
}
