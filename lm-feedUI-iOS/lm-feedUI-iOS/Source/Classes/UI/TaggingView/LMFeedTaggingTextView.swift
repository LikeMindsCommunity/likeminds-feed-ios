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
    func contentHeightChanged()
}

public extension LMFeedTaggingTextViewProtocol {
    func contentHeightChanged() { }
}

@IBDesignable
open class LMFeedTaggingTextView: LMTextView {
    public var rawText: String = ""
    public var isMentioning: Bool = false {
        willSet {
            if !newValue {
                mentionDelegate?.mentionStopped()
            }
        }
    }
    public var spaceChar: Character = " "
    public var newLineChar: Character = "\n"
    public var taggingCharacter: Character = LMFeedConstants.shared.strings.taggingCharacter
    public var isSpaceAdded: Bool = false
    public var startIndex: Int?
    public var characters: [Character] = []
    
    public weak var mentionDelegate: LMFeedTaggingTextViewProtocol?
    
    public func handleTagging() {
        let selectedLocation = selectedRange.location
        
        var encounteredRoute = false
        var taggingText = ""
        
        attributedText.enumerateAttributes(in: NSRange(location: 0, length: selectedLocation), options: .reverse) {attr, range, _ in
            if attr.contains(where: { $0.key == .route || $0.key == .link }) {
                encounteredRoute = true
            } else if !encounteredRoute {
                taggingText.append(attributedText.attributedSubstring(from: range).string)
            }
        }
        
        isMentioning = false
        taggingText = taggingText.trimmingCharacters(in: .whitespacesAndNewlines)
        isSpaceAdded = false
        characters.removeAll()
        startIndex = nil
        
        for (idx, char) in Array(taggingText).reversed().enumerated() {
            if char == taggingCharacter {
                startIndex = selectedLocation - idx - 1
                isMentioning = true
                break
            } else if char == spaceChar {
                if isSpaceAdded {
                    isMentioning = false
                    break
                } else {
                    isSpaceAdded = true
                }
            } else if char == newLineChar {
                isMentioning = false
                break
            }
            characters.append(char)
        }
        
        characters = characters.reversed()
        
        guard isMentioning else { return }
        
        mentionDelegate?.mentionStarted(with: String(characters))
    }
    
    public func addTaggedUser(with username: String, route: String) {
        if let startIndex {
            let partOneString = NSMutableAttributedString(attributedString: attributedText.attributedSubstring(from: NSRange(location: 0, length: startIndex)))
            let partTwoString = NSMutableAttributedString(attributedString: attributedText.attributedSubstring(from: NSRange(location: startIndex + 1 + characters.count, length: attributedText.length - startIndex - 1 - characters.count)))
            
            let attrName = NSAttributedString(string: "\(taggingCharacter)\(username.trimmingCharacters(in: .whitespacesAndNewlines))", attributes: [
                .font: LMFeedAppearance.shared.fonts.textFont1,
                .foregroundColor: LMFeedAppearance.shared.colors.linkColor,
                .route: route
            ])
            
            var newLocation = 1
            newLocation += partOneString.length
            newLocation += attrName.length
            
            partTwoString.insert(.init(string: " "), at: 0)
            
            let attrString =  NSMutableAttributedString(attributedString: partOneString)
            attrString.append(attrName)
            attrString.append(partTwoString)
            
            let tempAttrString = attrString
            
            tempAttrString.enumerateAttributes(in: NSRange(location: 0, length: tempAttrString.length)) { attr, range, _ in
                if attr.contains(where: { $0.key == .route }) {
                    attrString.addAttributes(linkTextAttributes, range: range)
                } else {
                    attrString.addAttributes(placeholderAttributes, range: range)
                }
            }
            
            attributedText = attrString
            selectedRange = NSRange(location: newLocation, length: 0)
            characters.removeAll(keepingCapacity: true)
            mentionDelegate?.contentHeightChanged()
        }
    }
    
    public override func getText() -> String {
        var message = ""
        
        attributedText.enumerateAttributes(in: NSRange(location: 0, length: attributedText.length)) { attr, range, _ in
            if let route = attr.first(where: { $0.key == .route })?.value as? String {
                message.append(route)
            } else {
                message.append(attributedText.attributedSubstring(from: range).string)
            }
        }
        message = message.trimmingCharacters(in: .whitespacesAndNewlines)
        return message != placeHolderText ? message : ""
    }
    
    public override func setAttributedText(from content: String, prefix: Character? = nil) {
        if !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            attributedText = GetAttributedTextWithRoutes.getAttributedText(from: content, andPrefix: prefix, allowLink: false, allowHashtags: false)
        } else {
            text = placeHolderText
            textColor = placeholderAttributes[.foregroundColor] as? UIColor
            font = placeholderAttributes[.font] as? UIFont
        }
    }
}


// MARK: UITextViewDelegate
extension LMFeedTaggingTextView {
    open func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text.isEmpty {
            if isMentioning {
                if range.length <= characters.count {
                    characters.removeLast(range.length)
                } else {
                    startIndex = nil
                    isMentioning.toggle()
                    characters.removeAll(keepingCapacity: true)
                }
            }
            
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
            
            mentionDelegate?.contentHeightChanged()
            return false
        }
        
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
        
        let attrString = NSMutableAttributedString(attributedString: textView.attributedText)
        
        textView.attributedText.enumerateAttributes(in: NSRange(location: 0, length: textView.attributedText.length)) { attr, range, _ in
            if attr.contains(where: { $0.key == .route }) {
                attrString.addAttributes(linkTextAttributes, range: range)
            } else {
                attrString.addAttributes(placeholderAttributes, range: range)
            }
        }
        
        textView.attributedText = attrString
        
        if textView.text != placeHolderText {
            handleTagging()
        }
    }
    
    open override func textViewDidChange(_ textView: UITextView) {
        mentionDelegate?.contentHeightChanged()
    }
    
    open override func textViewDidEndEditing(_ textView: UITextView) {
        super.textViewDidEndEditing(textView)
        
        mentionDelegate?.contentHeightChanged()
    }
}
