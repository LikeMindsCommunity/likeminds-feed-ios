//
//  LMFeedPostFooterView.swift
//  LMFramework
//
//  Created by Devansh Mohata on 28/11/23.
//

import UIKit

@IBDesignable
open class LMFeedPostFooterView: LMFeedPostBaseFooterView {
    // MARK: View Hierachy
    open override func setupViews() {
        super.setupViews()
        
        contentView.addSubview(containerView)
        containerView.addSubview(actionStackView)
        [likeButton, likeTextButton, commentButton, spacer, saveButton, shareButton].forEach { actionStackView.addArrangedSubview($0) }
    }
    
    // MARK: -  Constraints
    open override func setupLayouts() {
        super.setupLayouts()
        
        contentView.pinSubView(subView: containerView, padding: .init(top: 0, left: 0, bottom: -8, right: 0))
        containerView.pinSubView(subView: actionStackView, padding: .init(top: 8, left: 16, bottom: -8, right: -16))
        
        [likeButton, likeTextButton, commentButton, saveButton, shareButton].forEach { btn in
            btn.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        }
    }
}
