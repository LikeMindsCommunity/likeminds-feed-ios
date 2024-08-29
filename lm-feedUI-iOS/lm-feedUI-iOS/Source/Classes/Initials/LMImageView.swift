//
//  LMImageView.swift
//  LMFramework
//
//  Created by Devansh Mohata on 04/12/23.
//

import Kingfisher
import UIKit

@IBDesignable
public class LMImageView: UIImageView { 
    open func translatesAutoresizingMaskIntoConstraints() -> Self {
        translatesAutoresizingMaskIntoConstraints = false
        return self
    }
    
    public static func pickColor(alphabet: Character) -> UIColor {
        let alphabetColors = [0x5A8770, 0xB2B7BB, 0x6FA9AB, 0xF5AF29, 0x0088B9, 0xF18636, 0xD93A37, 0xA6B12E, 0x5C9BBC, 0xF5888D, 0x9A89B5, 0x407887, 0x9A89B5, 0x5A8770, 0xD33F33, 0xA2B01F, 0xF0B126, 0x0087BF, 0xF18636, 0x0087BF, 0xB2B7BB, 0x72ACAE, 0x9C8AB4, 0x5A8770, 0xEEB424, 0x407887]
        
        let numberColors = [0x5A8770, 0xB2B7BB, 0x6FA9AB, 0xF5AF29, 0x0088B9, 0xF18636, 0xD93A37, 0xA6B12E, 0x5C9BBC, 0xF5888D]
        
        let str = String(alphabet).unicodeScalars
        let unicode = Int(str[str.startIndex].value)
        
        if 65...90 ~= unicode {
            let hex = alphabetColors[unicode - 65]
            return .init(hex: hex)
        } else if 48...57 ~= unicode {
            let hex = numberColors[unicode - 48]
            return .init(hex: hex)
        }
        
        return UIColor.black
    }
}
