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
    
    open private(set) var playPauseButton: UIButton = {
        var playPauseButton = UIButton(type: .system)
        playPauseButton.setImage(LMFeedConstants.shared.images.playFilled, for: .normal)
        playPauseButton.backgroundColor = LMFeedAppearance.shared.colors.black4
        playPauseButton.tintColor = LMFeedAppearance.shared.colors.white
        playPauseButton.contentMode = .scaleAspectFit
        playPauseButton.translatesAutoresizingMaskIntoConstraints = false
        return playPauseButton
    }()
    open private(set) var buttonHideTimer: Timer?
    
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
        buttonHideTimer?.invalidate()
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
        button.backgroundColor = LMFeedAppearance.shared.colors.black4
        button.tintColor = LMFeedAppearance.shared.colors.white
        button.contentMode = .scaleAspectFit
        return button
    }()
    
    open private(set) lazy var volumeButton: LMButton = {
        let button = LMButton().translatesAutoresizingMaskIntoConstraints()
        button.setTitle(nil, for: .normal)
        button.setImage(LMFeedVideoProvider.isMuted ? LMFeedConstants.shared.images.unMuteFillIcon : LMFeedConstants.shared.images.muteFillIcon , for: .normal)
        button.backgroundColor = LMFeedAppearance.shared.colors.black4
        button.tintColor = LMFeedAppearance.shared.colors.white
        button.contentMode = .scaleAspectFit
        return button
    }()
    
    
    // MARK: Data Variables
    public var crossButtonHeight: CGFloat = 24
    public var volumeButtonHeight: CGFloat = 30
    public var playPauseButtonHeight : CGFloat = 50
    public var crossButtonAction: ((String) -> Void)?
    public var videoURL: URL?
    
    
    // MARK: prepareForReuse
    open override func prepareForReuse() {
        videoPlayer.pause()
        updateButtonIcon(isPlaying: false)
        super.prepareForReuse()
    }
    
    
    // MARK: setupViews
    public override func setupViews() {
        super.setupViews()
        
        contentView.addSubview(containerView)
        containerView.addSubview(videoPlayer)
        containerView.addSubview(crossButton)
        containerView.addSubview(volumeButton)
        containerView.addSubview(playPauseButton)
        
        startButtonHideTimer()
    }
    
    
    // MARK: setupLayouts
    open override func setupLayouts() {
        super.setupLayouts()
        
        contentView.pinSubView(subView: containerView)
        containerView.pinSubView(subView: videoPlayer)
        
        volumeButton.addConstraint(bottom: (containerView.bottomAnchor, -16),
                                   trailing: (containerView.trailingAnchor, -16))
        volumeButton.setHeightConstraint(with: volumeButtonHeight)
        volumeButton.setWidthConstraint(with: volumeButton.heightAnchor)
        
        crossButton.addConstraint(top: (containerView.topAnchor, 16),
                                  trailing: (containerView.trailingAnchor, -16))
        crossButton.setWidthConstraint(with: crossButton.heightAnchor)
        crossButton.setHeightConstraint(with: crossButtonHeight)
        
        playPauseButton.setHeightConstraint(with: playPauseButtonHeight)
        playPauseButton.setWidthConstraint(with: playPauseButton.heightAnchor)
        
        
        NSLayoutConstraint.activate([
            playPauseButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            playPauseButton.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
    }
    
    
    // MARK: setupAppearance
    open override func setupAppearance() {
        super.setupAppearance()
        videoPlayer.backgroundColor = LMFeedAppearance.shared.colors.black
        crossButton.layer.cornerRadius = crossButtonHeight / 2
        crossButton.layer.borderColor = LMFeedAppearance.shared.colors.gray51.cgColor
        crossButton.layer.borderWidth = 1
        volumeButton.layer.cornerRadius = volumeButtonHeight / 2
        playPauseButton.layer.cornerRadius = playPauseButtonHeight / 2
    }
    
    
    // MARK: setupActions
    open override func setupActions() {
        super.setupActions()
        setupObserver()
        crossButton.addTarget(self, action: #selector(didTapCrossButton), for: .touchUpInside)
        volumeButton.addTarget(self, action: #selector(didTapVolumeButton), for: .touchUpInside)
        playPauseButton.addTarget(self, action: #selector(didTapPlayPauseButton), for: .touchUpInside)
    }
    
    private func setupObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(setVolumeButtonImageBasedOnMuteState), name: .volumeStateChanged, object: nil)
        // Gesture Detector for showing and hiding play pause button
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
        addGestureRecognizer(tapGestureRecognizer)
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
        updateButtonIcon(isPlaying: true)
    }
    
    open func pauseVideo() {
        videoPlayer.pause()
        updateButtonIcon(isPlaying: false)
    }
    
    open func unload() {
        videoPlayer.unload()
    }
    
    open func toggleVolumeState(){
        videoPlayer.toggleVolumeState()
    }
    
    @objc private func viewTapped() {
        // Show the button and reset the auto-hide timer
        showButton()
        startButtonHideTimer()
    }
    
    private func startButtonHideTimer() {
        // Invalidate any existing timer
        buttonHideTimer?.invalidate()
        
        // Start a new timer to hide the button after 500ms
        buttonHideTimer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(hideButton), userInfo: nil, repeats: false)
    }
    
    @objc private func hideButton() {
        playPauseButton.isHidden = true
        volumeButton.isHidden = true
    }
    
    private func showButton() {
        playPauseButton.isHidden = false
        volumeButton.isHidden = false
    }
    
    @objc private func didTapPlayPauseButton() {
        if videoPlayer.playerLayer?.player?.timeControlStatus == .playing {
            pauseVideo()
        } else {
            playVideo()
        }
        
        startButtonHideTimer()
    }
    
    private func updateButtonIcon(isPlaying: Bool) {
        let iconImage = isPlaying ? LMFeedConstants.shared.images.pauseFilled : LMFeedConstants.shared.images.playFilled
        playPauseButton.setImage(iconImage, for: .normal)
    }
}
