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
    
    public static func formatDate(_ date: Date, toFormat format: String = "dd-MM-yyyy HH:mm") -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: date)
    }
    
    public static func isEpochTimeInSeconds(_ epochTime: Int) -> Bool {
        let epochTimeString = String(epochTime)
        let numDigits = epochTimeString.count
        
        /// Epoch time values with 10 or fewer digits are assumed to be in seconds
        /// Epoch time values with more than 10 digits are assumed to be in milliseconds
        return numDigits <= 10
    }
}
