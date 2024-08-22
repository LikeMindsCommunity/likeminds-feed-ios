//
//  LMFeedLoopedVideoPlayer.swift
//  lm-feedUI-iOS
//
//  Created by Devansh Mohata on 16/02/24.
//

import AVFoundation
import AVKit

public final class LMFeedLoopedVideoPlayer: UIView {
    public var data: LMFeedVideoCollectionCell.ContentModel?
    public var index: Int?
    public var videoPlayerController: AVPlayerViewController?
    public var playerLayer: AVPlayerLayer?
    public var showControls: Bool = false
    
    func prepareVideo(with data: LMFeedVideoCollectionCell.ContentModel, _ index: Int = 0, showControls: Bool = false) {
        
        self.data = data
        self.index = index
        self.showControls = showControls
        
        let request = LMFeedGetVideoControllerRequest.Builder()
            .setPostId(data.postID)
            .setVideoSource(data.videoURL)
            .setPosition(index)
            .setVideoType(.network)
            .setAutoPlay(false)
            .build()
        
        if let response = LMFeedVideoProvider.shared.videoController(for: request) {
            self.videoPlayerController = response.videoPlayerController
            self.playerLayer = AVPlayerLayer(player: response.videoPlayerController.player)
            
            self.videoPlayerController?.showsPlaybackControls = showControls
            
            self.layer.sublayers?.forEach { sublayer in
                    if sublayer is AVPlayerLayer {
                        sublayer.removeFromSuperlayer()
                    }
                }
            
            if let playerLayer {
                playerLayer.videoGravity = .resizeAspect
                playerLayer.frame = self.bounds
                
                self.layer.addSublayer(playerLayer)
            }
        }
    }
    
    func play() {
        if videoPlayerController == nil {
            guard let data else {
                return
            }
            prepareVideo(with: data, index ?? 0, showControls: showControls)
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
        super.layoutSubviews()
        self.playerLayer?.frame = self.bounds
    }
}
