//
//  LMFeedMediaImagePreview.swift
//  LikeMindsFeedCore
//
//  Created by Anurag Tyagi on 24/07/24.
//

import Kingfisher
import UIKit

open class LMFeedMediaImagePreview: LMCollectionViewCell {
    open private(set) lazy var previewImageView: LMFeedZoomImageViewContainer = {
        let image = LMUIComponents.shared.mediaImageZoomPreview.init()
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
        contentView.addSubview(previewImageView)
        contentView.pinSubView(subView: previewImageView)
    }
    
    open func configure(with data: LMFeedMediaPreviewContentModel) {
        guard let url = URL(string: data.mediaURL) else { return }
        previewImageView.configure(with: url)
    }
    
    open func resetZoomScale() {
        previewImageView.zoomScale = 1
    }
}
