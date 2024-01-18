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
    private var videoPlayer: AVPlayerViewController?
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
    }
    
    
    // MARK: setupLayouts
    open override func setupLayouts() {
        super.setupLayouts()
        
        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            crossButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            crossButton.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            crossButton.heightAnchor.constraint(equalToConstant: 24),
            crossButton.widthAnchor.constraint(equalTo: crossButton.heightAnchor)
        ])
    }
    
    
    // MARK: setupAppearance
    open override func setupAppearance() {
        super.setupAppearance()
        backgroundColor = .clear
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
        self.crossButtonAction = crossButtonAction
        videoURL = data.videoURL
        
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
        
        self.crossButtonAction = crossButtonAction
        crossButton.isHidden = crossButtonAction == nil
        if crossButtonAction != nil {
            containerView.bringSubviewToFront(crossButton)
        }
    }
    
    open func playVideo() {
        videoPlayer?.player?.play()
    }
    
    open func pauseVideo() {
        videoPlayer?.player?.pause()
    }
}
