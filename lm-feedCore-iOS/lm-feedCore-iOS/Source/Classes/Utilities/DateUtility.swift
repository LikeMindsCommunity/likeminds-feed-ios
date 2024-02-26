//
//  DateUtility.swift
//  likeminds-feed-iOS
//
//  Created by Devansh Mohata on 28/12/23.
//

import Foundation

public struct DateUtility {
    /// Specific Function to Convert `Double` aka `TimeInterval` to Human Readable Formatted Time String for Post Widget use case!
    public static func timeIntervalPostWidget(timeIntervalInMilliSeconds time: Int) -> String {
        if Double(time / 1000) == Date().timeIntervalSince1970 {
            return "Just Now"
        }
        
        if let time = timeIntervalToDate(Double(time / 1000)) {
           return time
        }
        
        return ""
    }
    
    
    /// Generic Function to Convert `Double` aka `TimeInterval` to Human Readable Formatted Time String
    public static func timeIntervalToDate(_ time: Double) -> String? {
        let formatter = RelativeDateTimeFormatter()
        formatter.dateTimeStyle = .named
        formatter.unitsStyle = .short
        return formatter.string(for: Date(timeIntervalSince1970: time))
    }
}
