//
//  LMTappableLabel.swift
//  LMFramework
//
//  Created by Devansh Mohata on 04/12/23.
//

import UIKit

protocol LMTappableLabelDelegate: AnyObject {
    func didTapOnLink(_ link: String, linkType: NSAttributedString.Key)
}

public class LMTappableLabel: LMLabel {
    public struct NameWithRoute {
        var name: String
        var route: String
        
        func getIdFromRoute() -> String {
            self.route.components(separatedBy: "/").last ?? ""
        }
        
        public init(name: String, route: String) {
            self.name = name
            self.route = route
        }
    }
    
    weak var delegate: LMTappableLabelDelegate?
            
    @objc
    private func tappedLabel(_ tap: UITapGestureRecognizer) {
        guard let label = tap.view as? LMTappableLabel,
              label == self,
              tap.state == .ended else {
            return
        }
        let location = tap.location(in: label)
        processInteraction(at: location, wasTap: true)
    }
    
    private func processInteraction(at location: CGPoint, wasTap: Bool) {
        let label = self
        
        guard let attributedText = label.attributedText else {
            return
        }
        
        let textStorage = NSTextStorage(attributedString: attributedText)
        let textContainer = NSTextContainer(size: label.bounds.size)
        let layoutManager = NSLayoutManager()
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)
        
        textContainer.lineFragmentPadding = 0.0
        textContainer.lineBreakMode = label.lineBreakMode
        textContainer.maximumNumberOfLines = label.numberOfLines
        
        
        let characterIndex = layoutManager.characterIndex(for: location,
                                                          in: textContainer,
                                                          fractionOfDistanceBetweenInsertionPoints: nil)
        if characterIndex < textStorage.length {
            if let labelLink = attributedText.attribute(.link, at: characterIndex, effectiveRange: nil)  {
                self.delegate?.didTapOnLink(String(describing: labelLink), linkType: .link)
            } else if let labelLink = attributedText.attribute(.hashtags, at: characterIndex, effectiveRange: nil) {
                delegate?.didTapOnLink(String(describing: labelLink), linkType: .hashtags)
            } else if let labelLink = attributedText.attribute(.route, at: characterIndex, effectiveRange: nil) {
                delegate?.didTapOnLink(String(describing: labelLink), linkType: .route)
            }
        }
    }
    
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = url(at: touches) {
            delegate?.didTapOnLink(touch.link, linkType: touch.linkType)
            return
        }
        super.touchesEnded(touches, with: event)
    }
    
    private func url(at touches: Set<UITouch>) -> (link: String, linkType: NSAttributedString.Key)? {
        guard let attributedText,
              !attributedText.string.isEmpty,
              let touchLocation = touches.sorted(by: { $0.timestamp < $1.timestamp } ).last?.location(in: self),
              let textStorage = preparedTextStorage() else { return nil }
        
        let layoutManager = textStorage.layoutManagers[0]
        let textContainer = layoutManager.textContainers[0]
        
        let characterIndex = layoutManager.characterIndex(for: touchLocation, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
        guard characterIndex >= 0, characterIndex != NSNotFound else { return nil }
        
        // Glyph index is the closest to the touch, therefore also validate if we actually tapped on the glyph rect
        let glyphRange = layoutManager.glyphRange(forCharacterRange: NSRange(location: characterIndex, length: 1), actualCharacterRange: nil)
        let characterRect = layoutManager.boundingRect(forGlyphRange: glyphRange, in: textContainer)
        guard characterRect.contains(touchLocation) else { return nil }
        
        
        if let touchedString = attributedText.attribute(.link, at: characterIndex, effectiveRange: nil) {
            return (String(describing: touchedString), .link)
        } else if let touchedString = attributedText.attribute(.hashtags, at: characterIndex, effectiveRange: nil) {
            return (String(describing: touchedString), .hashtags)
        } else if let touchedString = attributedText.attribute(.route, at: characterIndex, effectiveRange: nil) {
            return (String(describing: touchedString), .route)
        }
        
        return nil
    }
    
    private func preparedTextStorage() -> NSTextStorage? {
            guard let attributedText = attributedText, attributedText.length > 0 else { return nil }
            
            // Creates and configures a text storage which matches with the UILabel's configuration.
            let layoutManager = NSLayoutManager()
            let textContainer = NSTextContainer(size: bounds.size)
            textContainer.lineFragmentPadding = 0
            let textStorage = NSTextStorage(string: "")
            layoutManager.addTextContainer(textContainer)
            textStorage.addLayoutManager(layoutManager)
            
            textContainer.lineBreakMode = lineBreakMode
            textContainer.size = textRect(forBounds: bounds, limitedToNumberOfLines: numberOfLines).size
            textStorage.setAttributedString(attributedText)
            
            return textStorage
        }
    
    /*:
     - Note:
     Use this method when you want to add Tappable Links in the Label text. Using the existing `.text` or `.attributedText` won't set the Tappable Link behaviour.
     */
    func setText(_ text: String) {
//        let tap = UITapGestureRecognizer(target: self, action: #selector(tappedLabel))
//        self.addGestureRecognizer(tap)
        self.isUserInteractionEnabled = true
        self.text = text
        
        var attributedString = replaceRouteToName(with: text)
        attributedString = detectAndHighlightHashtags(in: attributedString)
        attributedString = detectAndHighlightURLs(in: attributedString)
        
        self.attributedText = attributedString
    }
    
    func checkForUrls(text: String) -> [String] {
        do {
            let detector = try NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
            let matches = detector.matches(in: text, options: .reportCompletion, range: NSMakeRange(0, text.count))
            return matches.compactMap({$0.url?.absoluteString})
        } catch {
            debugPrint(error.localizedDescription)
        }
        return []
    }
    
    func detectAndHighlightURLs(in attributedString: NSMutableAttributedString) -> NSMutableAttributedString {
        do {
            let detector = try NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
            let text = attributedString.string
            let matches = detector.matches(in: text, options: [], range: NSRange(location: 0, length: text.count))

            for match in matches {
                if let url = match.url {
                    let range = match.range
                    attributedString.addAttribute(.link, value: url, range: range)
                    attributedString.addAttribute(.foregroundColor, value: Appearance.shared.colors.linkColor, range: range)
                }
            }
        } catch {
            print("Error creating URL detector: \(error)")
        }

        return attributedString
    }
    
    func detectAndHighlightHashtags(in attributedString: NSMutableAttributedString) -> NSMutableAttributedString {
        do {
            let detector = try NSRegularExpression(pattern: "#(\\w+)", options: [])
            let text = attributedString.string
            let matches = detector.matches(in: text, options: [], range: NSRange(location: 0, length: text.count))

            for match in matches {
                if let range = Range(match.range(at: 1), in: text) {
                    let hashtag = String(text[range])
                    
                    attributedString.addAttribute(.hashtags, value: hashtag, range: match.range)
                    attributedString.addAttribute(.foregroundColor, value: Appearance.shared.colors.hashtagColor, range: match.range)
                }
            }
        } catch {
            print("Error creating URL detector: \(error)")
        }

        return attributedString
    }
    
    func getUserNames(in answer: String) -> [NameWithRoute] {
        guard !answer.isEmpty else { return [] } // Handle nil case early
        
        let charSet = CharacterSet(charactersIn: "<<>>")
        
        let routeStringArray = answer.components(separatedBy: charSet)
            .filter { $0.contains("|") }
        
        let nameWithRoutes: [NameWithRoute] = routeStringArray.compactMap {
            let components = $0.split(separator: "|")
            guard components.count == 2 else { return nil }
            return NameWithRoute(name: String(components[0]), route: String(components[1]))
        }
        
        return nameWithRoutes
    }
    
    func replaceRouteToName(
        with answer: String,
        andPrefix prefix: String? = nil
    ) -> NSMutableAttributedString {
        let nameWithRoutes = getUserNames(in: answer)

        let attrString = NSMutableAttributedString(string: answer, attributes: [
            .foregroundColor: Appearance.shared.colors.textColor,
            .font: Appearance.shared.fonts.textFont1
        ])

        for nameWithRoute in nameWithRoutes {
            let routeString = "<<\(nameWithRoute.name.replacingOccurrences(of: "<<", with: ""))|\(nameWithRoute.route)>>"
            let replaceString = "\(prefix ?? "")\(nameWithRoute.name)"
            
            let replaceAttributes: [NSAttributedString.Key: Any] = [
                .foregroundColor: Appearance.shared.colors.userProfileColor,
                .route: nameWithRoute.route
            ]

            let newAttributedString = NSAttributedString(string: replaceString, attributes: replaceAttributes)

            var range = (attrString.string as NSString).range(of: routeString)
            while range.location != NSNotFound {
                attrString.replaceCharacters(in: range, with: newAttributedString)
                range = (attrString.string as NSString).range(of: routeString)
            }
        }

        return attrString
    }
}
