//
//  LMTaggingTextView.swift
//  lm-feedUI-iOS
//
//  Created by Devansh Mohata on 09/01/24.
//

import UIKit

public protocol LMFeedTaggingTextViewProtocol: AnyObject {
    func mentionStarted(with text: String)
    func mentionStopped()
}

@IBDesignable
open class LMFeedTaggingTextView: LMTextView {
    public var rawText: String = ""
    public var isMentioning: Bool = false
    public var spaceChar: Character = " "
    public var newLineChar: Character = "\n"
    public weak var mentionDelegate: LMFeedTaggingTextViewProtocol?
    
    public override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        delegate = self
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        delegate = self
    }
    
    public func handleTagging(for textView: UITextView) {
        let selectedLocation = textView.selectedRange.location
        let taggingText = (textView.text as NSString).substring(with: NSMakeRange(0, selectedLocation))
        var characters: [Character] = []
        
        isMentioning = false
        
        for char in Array(taggingText).reversed() {
            if char == "@" {
                isMentioning = true
                break
            } else if char == spaceChar || char == newLineChar {
                isMentioning = false
                break
            }
            characters.append(char)
        }
        
        guard isMentioning else {
            mentionDelegate?.mentionStopped()
            return
        }
        
        mentionDelegate?.mentionStarted(with: String(characters))
    }
}


// MARK: UITextViewDelegate
extension LMFeedTaggingTextView: UITextViewDelegate {
    open func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text.isEmpty {
            let attrString = NSMutableAttributedString(attributedString: textView.attributedText)
            var newRange = range
            
            textView.attributedText.enumerateAttributes(in: .init(location: 0, length: textView.attributedText.length)) { attributes, xRange, _ in
                if attributes.contains(where: { $0.key == .route }),
                   NSIntersectionRange(xRange, range).length > 0 {
                    newRange = NSUnionRange(newRange, xRange)
                }
            }
            
            attrString.deleteCharacters(in: newRange)
            textView.attributedText = attrString
            
            var oldSelectedRange = textView.endOfDocument
            
            if let newPos = textView.position(from: textView.beginningOfDocument, offset: newRange.lowerBound) {
                oldSelectedRange = newPos
            }
            
            textView.selectedTextRange = textView.textRange(from: oldSelectedRange, to: oldSelectedRange)
            return false
        }
        
        handleTagging(for: textView)
        return true
    }
    
    open func textViewDidChangeSelection(_ textView: UITextView) {
        var position = textView.selectedRange
        
        if position.length > .zero {
            textView.attributedText.enumerateAttributes(in: .init(location: 0, length: textView.attributedText.length)) { attr, range, _ in
                if attr.contains(where: { $0.key == .route }),
                   NSIntersectionRange(range, textView.selectedRange).length > 0 {
                    position = NSUnionRange(range, position)
                }
            }
            
            textView.selectedRange = position
        } else if let range = textView.attributedText.attributeRange(at: position.location, for: .route) {
            let distanceToStart = abs(range.location - position.location)
            let distanceToEnd = abs(range.location + range.length - position.location)
            
            if distanceToStart < distanceToEnd {
                textView.selectedRange = .init(location: range.location, length: 0)
            } else {
                textView.selectedRange = .init(location: range.location + range.length, length: 0)
            }
        }
    }
}
