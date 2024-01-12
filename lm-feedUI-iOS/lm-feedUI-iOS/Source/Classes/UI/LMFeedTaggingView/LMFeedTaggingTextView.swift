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
    public var startIndex: Int?
    public var characters: [Character] = []
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
        
        characters.removeAll()
        startIndex = nil
        
        for (idx, char) in Array(taggingText).reversed().enumerated() {
            if char == "@" {
                startIndex = selectedLocation - idx - 1
                isMentioning = true
                break
            } else if char == spaceChar || char == newLineChar {
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
            
            attrString.addAttributes([.foregroundColor: Appearance.shared.colors.textColor,
                                      .font: Appearance.shared.fonts.textFont1], range: NSRange(location: 0, length: attrString.length))
            
            
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
}


// MARK: UITextViewDelegate
extension LMFeedTaggingTextView: UITextViewDelegate {
    open func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text.isEmpty {
            if isMentioning {
                if range.length <= characters.count {
                    characters.removeLast(range.length)
                    mentionDelegate?.mentionStarted(with: String(characters))
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
        
        handleTagging(for: textView)
        return true
    }
    
    open func textViewDidChangeSelection(_ textView: UITextView) {
        var position = textView.selectedRange
        
        if isMentioning,
           let tempIndex = startIndex {
            if !(tempIndex...tempIndex + characters.count).contains(position.location) {
                startIndex = nil
                isMentioning.toggle()
                mentionDelegate?.mentionStopped()
                characters.removeAll(keepingCapacity: true)
            }
        }
        
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
    
    open func textViewDidChange(_ textView: UITextView) {
        mentionDelegate?.contentHeightChanged()
        handleTagging(for: textView)
    }
}