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
    let postID: String
    let index: Int
    let width: Int?
    let height: Int?
}

open class LMFeedMediaVideoPreview: LMCollectionViewCell {
    // MARK: UI Elements
    open private(set) lazy var videoCell: LMFeedVideoCollectionCell = {
        let videoCell = LMFeedVideoCollectionCell()
        videoCell.translatesAutoresizingMaskIntoConstraints = false
        return videoCell
    }()
    
    var videoContentModel: LMFeedVideoCollectionCell.ContentModel!
    var index: Int!
    
    
    // MARK: setupViews
    open override func setupViews() {
        super.setupViews()
        contentView.addSubviewWithDefaultConstraints(containerView)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubviewWithDefaultConstraints(videoCell)
    }
    
    
    // MARK: setupLayouts
    open override func setupLayouts() {
        super.setupLayouts()
        
        NSLayoutConstraint.activate([
            // ContainerView should fill the entire contentView
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            // VideoCell should fill the entire containerView
            videoCell.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            videoCell.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            videoCell.topAnchor.constraint(equalTo: containerView.topAnchor),
            videoCell.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
    }
    
    
    // MARK: setupActions
    open override func setupActions() {
        super.setupActions()
    }
    
    
    // MARK: configure
    open func configure(with data: LMFeedMediaPreviewContentModel, index: Int?) {
        videoContentModel = LMFeedVideoCollectionCell.ContentModel(videoURL: data.mediaURL, postID: data.postID, width: data.width, height: data.height)
        self.index = index ?? 1
        videoCell.configure(with: videoContentModel, index: index ?? 0, showControls: true)
    }

}

