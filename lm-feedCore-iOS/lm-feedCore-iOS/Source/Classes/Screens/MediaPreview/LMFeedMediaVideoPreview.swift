//
//  LMFeedMediaVideoPreview.swift
//  LikeMindsFeedCore
//
//  Created by Anurag Tyagi on 24/07/24.
//

import LikeMindsFeedUI
import UIKit

public struct LMFeedMediaPreviewContentModel {
    let mediaURL: String
    let isVideo: Bool
}

open class LMFeedMediaVideoPreview: LMCollectionViewCell {
    // MARK: UI Elements
    open private(set) lazy var videoPreview: LMImageView = {
        let image = LMImageView().translatesAutoresizingMaskIntoConstraints()
        image.contentMode = .scaleAspectFit
        image.backgroundColor = LMFeedAppearance.shared.colors.black
        return image
    }()
    
    open private(set) lazy var playButton: LMButton = {
        let button = LMButton().translatesAutoresizingMaskIntoConstraints()
        button.setTitle(nil, for: .normal)
        button.setImage(LMFeedConstants.shared.images.playFilled, for: .normal)
        button.tintColor = LMFeedAppearance.shared.colors.white
        button.contentVerticalAlignment = .fill
        button.contentHorizontalAlignment = .fill
        return button
    }()
    
    
    // MARK: callback
    public var onTapCallback: (() -> Void)?
    
    
    // MARK: setupViews
    open override func setupViews() {
        super.setupViews()
        contentView.addSubviewWithDefaultConstraints(containerView)
        containerView.addSubviewWithDefaultConstraints(videoPreview)
        containerView.addSubview(playButton)
    }
    
    
    // MARK: setupLayouts
    open override func setupLayouts() {
        super.setupLayouts()
        
        playButton.setWidthConstraint(with: 36)
        playButton.setHeightConstraint(with: playButton.widthAnchor)
        playButton.addConstraint(centerX: (containerView.centerXAnchor, 0),
                                 centerY: (containerView.centerYAnchor, 0))
    }
    
    
    // MARK: setupActions
    open override func setupActions() {
        super.setupActions()
        playButton.addTarget(self, action: #selector(onTapPlayButton), for: .touchUpInside)
    }
    
    @objc
    open func onTapPlayButton() {
        onTapCallback?()
    }
    
    
    // MARK: configure
    open func configure(with data: LMFeedMediaPreviewContentModel, onTapCallback: (() -> Void)?) {
        self.onTapCallback = onTapCallback
        // videoPreview.kf.setImage(with: URL(string: data.thumbnailURL ?? ""))
    }
}

