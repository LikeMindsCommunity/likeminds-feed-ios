//
//  LMFeedLoopedVideoPlayer.swift
//  lm-feedUI-iOS
//
//  Created by Devansh Mohata on 16/02/24.
//

import AVFoundation

public final class LMFeedLoopedVideoPlayer: UIView {
    public var videoURL: URL?
    public var queuePlayer: AVQueuePlayer?
    public var playerLayer: AVPlayerLayer?
    public var playbackLooper: AVPlayerLooper?
    
    func prepareVideo(_ videoURL: URL) {
        if queuePlayer == nil,
           playerLayer == nil,
           playbackLooper == nil {
            let playerItem = AVPlayerItem(url: videoURL)
            
            self.queuePlayer = AVQueuePlayer(playerItem: playerItem)
            self.playerLayer = AVPlayerLayer(player: self.queuePlayer)
            
            if let queuePlayer {
                self.playbackLooper = AVPlayerLooper.init(player: queuePlayer, templateItem: playerItem)
            }
        }
        
        guard let playerLayer else { return }
        
        playerLayer.videoGravity = .resizeAspectFill
        playerLayer.frame = self.frame
        self.layer.addSublayer(playerLayer)
        
        play()
    }
    
   func play() {
        self.queuePlayer?.play()
    }
    
    func pause() {
        self.queuePlayer?.pause()
    }
    
    func stop() {
        pause()
        self.queuePlayer?.seek(to: CMTime.init(seconds: 0, preferredTimescale: 1))
    }
    
    func unload() {
        print(#function, #file)
        self.playerLayer?.removeFromSuperlayer()
        queuePlayer?.replaceCurrentItem(with: nil)
        self.playerLayer = nil
        self.queuePlayer = nil
        self.playbackLooper = nil
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
