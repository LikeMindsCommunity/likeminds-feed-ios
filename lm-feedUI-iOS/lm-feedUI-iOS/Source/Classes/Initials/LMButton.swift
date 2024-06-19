//
//  LMButton.swift
//  LMFramework
//
//  Created by Devansh Mohata on 30/11/23.
//

import UIKit

@IBDesignable
public class LMButton: UIButton {
    public override init(frame: CGRect) {
        super.init(frame: frame)
        tintAdjustmentMode = .normal
    }
    
    @available(*, unavailable, renamed: "init(frame:)")
    public required init?(coder: NSCoder) {
        fatalError("\(#function) not implemented in \(#filePath)")
    }
    
    public func translatesAutoresizingMaskIntoConstraints() -> Self {
        translatesAutoresizingMaskIntoConstraints = false
        return self
    }
    
    public func setFont(_ font: UIFont) {
        titleLabel?.font = font
    }
    
    public static func createButton(with title: String?, image: UIImage?, textColor: UIColor?, textFont: UIFont?, contentSpacing: UIEdgeInsets = .zero, imageSpacing: CGFloat = .zero) -> LMButton {
        if #available(iOS 15.0, *) {
            var config: LMButton.Configuration = .plain()
            
            config.title = title
            config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
                var outgoing = incoming
                outgoing.font = textFont
                outgoing.foregroundColor = textColor
                return outgoing
            }
            
            config.image = image
            config.contentInsets = .init(top: contentSpacing.top, leading: contentSpacing.left, bottom: contentSpacing.bottom, trailing: contentSpacing.right)
            config.imagePadding = imageSpacing
            return LMButton(configuration: config)
        } else {
            let button = LMButton()
            button.setTitle(title, for: .normal)
            button.setTitleColor(textColor, for: .normal)
            button.titleLabel?.font =  textFont
            button.setImage(image, for: .normal)
            button.contentEdgeInsets = contentSpacing
            button.setPreferredSymbolConfiguration(.init(font: textFont ?? .systemFont(ofSize: 16)), forImageIn: .normal)
            button.imageEdgeInsets = .init(top: imageSpacing, left: imageSpacing, bottom: imageSpacing, right: imageSpacing)
            
            return button
        }
    }
    
    public func setContentInsets(with insets: UIEdgeInsets) {
        if #available(iOS 15.0, *) {
            configuration?.contentInsets = .init(top: insets.top, leading: insets.left, bottom: insets.bottom, trailing: insets.right)
        } else {
            contentEdgeInsets = insets
        }
    }
    
    public func setImageInsets(with value: CGFloat) {
        if #available(iOS 15.0, *) {
            configuration?.imagePadding = value
        } else {
            imageEdgeInsets = .init(top: value, left: value, bottom: value, right: value)
        }
    }
    
    public func centerTextAndImage(spacing: CGFloat) {
        let insetAmount = spacing / 2
        let isRTL = UIView.userInterfaceLayoutDirection(for: semanticContentAttribute) == .rightToLeft
        if isRTL {
            imageEdgeInsets = UIEdgeInsets(top: 0, left: insetAmount, bottom: 0, right: -insetAmount)
            titleEdgeInsets = UIEdgeInsets(top: 0, left: -insetAmount, bottom: 0, right: insetAmount)
            contentEdgeInsets = UIEdgeInsets(top: 0, left: -insetAmount, bottom: 0, right: -insetAmount)
        } else {
            imageEdgeInsets = UIEdgeInsets(top: 0, left: -insetAmount, bottom: 0, right: insetAmount)
            titleEdgeInsets = UIEdgeInsets(top: 0, left: insetAmount, bottom: 0, right: -insetAmount)
            contentEdgeInsets = UIEdgeInsets(top: 0, left: insetAmount, bottom: 0, right: insetAmount)
        }
    }
}


// MARK: LMLoadingButton
public class LMLoadingButton: LMButton {
    var originalButtonText: String?
    var activityIndicator: UIActivityIndicatorView!
    
    public func showLoading() {
        originalButtonText = self.titleLabel?.text
        self.setTitle("", for: .normal)
        
        if (activityIndicator == nil) {
            activityIndicator = createActivityIndicator()
        }
        
        showSpinning()
    }
    
    public func hideLoading() {
        self.setTitle(originalButtonText, for: .normal)
        activityIndicator.stopAnimating()
    }
    
    private func createActivityIndicator() -> UIActivityIndicatorView {
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.hidesWhenStopped = true
        activityIndicator.color = UIColor.white
        return activityIndicator
    }
    
    private func showSpinning() {
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(activityIndicator)
        centerActivityIndicatorInButton()
        activityIndicator.startAnimating()
    }
    
    private func centerActivityIndicatorInButton() {
        let xCenterConstraint = NSLayoutConstraint(item: self, attribute: .centerX, relatedBy: .equal, toItem: activityIndicator, attribute: .centerX, multiplier: 1, constant: 0)
        self.addConstraint(xCenterConstraint)
        
        let yCenterConstraint = NSLayoutConstraint(item: self, attribute: .centerY, relatedBy: .equal, toItem: activityIndicator, attribute: .centerY, multiplier: 1, constant: 0)
        self.addConstraint(yCenterConstraint)
    }
}
