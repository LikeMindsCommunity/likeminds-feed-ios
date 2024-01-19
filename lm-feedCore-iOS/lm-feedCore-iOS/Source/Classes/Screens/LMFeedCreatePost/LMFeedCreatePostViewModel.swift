//
//  LMFeedCreatePostViewModel.swift
//  lm-feedCore-iOS
//
//  Created by Devansh Mohata on 18/01/24.
//

import lm_feedUI_iOS
import LikeMindsFeed

public protocol LMFeedCreatePostViewModelProtocol: AnyObject { }

public final class LMFeedCreatePostViewModel {
    public struct Attachment {
        let url: String
        let mediaType: AttachmentType
        
        public init(url: String, mediaType: AttachmentType) {
            self.url = url
            self.mediaType = mediaType
        }
    }
    
    public enum AttachmentType {
        case image,
             video,
             document,
             none
    }
    
    // MARK: Data Variables
    public var media: [Attachment]
    public var currentMediaSelectionType: AttachmentType
    public weak var delegate: LMFeedCreatePostViewModelProtocol?
    
    init(delegate: LMFeedCreatePostViewModelProtocol?) {
        currentMediaSelectionType = .none
        media = []
        self.delegate = delegate
    }
    
    public static func createModule() -> LMFeedCreatePostViewController {
        let viewcontroller = Components.shared.createPostScreen.init()
        let viewModel = LMFeedCreatePostViewModel(delegate: viewcontroller)
        
        viewcontroller.viewModel = viewModel
        return viewcontroller
    }
}
