//
//  LMFeedCreatePostDocumentPreviewCell.swift
//  lm-feedCore-iOS
//
//  Created by Devansh Mohata on 18/01/24.
//

import UIKit

@IBDesignable
open class LMFeedCreatePostDocumentPreviewCell: LMTableViewCell {
    // MARK: UI Elements
    open private(set) lazy var documentPreview: LMFeedDocumentPreview = {
        let view = LMUIComponents.shared.documentPreview.init().translatesAutoresizingMaskIntoConstraints()
        return view
    }()
    
    
    // MARK: setupViews
    open override func setupViews() {
        contentView.addSubview(containerView)
        containerView.addSubview(documentPreview)
    }
    
    
    // MARK: setupLayouts
    open override func setupLayouts() {
        super.setupLayouts()
        
        contentView.pinSubView(subView: containerView, padding: .init(top: 0, left: 0, bottom: -16, right: 0))
        containerView.pinSubView(subView: documentPreview)
    }
    
    
    // MARK: setupAppearance
    open override func setupAppearance() {
        super.setupAppearance()
        backgroundColor = LMFeedAppearance.shared.colors.clear
    }
    
    // MARK: configure
    open func configure(data: LMFeedDocumentPreview.ContentModel, delegate: LMFeedDocumentPreviewProtocol) {
        documentPreview.configure(with: data, delegate: delegate)
    }
}
