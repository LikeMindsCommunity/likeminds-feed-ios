//
//  LMFeedLinkPreviewDataModel.swift
//  lm-feedCore-iOS
//
//  Created by Devansh Mohata on 23/01/24.
//

public struct LMFeedLinkPreviewDataModel {
    let url: String
    let imagePreview: String?
    let title: String?
    let description: String?
    
    public init(url: String, imagePreview: String?, title: String?, description: String?) {
        self.url = url
        self.imagePreview = imagePreview
        self.title = title
        self.description = description
    }
}
