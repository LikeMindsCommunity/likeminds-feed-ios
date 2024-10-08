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
        public let width: Int?
        public let height: Int?
        
        public init(videoURL: String, isFilePath: Bool = false, postID: String, width: Int?, height: Int?) {
            self.videoURL = videoURL
            self.isFilePath = isFilePath
            self.postID = postID
            self.height = height
            self.width = width
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        buttonHideTimer?.invalidate()
        if let timeObserverToken = timeObserverToken {
            videoPlayer.playerLayer?.player?.removeTimeObserver(timeObserverToken)
            self.timeObserverToken = nil
        }
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
    
    open private(set) lazy var seekBar: UISlider = {
       let slider = UISlider()
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.minimumValue = 0
        return slider
    }()
    
    
    // MARK: Data Variables
    public var crossButtonHeight: CGFloat = 24
    public var volumeButtonHeight: CGFloat = 30
    public var playPauseButtonHeight : CGFloat = 50
    public var crossButtonAction: ((String) -> Void)?
    public var didTapVideo: (() -> Void)? = nil
    public var videoURL: URL?
    var timeObserverToken: Any?
    var showControls: Bool = true
    
    
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
        containerView.addSubview(seekBar)
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
        playPauseButton.addConstraint(centerX: (centerXAnchor, 0), centerY: (centerYAnchor, 0))
   
        seekBar.addConstraint( bottom: (containerView.bottomAnchor, -16), leading: (containerView.leadingAnchor, 16) , trailing: (volumeButton.leadingAnchor, -16))
        seekBar.setHeightConstraint(with: 30)
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
        seekBar.addTarget(self, action: #selector(seekBarChanged(_:)), for: .valueChanged)
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
    open func configure(with data: ContentModel, index: Int, crossButtonAction: ((String) -> Void)? = nil, didTapVideo: (() -> Void)? = nil, showControls: Bool = false) {
        guard let url = URL(string: data.videoURL) else { return }
        videoURL = url
        self.showControls = showControls
        self.didTapVideo = didTapVideo
        videoPlayer.prepareVideo(with: data, index, showControls: showControls)
        self.crossButtonAction = crossButtonAction
        crossButton.isHidden = crossButtonAction == nil
        if crossButtonAction != nil {
            containerView.bringSubviewToFront(crossButton)
        }
        seekBar.isHidden = !showControls
        addPeriodicTimeObserver()
        // Start timer to hide playpause button
        startButtonHideTimer()
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
        if playPauseButton.isHidden == true {
            showButton()
            startButtonHideTimer()
        }else{
            didTapVideo?()
        }
    }
    
    private func startButtonHideTimer() {
        // Invalidate any existing timer
        buttonHideTimer?.invalidate()
        
        // Start a new timer to hide the button after 500ms
        buttonHideTimer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(hideButton), userInfo: nil, repeats: false)
    }
    
    @objc private func hideButton() {
        seekBar.isHidden = true
        playPauseButton.isHidden = true
        volumeButton.isHidden = true
    }
    
    private func showButton() {
        seekBar.isHidden = !showControls
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
    
    // Seek bar value changed
    @objc func seekBarChanged(_ sender: UISlider) {
        let duration = videoPlayer.playerLayer?.player?.currentItem?.duration
        let seconds = Float64(sender.value) * CMTimeGetSeconds(duration!)
        let time = CMTimeMakeWithSeconds(seconds, preferredTimescale: 600)
        videoPlayer.playerLayer?.player?.seek(to: time)
    }
    
    // Add a periodic time observer to update the seek bar as the video plays
    func addPeriodicTimeObserver() {
        let interval = CMTime(seconds: 1, preferredTimescale: 600)
        timeObserverToken = videoPlayer.playerLayer?.player?.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            guard let self = self, let duration = videoPlayer.playerLayer?.player?.currentItem?.duration else { return }
            let currentTime = CMTimeGetSeconds(time)
            let totalTime = CMTimeGetSeconds(duration)
            self.seekBar.value = Float(currentTime / totalTime)
        }
    }
}
