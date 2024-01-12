//
//  LMView.swift
//  LMFramework
//
//  Created by Devansh Mohata on 24/11/23.
//

import UIKit

public extension UIView {
    func roundCorners(_ corners: CACornerMask, with cornerRadius: CGFloat) {
        clipsToBounds = true
        layer.maskedCorners = corners
        layer.cornerRadius = cornerRadius
    }
    
    func roundCornerWithShadow(cornerRadius: CGFloat, shadowRadius: CGFloat, offsetX: CGFloat, offsetY: CGFloat, colour: UIColor, opacity: Float, corners: CACornerMask = [.layerMinXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner, .layerMaxXMinYCorner]) {
        self.clipsToBounds = false
        
        let layer = self.layer
        layer.masksToBounds = false
        layer.cornerRadius = cornerRadius
        layer.maskedCorners = corners
        layer.shadowOffset = CGSize(width: offsetX, height: offsetY);
        layer.shadowColor = colour.cgColor
        layer.shadowRadius = shadowRadius
        layer.shadowOpacity = opacity
        layer.shadowPath = UIBezierPath(roundedRect: layer.bounds, cornerRadius: layer.cornerRadius).cgPath
        
        let bColour = self.backgroundColor
        self.backgroundColor = nil
        layer.backgroundColor = bColour?.cgColor
    }
}

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
