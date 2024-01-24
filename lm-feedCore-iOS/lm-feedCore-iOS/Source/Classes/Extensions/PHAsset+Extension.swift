//
//  PHAsset+Extension.swift
//  lm-feedCore-iOS
//
//  Created by Devansh Mohata on 22/01/24.
//

import Photos

extension PHAsset {
    func asyncURL(_ completion: @escaping ((URL?) -> Void)) {
        switch mediaType {
        case .image:
            let options: PHContentEditingInputRequestOptions = .init()
            options.isNetworkAccessAllowed = true
            options.canHandleAdjustmentData = { _ in true }
            requestContentEditingInput(with: options) { editingInput, _ in
                completion(editingInput?.fullSizeImageURL)
            }
        case .video:
            let options: PHVideoRequestOptions = .init()
            options.isNetworkAccessAllowed = true
            options.version = .original
            PHImageManager.default()
                .requestAVAsset(forVideo: self, options: options) { asset, _, _ in
                    DispatchQueue.main.async {
                        completion((asset as? AVURLAsset)?.url)
                    }
                }
        default:
            completion(nil)
        }
    }
}
