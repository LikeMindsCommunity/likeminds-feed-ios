//
//  LMStringConstants.swift
//  lm-feedCore-iOS
//
//  Created by Devansh Mohata on 30/01/24.
//

import Foundation

public struct LMStringConstants {
    private init() { }
    
    enum WordAction: Int {
        case firstLetterCapitalSingular
        case allCapitalSingular
        case allSmallSingular
        case firstLetterCapitalPlural
        case allCapitalPlural
        case allSmallPlural
    }
    
    func pluralizeOrCapitalize(to value: String, withAction action: WordAction) -> String {
        switch action {
        case .firstLetterCapitalSingular:
            return value.capitalized
        case .allCapitalSingular:
            return value.uppercased()
        case .allSmallSingular:
            return value.lowercased()
        case .firstLetterCapitalPlural:
            return value.pluralize().capitalized
        case .allCapitalPlural:
            return value.pluralize().uppercased()
        case .allSmallPlural:
            return value.pluralize().lowercased()
        }
    }
    
    
    public var postVariable: String {
        (LocalPreferences.communityConfiguration?.configs.first(where: { $0.type == "feed_metadata" })?.value?.post ?? "post").capitalized
    }
    
    public var commentVariable: String {
        (LocalPreferences.communityConfiguration?.configs.first(where: { $0.type == "feed_metadata" })?.value?.comment ?? "comment").capitalized
    }
    
    public var likeVariable: String {
        (LocalPreferences.communityConfiguration?.configs.first(where: { $0.type == "feed_metadata" })?.value?.like?.entityName ?? "Like").capitalized
    }
    
    public var pastLikeVariable: String {
        (LocalPreferences.communityConfiguration?.configs.first(where: { $0.type == "feed_metadata" })?.value?.like?.pasTenseName ?? "Liked").capitalized
    }
    
    public static var shared = Self()
    
    public var appName = "LM Feed"
    public var genericErrorMessage = "Something went wrong!"
    public var maxUploadSizeErrorMessage = "Max Upload Size is %d MB"
    public var doneText = "Done"
    public var oKText = "OK"
    
    // CreatePost Strings
    public var addMoreText = "Add More"
    public var addPhotoText = "Add Photo"
    public var addVideoText = "Add Video"
    public var attachFiles = "Attach Files"
    public var addPoll = "Add Poll"
    
    public var createPostTitle: String {
        String(format: "Create a %@", pluralizeOrCapitalize(to: postVariable, withAction: .allSmallSingular))
    }
    
    public var postDetailTitle: String {
        pluralizeOrCapitalize(to: postVariable, withAction: .firstLetterCapitalSingular)
    }
    
    public var postingInProgress: String {
        String(format: "A %@ is already uploading!", pluralizeOrCapitalize(to: postVariable, withAction: .allSmallSingular))
    }
    
    public var editPost: String {
        String(format: "Edit %@", pluralizeOrCapitalize(to: postVariable, withAction: .firstLetterCapitalSingular))
    }
    
    public var unpinThisPost: String {
        String(format: "Unpin This %@", pluralizeOrCapitalize(to: postVariable, withAction: .firstLetterCapitalSingular))
    }
    public var pinThisPost: String {
        String(format: "Pin This %@", pluralizeOrCapitalize(to: postVariable, withAction: .firstLetterCapitalSingular))
    }
    public var creatingResource: String {
        String(format: "Creating %@", pluralizeOrCapitalize(to: postVariable, withAction: .firstLetterCapitalSingular))
    }
    public var newPost: String {
        String(format: "NEW %@", pluralizeOrCapitalize(to: postVariable, withAction: .allCapitalSingular))
    }
    
    public func reportSubtitle(isComment: Bool) -> String {
        String(format: "You would be able to report this %@ after selecting a problem.", pluralizeOrCapitalize(to: isComment ? commentVariable : postVariable, withAction: .allSmallSingular))
    }
    
    public var deletePost: String {
        String(format: "Delete %@", pluralizeOrCapitalize(to: postVariable, withAction: .firstLetterCapitalSingular))
    }
    
    public var deletePostMessage: String {
        String(format: "Are you sure you want to delete this %@? This action cannot be reversed", pluralizeOrCapitalize(to: postVariable, withAction: .allSmallSingular))
    }
    
    public var writeComment: String {
        String(format: "Write a %@", pluralizeOrCapitalize(to: commentVariable, withAction: .allSmallSingular))
    }
    
    public var noCommentPermission: String {
        String(format: "You do not have permission to %@", pluralizeOrCapitalize(to: commentVariable, withAction: .allSmallSingular))
    }
}
