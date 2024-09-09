//
//  LMFeedZoomImageViewContainer.swift
//  LikeMindsFeedCore
//
//  Created by Anurag Tyagi on 24/07/24.
//

import UIKit

open class LMFeedZoomImageViewContainer: UIScrollView {
    
    public var imageName: String? {
        didSet {
            guard let imageName = imageName else {
                return
            }
            imageView.image = UIImage(named: imageName)
        }
    }
    
    open private(set) var imageView: LMImageView = {
        let image = LMImageView().translatesAutoresizingMaskIntoConstraints()
        image.clipsToBounds = true
        image.contentMode = .scaleAspectFit
        return image
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    convenience init(named: String) {
        self.init(frame: .zero)
        self.imageName = named
    }
    
    convenience init(image: UIImage) {
        self.init(frame: .zero)
//        self.image = image
    }
    
    public var zoomFeatureEnable: Bool? = true
    
    private func commonInit() {
        // Setup image view
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalTo: widthAnchor),
            imageView.heightAnchor.constraint(equalTo: heightAnchor),
            imageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
        
        // Setup scroll view
        minimumZoomScale = 1
        maximumZoomScale = 3
        showsHorizontalScrollIndicator = false
        showsVerticalScrollIndicator = false
        delegate = self
        
        // Setup tap gesture
        let doubleTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(_:)))
        doubleTapRecognizer.numberOfTapsRequired = 2
        addGestureRecognizer(doubleTapRecognizer)
    }
    
    @objc
    private func handleDoubleTap(_ sender: UITapGestureRecognizer) {
        guard zoomFeatureEnable == true else { return }
        if zoomScale == 1 {
            setZoomScale(2, animated: true)
        } else {
            setZoomScale(1, animated: true)
        }
    }
    
    
    public func configure(with image: URL?) {
        guard let image else { return }
        imageView.loadImage(url: image.absoluteString)
    }
    
    public func configure(with image: UIImage?) {
        imageView.image = image
    }
}

extension LMFeedZoomImageViewContainer: UIScrollViewDelegate {
    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}

