//
//  LMViewLifeCycle.swift
//  LMFramework
//
//  Created by Devansh Mohata on 27/11/23.
//

import Foundation

/// Protocol for LM Life Cycle Methods
@objc
public protocol LMViewLifeCycle {
    /// This function handles the initialization of views.
    func setupViews()
    
    /// This function handles the initialization of autolayouts.
    func setupLayouts()
    
    /// This function handles the initialization of actions.
    func setupActions()
    
    /// This function handles the initialization of styles.
    func setupAppearance()
}
