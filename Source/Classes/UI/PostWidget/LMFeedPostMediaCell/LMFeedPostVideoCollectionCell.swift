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
        let videoURL: String
    }
    
    // MARK: UI Elements
    open private(set) lazy var videoPlayer: AVPlayerViewController = {
        let player = AVPlayerViewController()
        player.view.translatesAutoresizingMaskIntoConstraints = false
        player.showsPlaybackControls = true
        return player
    }()
    
    open override func prepareForReuse() {
        super.prepareForReuse()
        pauseVideo()
    }
    
    // MARK: View Hierachy
    public override func setupViews() {
        super.setupViews()
        
        contentView.addSubview(videoPlayer.view)
    }
    
    // MARK: Constraints
    open override func setupLayouts() {
        super.setupLayouts()
        
        NSLayoutConstraint.activate([
            videoPlayer.view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            videoPlayer.view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            videoPlayer.view.topAnchor.constraint(equalTo: contentView.topAnchor),
            videoPlayer.view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    open override func setupAppearance() {
        super.setupAppearance()
        
        backgroundColor = .clear
        contentView.backgroundColor = .black
    }
    
    // MARK: Configure Method
    open func configure(with data: ViewModel) {
        guard let url = URL(string: data.videoURL) else { return }
        DispatchQueue.global(qos: .background).async {
            let player = AVPlayer(url: url)
            
            DispatchQueue.main.async { [weak self] in
                self?.videoPlayer.player = player
                self?.playVideo()
            }
        }
        videoPlayer.player = .init(url: url)
    }
    
    open func playVideo() {
        videoPlayer.player?.play()
    }
    
    open func pauseVideo() {
        videoPlayer.player?.pause()
    }
}
