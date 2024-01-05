//
//  LMFeedPostVideoCollectionCell.swift
//  LMFramework
//
//  Created by Devansh Mohata on 02/12/23.
//

import AVKit
import UIKit

@IBDesignable
open class LMFeedPostVideoCollectionCell: LMCollectionViewCell {
    public struct ViewModel: LMFeedMediaProtocol {
        public let videoURL: String
        
        public init(videoURL: String) {
            self.videoURL = videoURL
        }
    }
    
    private var videoPlayer: AVPlayerViewController?
    
    open override func prepareForReuse() {
        super.prepareForReuse()
        pauseVideo()
        videoPlayer = nil
    }
    
    // MARK: View Hierachy
    public override func setupViews() {
        super.setupViews()
        
        contentView.addSubview(containerView)
    }
    
    // MARK: Constraints
    open override func setupLayouts() {
        super.setupLayouts()
        
        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    open override func setupAppearance() {
        super.setupAppearance()
        
        backgroundColor = .clear
        contentView.backgroundColor = .black
    }
    
    // MARK: Configure Method
    open func configure(with data: ViewModel, videoPlayer: AVPlayerViewController) {
        self.videoPlayer = videoPlayer
        containerView.addSubview(videoPlayer.view)
        
        NSLayoutConstraint.activate([
            videoPlayer.view.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            videoPlayer.view.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            videoPlayer.view.topAnchor.constraint(equalTo: containerView.topAnchor),
            videoPlayer.view.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
        
        guard let url = URL(string: data.videoURL) else { return }
        DispatchQueue.global(qos: .background).async {
            let player = AVPlayer(url: url)
            
            DispatchQueue.main.async { [weak self] in
                self?.videoPlayer?.player = player
                self?.playVideo()
            }
        }
    }
    
    open func playVideo() {
        videoPlayer?.player?.play()
    }
    
    open func pauseVideo() {
        videoPlayer?.player?.pause()
    }
}
