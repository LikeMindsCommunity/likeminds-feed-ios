//
//  Date+Extension.swift
//  lm-feedCore-iOS
//
//  Created by Devansh Mohata on 14/01/24.
//

import Foundation

public extension Date {
    var millisecondsSince1970: Double {
        return (timeIntervalSince1970 * 1000.0).rounded()
    }
}
