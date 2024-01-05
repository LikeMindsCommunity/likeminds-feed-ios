//
//  Appearance.swift
//  LMFramework
//
//  Created by Devansh Mohata on 07/12/23.
//

import UIKit

public struct Appearance {
    private init() { }
    
    // Shared Instance
    public static var shared = Self()
    public var colors: Colors = Colors.shared
    public var fonts: Fonts = Fonts.shared
}
