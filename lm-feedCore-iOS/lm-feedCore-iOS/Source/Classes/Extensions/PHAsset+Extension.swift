//
//  PHAsset+Extension.swift
//  lm-feedCore-iOS
//
//  Created by Devansh Mohata on 22/01/24.
//

import Photos

extension PHAsset {
    func getURL(completionHandler : @escaping ((_ responseURL : URL?) -> Void)) {
        var fileURL: URL?
        
        if self.mediaType == .image {
            let options: PHContentEditingInputRequestOptions = PHContentEditingInputRequestOptions()
            options.canHandleAdjustmentData = {(adjustmeta: PHAdjustmentData) -> Bool in
                return true
            }
            self.requestContentEditingInput(with: options, completionHandler: {(contentEditingInput: PHContentEditingInput?, info: [AnyHashable : Any]) -> Void in
                fileURL = contentEditingInput?.fullSizeImageURL as? URL
            })
        } else if self.mediaType == .video {
            let options: PHVideoRequestOptions = PHVideoRequestOptions()
            options.version = .original
            PHImageManager.default().requestAVAsset(forVideo: self, options: options, resultHandler: {(asset: AVAsset?, audioMix: AVAudioMix?, info: [AnyHashable : Any]?) -> Void in
                if let urlAsset = asset as? AVURLAsset {
                    fileURL =  urlAsset.url
                }
            })
        }
        DispatchQueue.main.async {
            completionHandler(fileURL)
        }
    }
}
