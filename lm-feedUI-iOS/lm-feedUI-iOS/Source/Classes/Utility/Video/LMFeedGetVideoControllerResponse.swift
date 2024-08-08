//
//  LMFeedGetVideoControllerResponse.swift
//  LikeMindsFeedUI
//
//  Created by Anurag Tyagi on 01/08/24.
//

import Foundation
import AVKit

/// A class that represents the response containing video controller information for a post in a feed.
///
/// This class holds details about the video player controller associated with a specific post in a feed, including
/// identifiers for the controller and post, the index of the post in the feed, and the video player controller itself.
public class LMFeedGetVideoControllerResponse {
    /// The unique identifier for the video controller.
    var controllerId: String
    
    /// The unique identifier for the post.
    var postId: String
    
    /// The index of the post in the feed.
    var index: Int
    
    /// The video player controller used to play the video.
    var videoPlayerController: AVPlayerViewController
    
    /// Initializes a new instance of `LMFeedGetVideoControllerResponse`.
    ///
    /// - Parameters:
    ///   - controllerId: A unique identifier for the video controller.
    ///   - postId: A unique identifier for the post.
    ///   - index: The index of the post within the feed.
    ///   - videoPlayerController: The `AVPlayerViewController` instance used to control the video playback.
    ///
    /// - Returns: An initialized instance of `LMFeedGetVideoControllerResponse`.
    ///
    /// # Example
    /// ```
    /// let playerController = AVPlayerViewController()
    /// let response = LMFeedGetVideoControllerResponse(
    ///     controllerId: "controller123",
    ///     postId: "post456",
    ///     index: 0,
    ///     videoPlayerController: playerController
    /// )
    /// ```
    init(controllerId: String, postId: String, index: Int, videoPlayerController: AVPlayerViewController) {
        self.controllerId = controllerId
        self.postId = postId
        self.index = index
        self.videoPlayerController = videoPlayerController
    }
}

