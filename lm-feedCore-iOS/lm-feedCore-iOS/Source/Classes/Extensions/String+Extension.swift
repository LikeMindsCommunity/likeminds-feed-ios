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
}
