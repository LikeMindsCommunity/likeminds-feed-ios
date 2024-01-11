//
//  NSAttributedString.Key+Extension.swift
//  LMFramework
//
//  Created by Devansh Mohata on 04/12/23.
//

import Foundation

public extension NSAttributedString {
    func attributeRange(at location: Int, for attribute: NSAttributedString.Key) -> NSRange? {
        // Ensure the location is within the string's bounds
        guard location < length else { return nil }
        
        // Check if the attribute is present at the specified location
        var effectiveRange = NSRange(location: NSNotFound, length: 0)
        let attributes = attributes(at: location, effectiveRange: &effectiveRange)
        
        if attributes[attribute] != nil {
            return effectiveRange
        } else {
            return nil
        }
    }
}

public extension NSAttributedString.Key {
    static let hashtags = NSAttributedString.Key("Hashtags")
    static let route = NSAttributedString.Key("Route")
}
