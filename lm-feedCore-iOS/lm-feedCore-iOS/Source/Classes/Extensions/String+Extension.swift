//
//  String+Extension.swift
//  lm-feedCore-iOS
//
//  Created by Devansh Mohata on 23/01/24.
//

import UIKit

public extension String {
    func detectLink() -> Self? {
        do {
            let detector = try NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
            let matches = detector.matches(in: self, options: [], range: NSRange(location: 0, length: self.utf16.count))
            
            for match in matches {
                guard let range = Range(match.range, in: self) else { continue }
                let url = self[range]
                return String(url)
            }
        } catch {
            return nil
        }
        
        return nil
    }
    
    // TODO: Handle It
    func convertIntoURL() -> URL? {
        guard let url = URL(string: self) else { return nil }
        
        if url.scheme == nil {
            let newURLString = "https://\(url.absoluteString)"
            return URL(string: newURLString)
        }
        
        return url
    }
}
