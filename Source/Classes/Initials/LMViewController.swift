//
//  LMViewController.swift
//  LMFramework
//
//  Created by Devansh Mohata on 24/11/23.
//

import UIKit

/// Base LM View Controller Class with LM Life Cycle Methods
@IBDesignable
open class LMViewController: UIViewController {
    open override func loadView() {
        super.loadView()
        setupViews()
        setupLayouts()
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        setupActions()
        setupNavigationBar()
    }
    
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setupAppearance()
    }
    
    open func setupNavigationBar() {
        navigationController?.navigationBar.isTranslucent = false
        
        if #available(iOS 15, *) {
            let appearance = UINavigationBarAppearance()
            appearance.backgroundColor = Appearance.shared.colors.navigationBackgroundColor
            navigationController?.navigationBar.scrollEdgeAppearance = appearance
        }
    }
}

extension LMViewController: LMViewLifeCycle {
    /// This function handles the initialization of views.
    open func setupViews() { }
    
    /// This function handles the initialization of autolayouts.
    open func setupLayouts() { }
    
    /// This function handles the initialization of actions.
    open func setupActions() { }
    
    /// This function handles the initialization of styles.
    open func setupAppearance() { }
}
