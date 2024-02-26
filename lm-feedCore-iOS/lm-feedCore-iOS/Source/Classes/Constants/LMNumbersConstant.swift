//
//  LMNumbersConstant.swift
//  lm-feedCore-iOS
//
//  Created by Devansh Mohata on 14/02/24.
//

import Foundation

public struct LMNumbersConstant {
    private init() { }
    
    public static var shared = Self()
    
    public var maxFilesToUpload: Int = 10
    public var maxFileSizeInMB: Int = 100
    
    var maxFileSizeInBytes: Int {
        maxFileSizeInMB * 1_000_000
    }
}
