//
//  LMTextView.swift
//  LMFramework
//
//  Created by Devansh Mohata on 18/12/23.
//

import UIKit

@IBDesignable
open class LMTextView: UITextView {
    open var placeHolderText: String = "" {
        didSet {
            if text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                text = placeHolderText
            }
        }
    }
    
    open var numberOfLines: Int {
        invalidateIntrinsicContentSize()
        if let font {
            return Int(intrinsicContentSize.height / font.lineHeight)
        }
        return .zero
    }
    
    open func translatesAutoresizingMaskIntoConstraints() -> Self {
        translatesAutoresizingMaskIntoConstraints = false
        return self
    }
    
    public func addDoneButtonOnKeyboard() {
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        doneToolbar.barStyle = .default
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.doneButtonAction))
        
        let items = [flexSpace, done]
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        
        self.inputAccessoryView = doneToolbar
    }
    
    @objc
    public func doneButtonAction() {
        self.resignFirstResponder()
    }
}
