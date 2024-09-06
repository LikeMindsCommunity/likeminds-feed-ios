//
//  LMImageView.swift
//  LMFramework
//
//  Created by Devansh Mohata on 04/12/23.
//

import UIKit

@IBDesignable
public class LMImageView: UIImageView {
    var lastUrlLoaded: String?
    private var currentDownloadTask: URLSessionDataTask?

    open func translatesAutoresizingMaskIntoConstraints() -> Self {
        translatesAutoresizingMaskIntoConstraints = false
        return self
    }

    open func loadImage(url: String, completionHandler: ((Result<UIImage, LMFeedImageProviderError>) -> Void)? = nil) {
        self.loadImage(url: url, to: nil, scale: nil, completionHandler: completionHandler)
    }

    open func loadImage(url: String, to pointSize: CGSize?, scale: CGFloat?, completionHandler: ((Result<UIImage, LMFeedImageProviderError>) -> Void)? = nil) {
        if url != lastUrlLoaded{
            // Cancel any ongoing download task before starting a new one
            cancelCurrentDownload()
            self.deloadImageView()
            lastUrlLoaded = url
        }

        let defaultPointSize = CGSize(width: max(self.bounds.width, 720), height: max(self.bounds.height, 720))
        let targetPointSize = pointSize ?? defaultPointSize
        let targetScale = scale ?? CGFloat(1.0)

        currentDownloadTask = LMFeedImageProvider.shared.loadImage(from: url, to: targetPointSize, scale: targetScale) { [weak self] result in
            switch result{
            case .success(let image):
                completionHandler?(.success(image))
                DispatchQueue.main.async{
                    self?.image = image
                }
            case .failure(let err):
                completionHandler?(.failure(err))
            }
            
        }
    }

    open func deloadImageView() {
        lastUrlLoaded = nil
        DispatchQueue.main.async{
            self.image = nil
        }
    }
    
    private func cancelCurrentDownload() {
        currentDownloadTask?.cancel()
        currentDownloadTask = nil
    }
}
