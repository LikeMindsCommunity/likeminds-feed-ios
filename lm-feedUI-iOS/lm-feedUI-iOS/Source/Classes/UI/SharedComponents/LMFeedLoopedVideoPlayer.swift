//
//  LMFeedLoopedVideoPlayer.swift
//  lm-feedUI-iOS
//
//  Created by Devansh Mohata on 16/02/24.
//

import AVFoundation
import AVKit

public final class LMFeedLoopedVideoPlayer: UIView {
    public var videoURL: URL?
    public var postID: String?
    public var videoPlayerController: AVPlayerViewController?
    public var playerLayer: AVPlayerLayer?
    
    func prepareVideo(_ videoURL: URL,_ postID: String,_ index: Int = 0) {
        
        self.postID = postID
        
        let request = LMFeedGetVideoControllerRequest.Builder()
            .setPostId(postID)
            .setVideoSource(videoURL.absoluteString)
            .setPosition(index)
            .setVideoType(.network)
            .setAutoPlay(false)
            .build()
        
        if let response = LMFeedVideoProvider.shared.videoController(for: request) {
            self.videoPlayerController = response.videoPlayerController
            self.playerLayer = AVPlayerLayer(player: response.videoPlayerController.player)
            
            if let playerLayer {
                playerLayer.videoGravity = .resizeAspectFill
                playerLayer.frame = self.frame
                self.layer.addSublayer(playerLayer)
            }
        }
    }
    
    func play() {
        if videoPlayerController == nil {
            guard let videoURL else {
                return
            }
            prepareVideo(videoURL, postID ?? "")
        }
        videoPlayerController?.player?.isMuted = LMFeedVideoProvider.isMuted
        videoPlayerController?.player?.play()
    }
    
    func pause() {
        self.videoPlayerController?.player?.pause()
    }
    
    func stop() {
        pause()
        self.videoPlayerController?.player?.seek(to: CMTime(seconds: 0, preferredTimescale: 1))
    }
    
    func unload() {
        self.playerLayer?.removeFromSuperlayer()
        self.videoPlayerController?.player = nil
        self.playerLayer = nil
    }
    
    func toggleVolumeState(){
        videoPlayerController?.player?.isMuted = LMFeedVideoProvider.isMuted
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public override func layoutSubviews() {
        self.playerLayer?.frame = self.bounds
    }
}
