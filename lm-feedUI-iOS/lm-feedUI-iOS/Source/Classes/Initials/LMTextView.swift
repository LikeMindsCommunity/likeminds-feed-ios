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
    
    public var placeholderAttributes: [NSAttributedString.Key: Any] = [.font: LMFeedAppearance.shared.fonts.textFont1,
                                                                .foregroundColor: LMFeedAppearance.shared.colors.textColor]
    
    public var textAttributes: [NSAttributedString.Key: Any] = [.font: LMFeedAppearance.shared.fonts.textFont1,
                                                                .foregroundColor: LMFeedAppearance.shared.colors.gray51]
    
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
    
    public var textChangedObserver: (() -> Void)?
    
    public override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        backgroundColor = LMFeedAppearance.shared.colors.clear
        delegate = self
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        backgroundColor = LMFeedAppearance.shared.colors.clear
        delegate = self
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
    
    public func setAttributedText(from content: String, prefix: Character? = nil) {
        if !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            text = content
            textColor = textAttributes[.foregroundColor] as? UIColor
            font = textAttributes[.font] as? UIFont
        } else {
            text = placeHolderText
            textColor = placeholderAttributes[.foregroundColor] as? UIColor
            font = placeholderAttributes[.font] as? UIFont
        }
    }
    
    public func getText() -> String {
        let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if trimmedText.isEmpty || trimmedText == placeHolderText {
            return ""
        }
        
        return trimmedText
    }
}


extension LMTextView: UITextViewDelegate {
    open func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == placeHolderText {
            textView.text = nil
            textColor = textAttributes[.foregroundColor] as? UIColor
            font = textAttributes[.font] as? UIFont
        }
    }
    
    open func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            textView.attributedText = NSAttributedString(string: placeHolderText, attributes: placeholderAttributes)
        }
    }
    
    open func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        textChangedObserver?()
        
        return true
    }
}
