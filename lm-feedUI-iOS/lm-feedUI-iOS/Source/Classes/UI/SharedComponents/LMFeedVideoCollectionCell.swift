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
    
    public struct ContentModel: LMFeedMediaProtocol {
        public let videoURL: String
        public let isFilePath: Bool
        public let postID: String
        
        public init(videoURL: String, isFilePath: Bool = false, postID: String) {
            self.videoURL = videoURL
            self.isFilePath = isFilePath
            self.postID = postID
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    
    // MARK: UI Elements
    open private(set) lazy var videoPlayer: LMFeedLoopedVideoPlayer = {
        let player = LMFeedLoopedVideoPlayer()
        player.translatesAutoresizingMaskIntoConstraints = false
        return player
    }()
    
    open private(set) lazy var crossButton: LMButton = {
        let button = LMButton().translatesAutoresizingMaskIntoConstraints()
        button.setTitle(nil, for: .normal)
        button.setImage(LMFeedConstants.shared.images.xmarkIcon, for: .normal)
        button.backgroundColor = LMFeedAppearance.shared.colors.white
        button.tintColor = LMFeedAppearance.shared.colors.gray51
        button.contentMode = .scaleAspectFit
        return button
    }()
    
    open private(set) lazy var volumeButton: LMButton = {
        let button = LMButton().translatesAutoresizingMaskIntoConstraints()
        button.setTitle(nil, for: .normal)
        button.setImage(LMFeedVideoProvider.isMuted ? LMFeedConstants.shared.images.unMuteFillIcon : LMFeedConstants.shared.images.muteFillIcon , for: .normal)
        button.backgroundColor = LMFeedAppearance.shared.colors.white
        button.tintColor = LMFeedAppearance.shared.colors.gray51
        button.contentMode = .scaleAspectFit
        return button
    }()
    
    
    // MARK: Data Variables
    public var crossButtonHeight: CGFloat = 24
    public var crossButtonAction: ((String) -> Void)?
    public var videoURL: URL?
    
    
    // MARK: prepareForReuse
    open override func prepareForReuse() {
        videoPlayer.pause()
        super.prepareForReuse()
    }
    
    
    // MARK: setupViews
    public override func setupViews() {
        super.setupViews()
        
        contentView.addSubview(containerView)
        containerView.addSubview(videoPlayer)
        containerView.addSubview(crossButton)
        containerView.addSubview(volumeButton)
    }
    
    
    // MARK: setupLayouts
    open override func setupLayouts() {
        super.setupLayouts()
        
        contentView.pinSubView(subView: containerView)
        containerView.pinSubView(subView: videoPlayer)
        volumeButton.addConstraint(bottom: (containerView.bottomAnchor, -16),
                                   trailing: (containerView.trailingAnchor, -16))
        volumeButton.setHeightConstraint(with: crossButtonHeight)
        volumeButton.setWidthConstraint(with: crossButton.heightAnchor)
        crossButton.addConstraint(top: (containerView.topAnchor, 16),
                                  trailing: (containerView.trailingAnchor, -16))
        crossButton.setHeightConstraint(with: crossButtonHeight)
        crossButton.setWidthConstraint(with: crossButton.heightAnchor)
    }
    
    
    // MARK: setupAppearance
    open override func setupAppearance() {
        super.setupAppearance()
        videoPlayer.backgroundColor = LMFeedAppearance.shared.colors.black
        crossButton.layer.cornerRadius = crossButtonHeight / 2
        crossButton.layer.borderColor = LMFeedAppearance.shared.colors.gray51.cgColor
        crossButton.layer.borderWidth = 1
        volumeButton.layer.cornerRadius = crossButtonHeight / 2
        volumeButton.layer.borderColor = LMFeedAppearance.shared.colors.gray51.cgColor
        volumeButton.layer.borderWidth = 1
    }
    
    
    // MARK: setupActions
    open override func setupActions() {
        super.setupActions()
        setupObserver()
        crossButton.addTarget(self, action: #selector(didTapCrossButton), for: .touchUpInside)
        volumeButton.addTarget(self, action: #selector(didTapVolumeButton), for: .touchUpInside)
    }
    
    private func setupObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(setVolumeButtonImageBasedOnMuteState), name: .volumeStateChanged, object: nil)
    }
    
    @objc
    open func setVolumeButtonImageBasedOnMuteState(){
        volumeButton.setImage(LMFeedVideoProvider.isMuted ? LMFeedConstants.shared.images.unMuteFillIcon : LMFeedConstants.shared.images.muteFillIcon , for: .normal)
        toggleVolumeState()
    }
    
    @objc
    open func didTapCrossButton() {
        guard let videoURL else { return }
        unload()
        crossButtonAction?(videoURL.absoluteString)
    }
    
    @objc
    open func didTapVolumeButton(){
        LMFeedVideoProvider.isMuted.toggle()
    }
    
    // MARK: configure
    open func configure(with data: ContentModel, index: Int, crossButtonAction: ((String) -> Void)? = nil) {
        guard let url = URL(string: data.videoURL) else { return }
        videoURL = url
        
        videoPlayer.prepareVideo(url, data.postID, index)
        self.crossButtonAction = crossButtonAction
        crossButton.isHidden = crossButtonAction == nil
        if crossButtonAction != nil {
            containerView.bringSubviewToFront(crossButton)
        }
    }
    
    open func playVideo() {
        videoPlayer.videoPlayerController?.player?.isMuted = LMFeedVideoProvider.isMuted
        videoPlayer.play()
    }
    
    open func pauseVideo() {
        videoPlayer.pause()
    }
    
    open func unload() {
        videoPlayer.unload()
    }
    
    open func toggleVolumeState(){
        videoPlayer.toggleVolumeState()
    }
}
