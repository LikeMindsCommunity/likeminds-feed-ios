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
    public var isSpaceAdded: Bool = false
    public var startIndex: Int?
    public var characters: [Character] = []
    public var placeHolderText: String? {
        didSet {
            text = placeHolderText
            textColor = placeHolderTextColor
            font = placeHolderFont
        }
    }
    public var placeHolderFont: UIFont = Appearance.shared.fonts.subHeadingFont1
    public var placeHolderTextColor: UIColor = Appearance.shared.colors.gray155
    
    public weak var mentionDelegate: LMFeedTaggingTextViewProtocol?
    
    public var textAttributes: [NSAttributedString.Key: Any] = [.font: Appearance.shared.fonts.textFont1,
                                                                .foregroundColor: Appearance.shared.colors.textColor]
    
    public override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        delegate = self
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        delegate = self
    }
    
    public func handleTagging() {
        let selectedLocation = selectedRange.location
        
        var encounteredRoute = false
        var taggingText = ""
        
        attributedText.enumerateAttributes(in: NSRange(location: 0, length: selectedLocation), options: .reverse) {attr, range, _ in
            if attr.contains(where: { $0.key == .route }) {
                encounteredRoute = true
            } else if !encounteredRoute {
                taggingText.append(attributedText.attributedSubstring(from: range).string)
            }
        }
        
        isSpaceAdded = false
        characters.removeAll()
        startIndex = nil
        
        for (idx, char) in Array(taggingText).reversed().enumerated() {
            if char == "@" {
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
            
            let attrName = NSAttributedString(string: "@\(username.trimmingCharacters(in: .whitespacesAndNewlines))", attributes: [
                .font: Appearance.shared.fonts.textFont1,
                .foregroundColor: Appearance.shared.colors.linkColor,
                .route: route
            ])
            
            var newLocation = partTwoString.string.isEmpty ? 1 : 0
            newLocation += partOneString.length
            newLocation += attrName.length
            
            if partTwoString.string.isEmpty {
                partTwoString.append(.init(string: " "))
            }
            
            let attrString =  NSMutableAttributedString(attributedString: partOneString)
            attrString.append(attrName)
            attrString.append(partTwoString)
            
            attrString.addAttributes(textAttributes, range: NSRange(location: 0, length: attrString.length))
            
            let tempAttrString = attrString
            
            tempAttrString.enumerateAttributes(in: NSRange(location: 0, length: tempAttrString.length)) { attr, range, _ in
                if attr.contains(where: { $0.key == .route }) {
                    attrString.addAttribute(.foregroundColor, value: Appearance.shared.colors.linkColor, range: range)
                }
            }
            
            attributedText = attrString
            selectedRange = NSRange(location: newLocation, length: 0)
        }
    }
    
    public func getText() -> String {
        var message = ""
        
        attributedText.enumerateAttributes(in: NSRange(location: 0, length: attributedText.length)) { attr, range, _ in
            if let route = attr.first(where: { $0.key == .route })?.value as? String {
                message.append(route)
            } else {
                message.append(attributedText.attributedSubstring(from: range).string)
            }
        }
        
        return message
    }
}


// MARK: UITextViewDelegate
extension LMFeedTaggingTextView: UITextViewDelegate {
    open func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text.isEmpty {
            if isMentioning {
                if range.length <= characters.count {
                    characters.removeLast(range.length)
//                    mentionDelegate?.mentionStarted(with: String(characters))
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
        
        handleTagging()
    }
    
    open func textViewDidChange(_ textView: UITextView) {
        mentionDelegate?.contentHeightChanged()
    }
    
    open func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == placeHolderText {
            textView.text = nil
        }
    }
    
    open func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            textView.text = placeHolderText
            textView.font = placeHolderFont
            textView.textColor = placeHolderTextColor
        }
    }
}
