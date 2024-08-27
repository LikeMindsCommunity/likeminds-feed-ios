//
//  LMFeedConstants.swift
//  LMFramework
//
//  Created by Devansh Mohata on 01/12/23.
//

import UIKit

public struct LMFeedConstants {
    private init() { }
    
    // Shared Instance
    public static var shared = Self()
    
    public var number: Numbers = Numbers.shared
    public var strings: Strings = Strings.shared
    public var images: Images = Images.shared
}
