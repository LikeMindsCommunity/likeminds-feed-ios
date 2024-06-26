//
//  LMStringConstants.swift
//  lm-feedCore-iOS
//
//  Created by Devansh Mohata on 30/01/24.
//

import Foundation

public struct LMStringConstants {
    private init() { }
    
    public static var shared = Self()
    
    public var appName = "LM Feed"
    public var genericErrorMessage = "Something went wrong!"
    public var maxUploadSizeErrorMessage = "Max Upload Size is %d MB"
    public var doneText = "Done"
    public var oKText = "OK"
    
    // CreatePost Strings
    public var createPostNavTitle = "Create a Post"
    public var addMoreText = "Add More"
    public var addPhotoText = "Add Photo"
    public var addVideoText = "Add Video"
    public var attachFiles = "Attach Files"
    public var addPoll = "Add Poll"
}
