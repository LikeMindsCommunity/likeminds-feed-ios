//
//  LMFeedPostDocumentCell.swift
//  LMFramework
//
//  Created by Devansh Mohata on 13/12/23.
//

import UIKit

public protocol LMFeedPostDocumentCellProtocol: AnyObject {
    func didTapShowMoreDocuments(for indexPath: IndexPath)
}

@IBDesignable
open class LMFeedPostDocumentCell: LMPostWidgetTableViewCell {
    // MARK: Data Model
    public struct ViewModel: LMFeedPostTableCellProtocol {
        let headerData: LMFeedPostHeaderView.ViewModel
        let postText: String
        let documents: [LMFeedPostDocumentCellView.ViewModel]
        let isShowFullText: Bool
        var isShowAllDocuments: Bool
        var footerData: LMFeedPostFooterView.ViewModel
        
        init(headerData: LMFeedPostHeaderView.ViewModel,
             postText: String?,
             documents: [LMFeedPostDocumentCellView.ViewModel],
             footerData: LMFeedPostFooterView.ViewModel,
             isShowFullText: Bool = false,
             isShowAllDocuments: Bool = false) {
            self.headerData = headerData
            self.postText = postText ?? ""
            self.documents = documents
            self.footerData = footerData
            self.isShowFullText = isShowFullText
            self.isShowAllDocuments = isShowAllDocuments
        }
    }
    
    // MARK: UI Elements
    open private(set) lazy var contentStack: LMStackView = {
        let stack = LMStackView().translatesAutoresizingMaskIntoConstraints()
        stack.axis = .vertical
        stack.alignment = .leading
        stack.distribution = .fill
        stack.spacing = 8
        return stack
    }()
    
    open private(set) lazy var seeMoreDocumentsButton: LMButton = {
        if #available(iOS 15, *) {
            var btnConfig = UIButton.Configuration.plain()
            btnConfig.baseForegroundColor = Appearance.shared.colors.appTintColor
            btnConfig.contentInsets = .zero
            return LMButton(configuration: btnConfig).translatesAutoresizingMaskIntoConstraints()
        } else {
            let button = LMButton().translatesAutoresizingMaskIntoConstraints()
            button.contentEdgeInsets = .zero
            button.setTitleColor(Appearance.shared.colors.appTintColor, for: .normal)
            button.setTitle(nil, for: .normal)
            button.setImage(nil, for: .normal)
            return button
        }
    }()
    
    
    // MARK: Variables
    open var delegate: LMFeedPostDocumentCellProtocol?
    var indexPath: IndexPath?
    
    
    // MARK: setupViews
    open override func setupViews() {
        super.setupViews()
        
        contentView.addSubview(containerView)
        
        containerView.addSubview(headerView)
        containerView.addSubview(postText)
        containerView.addSubview(contentStack)
        containerView.addSubview(footerView)
    }
    
    
    // MARK: setupLayouts
    open override func setupLayouts() {
        super.setupLayouts()
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            
            headerView.topAnchor.constraint(equalTo: containerView.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            headerView.bottomAnchor.constraint(equalTo: postText.topAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 64),
            
            postText.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            postText.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            postText.bottomAnchor.constraint(equalTo: contentStack.topAnchor, constant: -8),
//            postText.heightAnchor.constraint(equalToConstant: 80),
            
            contentStack.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            contentStack.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            
            footerView.topAnchor.constraint(equalTo: contentStack.bottomAnchor),
            footerView.leadingAnchor.constraint(equalTo: contentStack.leadingAnchor),
            footerView.trailingAnchor.constraint(equalTo: contentStack.trailingAnchor),
            footerView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            footerView.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        postText.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
    }
    
    
    // MARK: setupAppearance
    open override func setupAppearance() {
        super.setupAppearance()
        backgroundColor = Appearance.shared.colors.clear
        contentView.backgroundColor = Appearance.shared.colors.clear
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
    open func configure(for indexPath: IndexPath, with data: ViewModel, delegate: (LMFeedPostDocumentCellProtocol & LMFeedTableCellToViewControllerProtocol)) {
        self.indexPath = indexPath
        self.delegate = delegate
        self.actionDelegate = delegate
        
        headerView.configure(with: data.headerData)
        postText.attributedText = GetAttributedTextWithRoutes.getAttributedText(from: data.postText)
        footerView.configure(with: data.footerData)
        
        contentStack.removeAllArrangedSubviews()
        
        data.documents.enumerated().forEach { index, document in
            guard index < 2 || data.isShowAllDocuments else { return }
            let documentView = LMFeedPostDocumentCellView(frame: .init(x: 0, y: 0, width: contentStack.frame.width, height: 90))
            documentView.configure(with: document, delegate: self)
            contentStack.addArrangedSubview(documentView)
            
            NSLayoutConstraint.activate([
                documentView.leadingAnchor.constraint(equalTo: contentStack.leadingAnchor),
                documentView.trailingAnchor.constraint(equalTo: contentStack.trailingAnchor)
            ])
        }
        
        if data.documents.count > 2 && !data.isShowAllDocuments {
            seeMoreDocumentsButton.setTitle("+\(data.documents.count - 2) more", for: .normal)
            seeMoreDocumentsButton.setImage(nil, for: .normal)
            
            contentStack.addArrangedSubview(seeMoreDocumentsButton)
            
            NSLayoutConstraint.activate([
                seeMoreDocumentsButton.leadingAnchor.constraint(equalTo: contentStack.leadingAnchor)
            ])
        }
    }
}

// MARK: LMChatDocumentCellViewProtocol
@objc
extension LMFeedPostDocumentCell: LMChatDocumentCellViewProtocol {
    open func didTapCrossButton(documentID: Int) { print(#function) }
    open func didTapDocument(documentID: Int) { print(#function) }
}
