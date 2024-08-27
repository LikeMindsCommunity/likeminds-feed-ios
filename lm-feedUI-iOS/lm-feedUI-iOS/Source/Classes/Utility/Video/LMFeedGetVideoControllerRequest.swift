//
//  LMFeedGetVideoControllerRequest.swift
//  LikeMindsFeedUI
//
//  Created by Anurag Tyagi on 01/08/24.
//

import Foundation

/// A class representing a request to get a video controller for a specific post in the feed.
public class LMFeedGetVideoControllerRequest {
    let postId: String
    let videoSource: String?
    let videoBytes: Data?
    let position: Int
    let videoType: LMFeedVideoSourceType
    let autoPlay: Bool

    /// Private initializer to enforce the use of the builder for object creation.
    private init(postId: String, videoSource: String?, videoBytes: Data?, position: Int, videoType: LMFeedVideoSourceType, autoPlay: Bool) {
        self.postId = postId
        self.videoSource = videoSource
        self.videoBytes = videoBytes
        self.position = position
        self.videoType = videoType
        self.autoPlay = autoPlay
    }

    /// Builder class for constructing `LMFeedGetVideoControllerRequest` instances.
    public class Builder {
        private var postId: String = ""
        private var videoSource: String? = nil
        private var videoBytes: Data? = nil
        private var position: Int = 0
        private var videoType: LMFeedVideoSourceType = .network
        private var autoPlay: Bool = false

        /// Sets the post ID.
        ///
        /// - Parameter postId: The unique identifier for the post.
        /// - Returns: The builder instance for chaining.
        public func setPostId(_ postId: String) -> Builder {
            self.postId = postId
            return self
        }

        /// Sets the video source URL.
        ///
        /// - Parameter videoSource: The URL of the video as a string.
        /// - Returns: The builder instance for chaining.
        public func setVideoSource(_ videoSource: String?) -> Builder {
            self.videoSource = videoSource
            return self
        }

        /// Sets the video data in bytes.
        ///
        /// - Parameter videoBytes: The video data as raw bytes.
        /// - Returns: The builder instance for chaining.
        public func setVideoBytes(_ videoBytes: Data?) -> Builder {
            self.videoBytes = videoBytes
            return self
        }

        /// Sets the position of the post in the feed.
        ///
        /// - Parameter position: The position index.
        /// - Returns: The builder instance for chaining.
        public func setPosition(_ position: Int) -> Builder {
            self.position = position
            return self
        }

        /// Sets the type of the video source.
        ///
        /// - Parameter videoType: The type of the video source.
        /// - Returns: The builder instance for chaining.
        public func setVideoType(_ videoType: LMFeedVideoSourceType) -> Builder {
            self.videoType = videoType
            return self
        }

        /// Sets whether the video should auto-play.
        ///
        /// - Parameter autoPlay: A boolean indicating auto-play preference.
        /// - Returns: The builder instance for chaining.
        public func setAutoPlay(_ autoPlay: Bool) -> Builder {
            self.autoPlay = autoPlay
            return self
        }

        /// Builds and returns an instance of `LMFeedGetVideoControllerRequest`.
        ///
        /// - Returns: A fully configured `LMFeedGetVideoControllerRequest` instance.
        public func build() -> LMFeedGetVideoControllerRequest {
            return LMFeedGetVideoControllerRequest(
                postId: self.postId,
                videoSource: self.videoSource,
                videoBytes: self.videoBytes,
                position: self.position,
                videoType: self.videoType,
                autoPlay: self.autoPlay
            )
        }
    }
}

