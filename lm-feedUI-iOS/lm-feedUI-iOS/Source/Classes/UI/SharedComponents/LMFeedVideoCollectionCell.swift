//
//  LMFeedPostVideoCollectionCell.swift
//  LMFramework
//
//  Created by Devansh Mohata on 02/12/23.
//

import AVKit
import UIKit

@IBDesignable
open class LMFeedVideoCollectionCell: LMCollectionViewCell {
    public struct ViewModel: LMFeedMediaProtocol {
        public let videoURL: String
        public let isFilePath: Bool
        
        public init(videoURL: String, isFilePath: Bool = false) {
            self.videoURL = videoURL
            self.isFilePath = isFilePath
        }
    }
    
    
    // MARK: UI Elements
    open private(set) lazy var crossButton: LMButton = {
        let button = LMButton().translatesAutoresizingMaskIntoConstraints()
        button.setTitle(nil, for: .normal)
        button.setImage(Constants.shared.images.crossIcon, for: .normal)
        button.tintColor = Appearance.shared.colors.gray51
        button.backgroundColor = Appearance.shared.colors.white
        return button
    }()
    
    
    // MARK: Data Variables
    private weak var videoPlayer: AVPlayerViewController?
    public var crossButtonAction: ((String) -> Void)?
    public var videoURL: String?
    
    
    // MARK: prepareForReuse
    open override func prepareForReuse() {
        super.prepareForReuse()
        pauseVideo()
        videoPlayer = nil
    }
    
    
    // MARK: setupViews
    public override func setupViews() {
        super.setupViews()
        
        contentView.addSubview(containerView)
        containerView.addSubview(crossButton)
    }
    
    
    // MARK: setupLayouts
    open override func setupLayouts() {
        super.setupLayouts()
        
        contentView.pinSubView(subView: containerView)
        crossButton.addConstraint(top: (containerView.topAnchor, 16),
                                  trailing: (containerView.trailingAnchor, -16))
        crossButton.setHeightConstraint(with: 24)
        crossButton.setWidthConstraint(with: crossButton.heightAnchor)
    }
    
    
    // MARK: setupAppearance
    open override func setupAppearance() {
        super.setupAppearance()
        backgroundColor = .clear
        crossButton.layer.cornerRadius = crossButton.frame.height / 2
    }
    
    
    // MARK: setupActions
    open override func setupActions() {
        super.setupActions()
        crossButton.addTarget(self, action: #selector(didTapCrossButton), for: .touchUpInside)
    }
    
    @objc
    open func didTapCrossButton() {
        guard let videoURL else { return }
        crossButtonAction?(videoURL)
    }
    
    // MARK: configure
    open func configure(with data: ViewModel, videoPlayer: AVPlayerViewController, crossButtonAction: ((String) -> Void)? = nil) {
        self.videoPlayer = videoPlayer
        self.videoPlayer?.showsPlaybackControls = false
        self.videoPlayer?.allowsPictureInPicturePlayback = false
        videoURL = data.videoURL
        
        self.crossButtonAction = crossButtonAction
        crossButton.isHidden = crossButtonAction == nil
        if crossButtonAction != nil {
            containerView.bringSubviewToFront(crossButton)
        }
        
        containerView.addSubview(videoPlayer.view)
        containerView.pinSubView(subView: videoPlayer.view)
        
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
