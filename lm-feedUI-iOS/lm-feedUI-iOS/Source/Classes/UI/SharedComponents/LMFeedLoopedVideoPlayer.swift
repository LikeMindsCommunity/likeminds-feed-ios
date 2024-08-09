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
    public var videoPlayerController: AVPlayerViewController?
    public var playerLayer: AVPlayerLayer?
    
    func prepareVideo(_ videoURL: URL) {
        
        let request = LMFeedGetVideoControllerRequest.Builder()
            .setPostId(UUID().uuidString)
            .setVideoSource(videoURL.absoluteString)
            .setPosition(0)
            .setVideoType(.network)
            .setAutoPlay(false)
            .build()
        
        if let response = LMFeedVideoProvider.shared.videoController(for: request) {
            self.videoPlayerController = response.videoPlayerController
            self.playerLayer = AVPlayerLayer(player: response.videoPlayerController.player)
            
            if let playerLayer = self.playerLayer {
                playerLayer.videoGravity = .resizeAspectFill
                playerLayer.frame = self.frame
                self.layer.addSublayer(playerLayer)
            }
        }
    }
    
    func play() {
        self.videoPlayerController?.player?.play()
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
