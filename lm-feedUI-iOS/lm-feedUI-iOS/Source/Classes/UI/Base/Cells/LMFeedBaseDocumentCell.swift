//
//  LMFeedBaseDocumentCell.swift
//  LikeMindsFeedUI
//
//  Created by Devansh Mohata on 23/07/24.
//

import UIKit

open class LMFeedBaseDocumentCell: LMPostWidgetTableViewCell {
    // MARK: UI Elements
    open private(set) lazy var documentContainerStack: LMStackView = {
        let stack = LMStackView().translatesAutoresizingMaskIntoConstraints()
        stack.axis = .vertical
        stack.alignment = .leading
        stack.distribution = .fill
        stack.spacing = 8
        return stack
    }()
        
    open private(set) lazy var seeMoreDocumentsButton: LMButton = {
        let button = LMButton.createButton(with: "See More", image: nil, textColor: LMFeedAppearance.shared.colors.appTintColor, textFont: LMFeedAppearance.shared.fonts.headingFont1, contentSpacing: .init(top: 8, left: 8, bottom: 8, right: 8))
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = LMFeedAppearance.shared.colors.appTintColor
        return button
    }()
    
    // MARK: Variables
    public weak var delegate: LMFeedPostDocumentCellProtocol?
    var indexPath: IndexPath?
    
    
    // MARK: setupAppearance
    open override func setupAppearance() {
        super.setupAppearance()
        backgroundColor = LMFeedAppearance.shared.colors.clear
        contentView.backgroundColor = LMFeedAppearance.shared.colors.clear
    }
    
    
    // MARK: setupActions
    open override func setupActions() {
        super.setupActions()
        seeMoreDocumentsButton.addTarget(self, action: #selector(didTapSeeMoreDocuments), for: .touchUpInside)
    }
    
    @objc
    open func didTapSeeMoreDocuments() {
        guard let indexPath else { return }
        delegate?.didTapShowMoreDocuments(for: indexPath)
    }
    
    
    // MARK: configure
    open func configure(for indexPath: IndexPath, with data: LMFeedPostContentModel, delegate: LMFeedPostDocumentCellProtocol?) {
        self.indexPath = indexPath
        self.delegate = delegate
        self.actionDelegate = delegate
        
        postID = data.postID
        userUUID = data.userUUID
                
        setupPostText(text: data.postText, showMore: data.isShowMore)
        
        topicFeed.configure(with: data.topics)
        
        topicFeed.isHidden = data.topics.topics.isEmpty
                
        documentContainerStack.removeAllArrangedSubviews()
        
        data.documents.enumerated().forEach { index, document in
            guard index < LMFeedConstants.shared.number.maxDocumentView || data.isShowMoreDocuments else { return }
            let documentView = LMUIComponents.shared.documentPreview.init()
            
            documentView.setHeightConstraint(with: LMFeedConstants.shared.number.documentPreviewSize)
            
            documentView.configure(with: document, delegate: self)
            documentContainerStack.addArrangedSubview(documentView)
            
            NSLayoutConstraint.activate([
                documentView.leadingAnchor.constraint(equalTo: documentContainerStack.leadingAnchor),
                documentView.trailingAnchor.constraint(equalTo: documentContainerStack.trailingAnchor)
            ])
        }
        
        if data.documents.count > LMFeedConstants.shared.number.maxDocumentView && !data.isShowMoreDocuments {
            seeMoreDocumentsButton.setTitle("+\(data.documents.count - LMFeedConstants.shared.number.maxDocumentView) more", for: .normal)
            seeMoreDocumentsButton.setImage(nil, for: .normal)
            
            documentContainerStack.addArrangedSubview(seeMoreDocumentsButton)
            
            NSLayoutConstraint.activate([
                seeMoreDocumentsButton.leadingAnchor.constraint(equalTo: documentContainerStack.leadingAnchor)
            ])
        }
    }
}


// MARK: LMFeedDocumentPreviewProtocol
@objc
extension LMFeedBaseDocumentCell: LMFeedDocumentPreviewProtocol {
    public func didTapDocument(documentID: URL) {
        delegate?.didTapDocument(with: documentID)
    }
}
