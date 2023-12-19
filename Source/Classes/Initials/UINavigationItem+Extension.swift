//
//  UINavigation+Extension.swift
//  LMFramework
//
//  Created by Devansh Mohata on 07/12/23.
//

import UIKit

extension UINavigationItem {
    enum Direction {
        case left,
             right,
             centre
    }
    
    func setTitle(with titleText: String?, with alignment: Direction = .left) {
        guard let titleText else {
            titleView = nil
            return
        }
        
        let title = UILabel()
        title.text = titleText
        title.font = Appearance.shared.fonts.navigationFont
        title.textColor = Appearance.shared.colors.navigationTitleColor
        
        let stack = UIStackView()
        stack.axis = .horizontal
        
        switch alignment {
        case .centre:
            titleView = title
        default:
            let spacer = UIView()
            let constraint = spacer.widthAnchor.constraint(greaterThanOrEqualToConstant: 1)
            constraint.isActive = true
            constraint.priority = .defaultLow
            
            let viewsArray = alignment == .left ? [title, spacer] : [spacer, title]
            
            let stack = UIStackView(arrangedSubviews: viewsArray)
            stack.axis = .horizontal
            
            titleView = stack
        }
    }
}
