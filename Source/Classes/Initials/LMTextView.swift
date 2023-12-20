//
//  LMTextView.swift
//  LMFramework
//
//  Created by Devansh Mohata on 18/12/23.
//

import UIKit

@IBDesignable
open class LMTextView: UITextView {
    open func translatesAutoresizingMaskIntoConstraints() -> Self {
        translatesAutoresizingMaskIntoConstraints = false
        return self
    }
    
    open var numberOfLines: Int {
        invalidateIntrinsicContentSize()
        if let font {
            return Int(intrinsicContentSize.height / font.lineHeight)
        }
        return .zero
    }
}
