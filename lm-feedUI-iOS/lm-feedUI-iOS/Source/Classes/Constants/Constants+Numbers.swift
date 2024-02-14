//
//  Constants+Numbers.swift
//  LMFramework
//
//  Created by Devansh Mohata on 07/12/23.
//

import Foundation

public extension Constants {
    struct Numbers {
        private init() { }
        
        // Shared Instance
        public static var shared = Numbers()
        
        // Numbers
        public var imageSize: CGFloat = 48
        public var postHeaderSize: CGFloat = 64
        public var postFooterSize: CGFloat = 44
        public var documentPreviewSize: CGFloat = 72
    }
}
