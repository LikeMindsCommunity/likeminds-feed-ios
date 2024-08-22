//
//  LMFeedMediaImagePreview.swift
//  LikeMindsFeedCore
//
//  Created by Anurag Tyagi on 24/07/24.
//

import Kingfisher
import LikeMindsFeedUI
import UIKit

open class LMFeedMediaImagePreview: LMCollectionViewCell {
    open private(set) lazy var previewImageView: LMFeedZoomImageViewContainer = {
        let image = LMFeedZoomImageViewContainer()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.backgroundColor = .black
        return image
    }()
    
    open override func prepareForReuse() {
        super.prepareForReuse()
        resetZoomScale()
    }
    
    open override func setupViews() {
        super.setupViews()
        contentView.addSubviewWithDefaultConstraints(previewImageView)
    }
    
    open func configure(with data: LMFeedMediaPreviewContentModel) {
        guard let url = URL(string: data.mediaURL) else { return }
        previewImageView.configure(with: url)
    }
    
    open func resetZoomScale() {
        previewImageView.zoomScale = 1
    }
}