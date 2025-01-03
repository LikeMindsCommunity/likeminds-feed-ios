//
//  LMPostWidgetTableViewCell.swift
//  LMFramework
//
//  Created by Devansh Mohata on 17/12/23.
//

import UIKit

@IBDesignable
open class LMPostWidgetTableViewCell: LMTableViewCell {
    // MARK: UI Elements
    open private(set) lazy var contentStack: LMStackView = {
        let stack = LMStackView().translatesAutoresizingMaskIntoConstraints()
        stack.axis = .vertical
        stack.alignment = .center
        stack.distribution = .fill
        stack.spacing = 8
        return stack
    }()
    
    // MARK: Data Variables
    public weak var actionDelegate: LMPostWidgetTableViewCellProtocol?
    public var userUUID: String?
    public var postID: String?
    
    deinit { }
    
    // MARK: setupLayouts
    open override func setupLayouts() {
        super.setupLayouts()
    }
    
    open override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    // MARK: setupActions
    open override func setupActions() {
        super.setupActions()
        containerView.isUserInteractionEnabled = true
        containerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapPost)))
    }
    
    @objc
    open func didTapPost() {
        guard let postID else { return }
        actionDelegate?.didTapPost(postID: postID)
    }
}
