//
//  LMButton.swift
//  LMFramework
//
//  Created by Devansh Mohata on 30/11/23.
//

import UIKit

@IBDesignable
open class LMButton: UIButton {
    public override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    @available(*, unavailable, renamed: "init(frame:)")
    public required init?(coder: NSCoder) {
        fatalError("\(#function) not implemented in \(#filePath)")
    }
    
    open func translatesAutoresizingMaskIntoConstraints() -> Self {
        translatesAutoresizingMaskIntoConstraints = false
        return self
    }
    
    open func setFont(_ font: UIFont) {
        titleLabel?.font = font
    }
}

import UIKit

extension UIButton {
    @available(iOS 15.0, *)
    static func createForiOS15(title: String, titleFont: UIFont, titleSpacing: CGFloat, image: UIImage?, imageSize: CGSize, contentPadding: UIEdgeInsets, titlePadding: UIEdgeInsets) -> UIButton {
        let button = UIButton(type: .system)

        // Configure button properties for iOS 15
        var config = UIButton.Configuration.filled()
        
        config.title = title
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = titleFont
            return outgoing
        }
        
        config.tit
        
//        config.titleSpacing = titleSpacing
//        config.image = image
//        config.imageSize = imageSize
//        config.contentInsets = contentPadding
//        config.imagePadding = titlePadding

        button.configuration = config

        return button
    }

    static func createForiOS13(title: String, titleFont: UIFont, image: UIImage?, imageSize: CGSize, contentPadding: UIEdgeInsets, titlePadding: UIEdgeInsets) -> UIButton {
        let button = UIButton(type: .system)

        // Configure button properties for iOS 13
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = titleFont
        button.tintColor = UIColor.systemBlue
        button.setImage(image, for: .normal)
        button.imageEdgeInsets = titlePadding
        button.titleEdgeInsets = titlePadding
        button.contentEdgeInsets = contentPadding

        return button
    }

    static func createCustomButton(title: String, titleFont: UIFont, titleSpacing: CGFloat, image: UIImage?, imageSize: CGSize, contentPadding: UIEdgeInsets, titlePadding: UIEdgeInsets) -> UIButton {
        if #available(iOS 15.0, *) {
            return createForiOS15(title: title, titleFont: titleFont, titleSpacing: titleSpacing, image: image, imageSize: imageSize, contentPadding: contentPadding, titlePadding: titlePadding)
        } else {
            return createForiOS13(title: title, titleFont: titleFont, image: image, imageSize: imageSize, contentPadding: contentPadding, titlePadding: titlePadding)
        }
    }
}

// Example usage
let customButton = UIButton.createCustomButton(
    title: "Custom Button",
    titleFont: UIFont.systemFont(ofSize: 16),
    titleSpacing: 5.0,
    image: UIImage(named: "icon"),
    imageSize: CGSize(width: 30, height: 30),
    contentPadding: UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16),
    titlePadding: UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
)

// Add customButton to your view or perform other actions
