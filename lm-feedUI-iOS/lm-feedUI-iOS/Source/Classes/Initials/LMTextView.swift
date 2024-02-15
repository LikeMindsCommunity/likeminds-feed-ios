//
//  LMTextView.swift
//  LMFramework
//
//  Created by Devansh Mohata on 18/12/23.
//

import UIKit

@IBDesignable
open class LMTextView: UITextView {
    public var placeHolderText: String = "" {
        didSet {
            if !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                text = placeHolderText
            }
        }
    }
    
    public var numberOfLines: Int {
        let numberOfGlyphs = layoutManager.numberOfGlyphs
        var index : Int = 0
        var lineRange = NSRange(location: NSNotFound, length: 0)
        var currentNumOfLines : Int = 0
        var numberOfParagraphJump : Int = 0
        
        while index < numberOfGlyphs {
            layoutManager.lineFragmentRect(forGlyphAt: index, effectiveRange: &lineRange)
            index = NSMaxRange(lineRange)
            currentNumOfLines += 1
            
            // Observing whether user went to line and if it's the first such line break, accounting for it.
            if text.last == "\n", numberOfParagraphJump == 0 {
                numberOfParagraphJump = 1
            }
        }
        
        currentNumOfLines += numberOfParagraphJump
        
        return currentNumOfLines
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
