//
//  LMFeedPostDetailTotalCommentCell.swift
//  LMFramework
//
//  Created by Devansh Mohata on 18/12/23.
//

import UIKit

@IBDesignable
open class LMFeedPostDetailTotalCommentCell: LMTableViewHeaderFooterView {
    // MARK: UI Elements
    open private(set) lazy var containerView: LMView = {
        let view = LMView().translatesAutoresizingMaskIntoConstraints()
        return view
    }()
    
    open private(set) lazy var totalCommentLabel: LMLabel = {
        let label = LMLabel().translatesAutoresizingMaskIntoConstraints()
        label.font = Appearance.shared.fonts.headingFont3
        label.textColor = Appearance.shared.colors.gray1
        return label
    }()
    
    
    // MARK: setupViews
    open override func setupViews() {
        super.setupViews()
        
        contentView.addSubview(containerView)
        containerView.addSubview(totalCommentLabel)
    }
    
    
    // MARK: setupLayouts
    open override func setupLayouts() {
        super.setupLayouts()
        
        contentView.pinSubView(subView: containerView)
        containerView.pinSubView(subView: totalCommentLabel, padding: .init(top: 16, left: 16, bottom: -8, right: -16))
    }
    
    
    // MARK: setupAppearance
    open override func setupAppearance() {
        super.setupAppearance()
        containerView.backgroundColor = Appearance.shared.colors.white
    }
    
    
    // MARK: configure
    open func configure(with count: Int) {
        totalCommentLabel.text = "\(count) \(Constants.shared.strings.comments)"
    }
}
