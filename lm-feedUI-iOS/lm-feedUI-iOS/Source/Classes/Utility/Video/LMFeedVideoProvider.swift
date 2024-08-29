//
//  VideoProvider.swift
//  LikeMindsFeedUI
//
//  Created by Anurag Tyagi on 01/08/24.
//

import Foundation
import AVKit

/// Enum representing the type of video source
public enum LMFeedVideoSourceType {
    case network  // Video is accessed from a network URL
    case path     // Video is accessed from a local file path
    case bytes    // Video data is provided as raw bytes
}

/// Class for managing video controllers for posts
public class LMFeedVideoProvider {
    /// Static property to control mute state of all video controllers
    static var isMuted = false {
        didSet {
            NotificationCenter.default.post(name: .volumeStateChanged, object: nil, userInfo: ["isMuted": isMuted])
        }
    }
    
    /// Shared instance for singleton access
    static let shared = LMFeedVideoProvider()
    
    /// Maximum size of a video in bytes (100MB)
    private let maxVideoSize: Int64 = 100 * 1024 * 1024
    
    /// Maximum number of controllers that can be stored in the cache
    private let maxCacheSize = 3
    
    /// LRU cache for storing video controllers
    private let cache = NSCache<NSString, AVPlayerViewController>()
    
    /// Array to keep track of cache keys in order of use (most recent first)
    private var cacheOrder: [String] = []
    
    /// Private initializer to enforce singleton pattern
    private init() {}
    
    /**
     Fetches or creates a video controller response for the given request.
     
     This method first checks the cache, and creates a new controller if needed.
     If the cache is full, it will remove the least recently used controller.
     
     - Parameter request: The `LMFeedGetVideoControllerRequest` containing details about the requested video
     - Returns: An `LMFeedGetVideoControllerResponse` if successful, `nil` otherwise
     
     Example usage:
     ```
     let request = LMFeedGetVideoControllerRequest(postId: "123", position: 0, videoSource: "https://example.com/video.mp4", videoType: .network, autoPlay: true)
     if let response = LMFeedVideoProvider.shared.videoController(for: request) {
     // Use the response's video player controller
     present(response.videoPlayerController, animated: true)
     }
     ```
     */
    func videoController(for request: LMFeedGetVideoControllerRequest) -> LMFeedGetVideoControllerResponse? {
        let key = "\(request.postId)-\(request.position)"
        
        // Check cache first
        if let cachedController = cache.object(forKey: key as NSString) {
            updateCacheOrder(key)
            return LMFeedGetVideoControllerResponse(
                controllerId: key,
                postId: request.postId,
                index: request.position,
                videoPlayerController: cachedController
            )
        }
        
        // Create new controller if not found
        guard let controller = createVideoController(for: request) else {
            return nil
        }
        
        // Check if cache is full
        if cacheOrder.count >= maxCacheSize {
            removeLeastRecentlyUsedController()
        }
        
        // Add to cache
        cache.setObject(controller, forKey: key as NSString)
        cacheOrder.insert(key, at: 0)
        
        return LMFeedGetVideoControllerResponse(
            controllerId: key,
            postId: request.postId,
            index: request.position,
            videoPlayerController: controller
        )
    }
    
    /**
     Creates a new video controller based on the given request.
     
     - Parameter request: The LMFeedGetVideoControllerRequest containing details about the video
     - Returns: An AVPlayerViewController if successful, nil otherwise
     */
    private func createVideoController(for request: LMFeedGetVideoControllerRequest) -> AVPlayerViewController? {
        var playerItem: AVPlayerItem?
        
        switch request.videoType {
        case .network:
            guard let urlString = request.videoSource, let url = URL(string: urlString) else {
                return nil
            }
            playerItem = AVPlayerItem(url: url)
            
        case .path:
            guard let path = request.videoSource else {
                return nil
            }
            let url = URL(fileURLWithPath: path)
            playerItem = AVPlayerItem(url: url)
            
        case .bytes:
            guard let data = request.videoBytes else {
                return nil
            }
            let asset = AVAsset(url: createTemporaryURL(with: data))
            playerItem = AVPlayerItem(asset: asset)
        }
        
        guard let item = playerItem else {
            return nil
        }
        
        let player = AVPlayer(playerItem: item)
        let controller = AVPlayerViewController()
        controller.player = player
        
        if request.autoPlay {
            player.play()
        }
        
        return controller
    }
    
    /**
     Creates a temporary URL for video data.
     
     - Parameter data: The video data
     - Returns: A URL pointing to the temporary file
     */
    private func createTemporaryURL(with data: Data) -> URL {
        let temporaryDirectoryURL = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
        let temporaryFileURL = temporaryDirectoryURL.appendingPathComponent(UUID().uuidString).appendingPathExtension("mp4")
        try? data.write(to: temporaryFileURL)
        return temporaryFileURL
    }
    
    /**
     Updates the order of cache keys, moving the given key to the front.
     
     - Parameter key: The cache key to update
     */
    private func updateCacheOrder(_ key: String) {
        if let index = cacheOrder.firstIndex(of: key) {
            cacheOrder.remove(at: index)
        }
        cacheOrder.insert(key, at: 0)
    }
    
    /**
     Removes the least recently used controller from the cache.
     */
    private func removeLeastRecentlyUsedController() {
        guard let leastRecentKey = cacheOrder.last else { return }
        cache.removeObject(forKey: leastRecentKey as NSString)
        cacheOrder.removeLast()
    }
    
    /**
     Clears the video controller for a specific post.
     
     This method stops playback and removes the controller from the cache.
     
     - Parameter postId: The ID of the post whose controller should be cleared
     
     Example usage:
     ```
     LMFeedPostVideoProvider.shared.clearController(for: "123")
     ```
     */
    func clearController(for postId: String) {
        cacheOrder = cacheOrder.filter { key in
            if key.starts(with: postId) {
                if let controller = cache.object(forKey: key as NSString) {
                    controller.player?.pause()
                    controller.player = nil
                }
                cache.removeObject(forKey: key as NSString)
                return false
            }
            return true
        }
    }
    
    /**
     Pauses playback on all active video controllers.
     
     Example usage:
     ```
     LMFeedPostVideoProvider.shared.pauseAllControllers()
     ```
     */
    func pauseAllControllers() {
        cacheOrder.forEach { key in
            cache.object(forKey: key as NSString)?.player?.pause()
        }
    }
}

extension Notification.Name {
    static let volumeStateChanged = Notification.Name("volumeStateChanged")
}
