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
        
        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            
            documentPreview.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            documentPreview.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            documentPreview.topAnchor.constraint(equalTo: containerView.topAnchor),
            documentPreview.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
    }
    
    
    // MARK: configure
    open func configure(data: LMFeedDocumentPreview.ViewModel, delegate: LMFeedDocumentPreviewProtocol) {
        documentPreview.configure(with: data, delegate: delegate)
    }
}
