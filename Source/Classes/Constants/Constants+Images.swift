//
//  Constants+Images.swift
//  LMFramework
//
//  Created by Devansh Mohata on 12/12/23.
//

import UIKit

extension UIImage {
    convenience init?(named name: String, in bundle: Bundle) {
        self.init(named: name, in: bundle, compatibleWith: nil)
    }
}

public extension Constants {
    struct Images {
        private init() { }
        
        // Shared Instance
        public static var shared = Images()
        
        // Images
        public var heart = UIImage(systemName: "heart")
        public var heartFilled = UIImage(systemName: "heart.fill")
        public var commentIcon = UIImage(systemName: "message")
        public var bookmark = UIImage(systemName: "bookmark")
        public var bookmarkFilled = UIImage(systemName: "bookmark.fill")
        public var shareIcon = UIImage(systemName: "arrowshape.turn.up.right")
        public var crossIcon = UIImage(systemName: "xmark.circle")
        public var ellipsis = UIImage(systemName: "ellipsis")
        public var pdfIcon = UIImage(named: "pdfIcon", in: Bundle.LMBundleIdentifier)
    }
}
