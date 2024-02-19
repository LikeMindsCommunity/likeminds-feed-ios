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
    open private(set) lazy var videoPlayer: LMFeedLoopedVideoPlayer = {
        let player = LMFeedLoopedVideoPlayer()
        player.translatesAutoresizingMaskIntoConstraints = false
        return player
    }()
    
    open private(set) lazy var crossButton: LMImageView = {
        let image = LMImageView(image: Constants.shared.images.xmarkIcon)
        image.translatesAutoresizingMaskIntoConstraints = false
        image.backgroundColor = Appearance.shared.colors.white
        image.tintColor = Appearance.shared.colors.gray51
        image.contentMode = .scaleAspectFill
        image.layer.borderColor = Appearance.shared.colors.gray51.cgColor
        image.layer.borderWidth = 1
        return image
    }()
    
    
    // MARK: Data Variables
    public var crossButtonHeight: CGFloat = 24
    public var crossButtonAction: ((String) -> Void)?
    public var videoURL: String?
    
    
    // MARK: prepareForReuse
    open override func prepareForReuse() {
        super.prepareForReuse()
        pauseVideo()
    }
    
    
    // MARK: setupViews
    public override func setupViews() {
        super.setupViews()
        
        contentView.addSubview(containerView)
        containerView.addSubview(videoPlayer)
        containerView.addSubview(crossButton)
    }
    
    
    // MARK: setupLayouts
    open override func setupLayouts() {
        super.setupLayouts()
        
        contentView.pinSubView(subView: containerView)
        containerView.pinSubView(subView: videoPlayer)
        crossButton.addConstraint(top: (containerView.topAnchor, 16),
                                  trailing: (containerView.trailingAnchor, -16))
        crossButton.setHeightConstraint(with: crossButtonHeight)
        crossButton.setWidthConstraint(with: crossButton.heightAnchor)
    }
    
    
    // MARK: setupAppearance
    open override func setupAppearance() {
        super.setupAppearance()
        backgroundColor = .red
        crossButton.layer.cornerRadius = crossButtonHeight / 2
    }
    
    
    // MARK: setupActions
    open override func setupActions() {
        super.setupActions()
        crossButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapCrossButton)))
    }
    
    @objc
    open func didTapCrossButton() {
        guard let videoURL else { return }
        crossButtonAction?(videoURL)
    }
    
    // MARK: configure
    open func configure(with data: ViewModel, crossButtonAction: ((String) -> Void)? = nil) {
        guard let url = URL(string: data.videoURL) else { return }
        videoURL = data.videoURL
        
        videoPlayer.prepareVideo(url)
        self.crossButtonAction = crossButtonAction
        crossButton.isHidden = crossButtonAction == nil
        if crossButtonAction != nil {
            containerView.bringSubviewToFront(crossButton)
        }
    }
    
    open func playVideo() {
        videoPlayer.play()
    }
    
    open func pauseVideo() {
        videoPlayer.pause()
    }
}
