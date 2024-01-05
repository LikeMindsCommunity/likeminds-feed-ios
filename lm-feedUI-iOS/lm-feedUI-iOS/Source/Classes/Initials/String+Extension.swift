//
//  String+Extension.swift
//  likeminds-feed-iOS
//
//  Created by Devansh Mohata on 21/12/23.
//

import Foundation

public extension String {
    func sizeOfString(with font: UIFont = .systemFont(ofSize: 16)) -> CGSize {
        let fontAttributes = [NSAttributedString.Key.font: font]
        let size = (self as NSString).size(withAttributes: fontAttributes)
        return size
    }
}
