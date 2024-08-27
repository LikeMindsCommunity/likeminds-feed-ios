//
//  LMView.swift
//  LMFramework
//
//  Created by Devansh Mohata on 24/11/23.
//

import UIKit

public extension UIView {
    func roundCorners(_ corners: CACornerMask = [.layerMaxXMaxYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMinXMinYCorner], with cornerRadius: CGFloat) {
        clipsToBounds = true
        layer.maskedCorners = corners
        layer.cornerRadius = cornerRadius
    }
    
    func dropShadow(scale: Bool = true) {
        layer.masksToBounds = false
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.5
        layer.shadowOffset = CGSize(width: -1, height: 1)
        layer.shadowRadius = 1

        layer.shadowPath = UIBezierPath(rect: bounds).cgPath
        layer.shouldRasterize = true
        layer.rasterizationScale = scale ? UIScreen.main.scale : 1
      }

      func dropShadow(color: UIColor, opacity: Float = 1, offSet: CGSize, radius: CGFloat = 1, scale: Bool = true) {
        layer.masksToBounds = false
        layer.shadowColor = color.cgColor
        layer.shadowOpacity = opacity
        layer.shadowOffset = offSet
        layer.shadowRadius = radius

        layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
        layer.shouldRasterize = true
        layer.rasterizationScale = scale ? UIScreen.main.scale : 1
      }
    
    func pinSubView(subView: UIView, padding: UIEdgeInsets = .zero) {
        NSLayoutConstraint.activate([
            subView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding.left),
            subView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: padding.right),
            subView.topAnchor.constraint(equalTo: topAnchor, constant: padding.top),
            subView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: padding.bottom)
        ])
    }
    
    func safePinSubView(subView: UIView, padding: UIEdgeInsets = .zero) {
        NSLayoutConstraint.activate([
            subView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: padding.left),
            subView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: padding.right),
            subView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: padding.top),
            subView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: padding.bottom)
        ])
    }
    
    func addConstraint(top: (anchor: NSLayoutYAxisAnchor, padding: CGFloat)? = nil,
                       bottom: (anchor: NSLayoutYAxisAnchor, padding: CGFloat)? = nil,
                       leading: (anchor: NSLayoutXAxisAnchor, padding: CGFloat)? = nil,
                       trailing: (anchor: NSLayoutXAxisAnchor, padding: CGFloat)? = nil,
                       centerX: (anchor: NSLayoutXAxisAnchor, padding: CGFloat)? = nil,
                       centerY: (anchor: NSLayoutYAxisAnchor, padding: CGFloat)? = nil) {
        if let top {
            let constraint = topAnchor.constraint(equalTo: top.anchor, constant: top.padding)
            constraint.priority = .required
            constraint.isActive = true
        }
        
        if let bottom {
            let constraint = bottomAnchor.constraint(equalTo: bottom.anchor, constant: bottom.padding)
            constraint.priority = .required
            constraint.isActive = true
        }
        
        if let leading {
            let constraint = leadingAnchor.constraint(equalTo: leading.anchor, constant: leading.padding)
            constraint.priority = .required
            constraint.isActive = true
        }
        
        if let trailing {
            let constraint = trailingAnchor.constraint(equalTo: trailing.anchor, constant: trailing.padding)
            constraint.priority = .required
            constraint.isActive = true
        }
        
        if let centerX {
            let constraint = centerXAnchor.constraint(equalTo: centerX.anchor, constant: centerX.padding)
            constraint.priority = .required
            constraint.isActive = true
        }
        
        if let centerY {
            let constraint = centerYAnchor.constraint(equalTo: centerY.anchor, constant: centerY.padding)
            constraint.priority = .required
            constraint.isActive = true
        }
    }
    
    @discardableResult
    func setHeightConstraint(
        with value: CGFloat,
        relatedBy: NSLayoutConstraint.Relation = .equal,
        priority: UILayoutPriority = .required
    ) -> NSLayoutConstraint {
        let heightConstraint = NSLayoutConstraint(item: self, attribute: .height, relatedBy: relatedBy, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: value)
        heightConstraint.priority = priority
        heightConstraint.isActive = true
        
        return heightConstraint
    }
    
    @discardableResult
    func setWidthConstraint(
        with value: CGFloat,
        relatedBy: NSLayoutConstraint.Relation = .equal,
        priority: UILayoutPriority = .required
    ) -> NSLayoutConstraint {
        let widthConstraint = NSLayoutConstraint(item: self, attribute: .width, relatedBy: relatedBy, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: value)
        widthConstraint.priority = priority
        widthConstraint.isActive = true
        
        return widthConstraint
    }
    
    @discardableResult
    func setHeightConstraint(
        with anchor: NSLayoutDimension,
        relatedBy: NSLayoutConstraint.Relation = .equal,
        priority: UILayoutPriority = .required,
        multiplier: CGFloat = 1,
        constant: CGFloat = .zero
    ) -> NSLayoutConstraint {
        switch relatedBy {
        case .lessThanOrEqual:
            let height = self.heightAnchor.constraint(lessThanOrEqualTo: anchor, multiplier: multiplier, constant: constant)
            height.priority = priority
            height.isActive = true
            return height
        case .greaterThanOrEqual:
            let height = self.heightAnchor.constraint(greaterThanOrEqualTo: anchor, multiplier: multiplier, constant: constant)
            height.priority = priority
            height.isActive = true
            return height
        default:
            let height = self.heightAnchor.constraint(equalTo: anchor, multiplier: multiplier, constant: constant)
            height.priority = priority
            height.isActive = true
            return height
        }
    }
    
    @discardableResult
    func setWidthConstraint(
        with anchor: NSLayoutDimension,
        relatedBy: NSLayoutConstraint.Relation = .equal,
        priority: UILayoutPriority = .required,
        multiplier: CGFloat = 1,
        constant: CGFloat = .zero
    ) -> NSLayoutConstraint {
        switch relatedBy {
        case .lessThanOrEqual:
            let width = self.widthAnchor.constraint(lessThanOrEqualTo: anchor, multiplier: multiplier, constant: constant)
            width.priority = priority
            width.isActive = true
            return width
        case .greaterThanOrEqual:
            let width = self.widthAnchor.constraint(greaterThanOrEqualTo: anchor, multiplier: multiplier, constant: constant)
            width.priority = priority
            width.isActive = true
            return width
        default:
            let width = self.widthAnchor.constraint(equalTo: anchor, multiplier: multiplier, constant: constant)
            width.priority = priority
            width.isActive = true
            return width
        }
    }
    
    func addSubviewWithDefaultConstraints(_ subView: UIView) {
        addSubview(subView)
        pinSubView(subView: subView)
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
        self.setupObservers()
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
    
    deinit {
        self.subviews.forEach { subView in
            print(String(describing: subView))
            subView.removeFromSuperview()
        }
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
    
    open func setupObservers() { }
}
