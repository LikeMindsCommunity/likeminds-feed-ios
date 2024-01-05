//
//  Constants.swift
//  LMFramework
//
//  Created by Devansh Mohata on 01/12/23.
//

import UIKit

public struct Constants {
    private init() { }
    
    // Shared Instance
    public static var shared = Constants()
    
    public var number: Numbers = Numbers.shared
    public var strings: Strings = Strings.shared
    public var images: Images = Images.shared
}
