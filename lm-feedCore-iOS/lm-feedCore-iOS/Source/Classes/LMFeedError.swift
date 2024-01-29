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
    
    case postCreationFailed(error: String?)
    case postEditFailed(error: String?)
    
    case routeError(error: String)
}
