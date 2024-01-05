//
//  LMView.swift
//  LMFramework
//
//  Created by Devansh Mohata on 24/11/23.
//

import UIKit

@IBDesignable
open class LMView: UIView {
    /// Initializes `UIView` and set up subviews, auto layouts and actions.
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setupViews()
        self.setupLayouts()
        self.setupActions()
    }
    
    @available(*, unavailable, renamed: "init(frame:)")
    public required init?(coder: NSCoder) {
        fatalError("\(#function) not implemented in \(#filePath)")
    }
    
    /// Lays out subviews and set up styles.
    open override func layoutSubviews() {
        super.layoutSubviews()
        setupAppearance()
    }
    
    public func translatesAutoresizingMaskIntoConstraints() -> Self {
        self.translatesAutoresizingMaskIntoConstraints = false
        return self
    }
}

// MARK: LMViewLifeCycle
// Default Implementation is empty
extension LMView: LMViewLifeCycle {
    open func setupViews() { }
    
    open func setupLayouts() { }
    
    open func setupAppearance() { }
    
    open func setupActions() { }
}
