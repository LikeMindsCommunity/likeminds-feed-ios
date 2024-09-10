//
//  LMFeedImageProvider.swift
//  LikeMindsFeedUI
//
//  Created by Anurag Tyagi on 03/09/24.
//

import UIKit

extension UIImage {
    var cacheCost: Int {
        guard let cgImage = self.cgImage else { return 0 }
        let bytesPerPixel = 4 // RGBA (Red, Green, Blue, Alpha)
        let bytesPerRow = cgImage.width * bytesPerPixel
        let totalBytes = bytesPerRow * cgImage.height
        return totalBytes
    }
}

public enum LMFeedImageProviderError: Error {
    case invalidURL(url: String)
    case downsamplingFailed(message: String)
    case unknownError(message: String)
}

// Declares in-memory image cache
public protocol LMFeedImageCacheProtocol: AnyObject {
    // Returns the image associated with a given url
    func getCachedimage(for url: String) -> UIImage?
    // Inserts the image of the specified url in the cache
    func insertImage(_ image: UIImage?, for url: String)
    // Removes the image of the specified url in the cache
    func removeImage(for url: String)
    // Removes all images from the cache
    func removeAllImages()
}

open class LMFeedImageProvider : LMFeedImageCacheProtocol{
    static let shared = LMFeedImageProvider()
    var imageCache: NSCache<NSString, UIImage> = NSCache<NSString, UIImage>()
    
    private let lock = NSLock()
    private let config: Config
    
    struct Config {
        let countLimit: Int
        let memoryLimit: Int
        
        static let defaultConfig = Config(countLimit: 100, memoryLimit: 1024 * 1024 * 300) // 150 MB
    }
    
    private init(config: Config = Config.defaultConfig) {
        self.config = config
        imageCache.countLimit = config.countLimit
        imageCache.totalCostLimit = config.memoryLimit
    }
    
    open func getCachedimage(for url: String) -> UIImage? {
        // the best case scenario -> there is a decoded image
        if let decodedImage = imageCache.object(forKey:  url as NSString) {
            return decodedImage
        }
        
        return nil
    }
    
    open func insertImage(_ image: UIImage?, for url: String) {
        defer { lock.unlock() }
        lock.lock()
        
        guard let image = image else { return removeImage(for: url) }
        imageCache.setObject(image, forKey: url as NSString, cost: image.cacheCost)
    }
    
    open func removeImage(for url: String) {
        defer { lock.unlock() }
        
        lock.lock()
        imageCache.removeObject(forKey:  url as NSString)
    }
    
    open func removeAllImages() {
         lock.lock()
         defer { lock.unlock() }
        
        imageCache.removeAllObjects()
    }
    
    open func loadImage(from url: String, to pointSize: CGSize, scale: CGFloat, completion: ((Result<UIImage, LMFeedImageProviderError>) -> Void)? = nil) -> URLSessionDataTask? {
        //Check if the image is already cached
        if let cachedImage = getCachedimage(for: url) {
            completion?(.success(cachedImage))
            return nil
        }
        //
        // Proceed with downloading and downsampling the image
        guard let imageURL = URL(string: url) else {
            completion?(.failure(LMFeedImageProviderError.invalidURL(url: url)))
            return nil
        }
        
        let task = URLSession.shared.dataTask(with: imageURL) { data, response, error in
            guard let data = data, error == nil else {
                completion?(.failure(LMFeedImageProviderError.unknownError(message: "Failed to load image data: \(error?.localizedDescription ?? "Unknown error")")))
                return
            }
            let imageSourceOptions = [kCGImageSourceShouldCache: false] as CFDictionary
            
            if let imageSource = CGImageSourceCreateWithData(data as CFData, imageSourceOptions) {
                let maxDimensionInPixels = max(pointSize.width, pointSize.height) * scale
                let downsampledOptions = [
                    kCGImageSourceCreateThumbnailFromImageAlways: true,
                    kCGImageSourceShouldCacheImmediately: true,
                    kCGImageSourceCreateThumbnailWithTransform: true,
                    kCGImageSourceThumbnailMaxPixelSize: maxDimensionInPixels
                ] as CFDictionary
                
                if let downsampledImage = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, downsampledOptions) {
                    let image = UIImage(cgImage: downsampledImage)
                    // Cache the image
                    self.insertImage(image, for: url)
                    completion?(.success(image))
                } else {
                    completion?(.failure(LMFeedImageProviderError.downsamplingFailed(message: "Unable to downsample the provided image")))
                }
            } else {
                completion?(.failure(LMFeedImageProviderError.unknownError(message: "Unknown error while fetching image from source")))
            }
        }
        task.resume()
        return task
    }
}
