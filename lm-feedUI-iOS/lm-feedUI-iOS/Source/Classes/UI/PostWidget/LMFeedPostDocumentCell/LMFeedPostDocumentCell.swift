//
//  LMFeedPostDocumentCell.swift
//  LMFramework
//
//  Created by Devansh Mohata on 13/12/23.
//

import UIKit

public protocol LMFeedPostDocumentCellProtocol: AnyObject {
    func didTapShowMoreDocuments(for indexPath: IndexPath)
    func didTapDocument(with url: String)
}

@IBDesignable
open class LMFeedPostDocumentCell: LMPostWidgetTableViewCell {
    // MARK: Data Model
    public struct ViewModel: LMFeedPostTableCellProtocol {
        public var postID: String
        public var userUUID: String
        public var headerData: LMFeedPostHeaderView.ViewModel
        public var postText: String
        public var topics: LMFeedTopicView.ViewModel
        public let documents: [LMFeedDocumentPreview.ViewModel]
        public var isShowMore: Bool
        public var isShowAllDocuments: Bool
        public var footerData: LMFeedPostFooterView.ViewModel
        public var totalCommentCount: Int
        
        public init( postID: String,
                     userUUID: String,
                     headerData: LMFeedPostHeaderView.ViewModel,
                     topics: LMFeedTopicView.ViewModel?,
                     postText: String?,
                     documents: [LMFeedDocumentPreview.ViewModel],
                     footerData: LMFeedPostFooterView.ViewModel,
                     totalCommentCount: Int,
                     isShowMore: Bool = true,
                     isShowAllDocuments: Bool = false) {
            self.postID = postID
            self.userUUID = userUUID
            self.headerData = headerData
            self.postText = postText ?? ""
            self.topics = topics ?? .init()
            self.documents = documents
            self.footerData = footerData
            self.totalCommentCount = totalCommentCount
            self.isShowMore = isShowMore
            self.isShowAllDocuments = isShowAllDocuments
        }
    }
    
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
    public weak var delegate: LMFeedPostDocumentCellProtocol?
    var indexPath: IndexPath?
    
    
    // MARK: setupViews
    open override func setupViews() {
        super.setupViews()
        
        contentView.addSubview(containerView)
        
        containerView.addSubview(headerView)
        containerView.addSubview(contentStack)
        containerView.addSubview(footerView)
        
        [topicFeed, postText, seeMoreButton, documentContainerStack].forEach { subView in
            contentStack.addArrangedSubview(subView)
        }
    }
    
    
    // MARK: setupLayouts
    open override func setupLayouts() {
        super.setupLayouts()
                
        containerView.addConstraint(top: (contentView.topAnchor, 0),
                                    leading: (contentView.leadingAnchor, 0),
                                    trailing: (contentView.trailingAnchor, 0))
        containerView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -16).isActive = true
        
        headerView.setHeightConstraint(with: Constants.shared.number.postHeaderSize)
        headerView.addConstraint(
            top: (containerView.topAnchor, 0),
            bottom: (contentStack.topAnchor, -8),
            leading: (containerView.leadingAnchor, 0),
            trailing: (containerView.trailingAnchor, 0)
        )
        
        contentStack.addConstraint(leading: (headerView.leadingAnchor, 0), trailing: (headerView.trailingAnchor, 0))
        topicFeed.addConstraint(leading: (contentStack.leadingAnchor, 16), trailing: (contentStack.trailingAnchor, -16))
        postText.addConstraint(leading: (contentStack.leadingAnchor, 16), trailing: (contentStack.trailingAnchor, -16))
        documentContainerStack.addConstraint(leading: (contentStack.leadingAnchor, 16), trailing: (contentStack.trailingAnchor, -16))
        
        footerView.setHeightConstraint(with: Constants.shared.number.postFooterSize)
        footerView.addConstraint(
            top: (contentStack.bottomAnchor, 0),
            bottom: (containerView.bottomAnchor, 0),
            leading: (contentStack.leadingAnchor, 16),
            trailing: (contentStack.trailingAnchor, -16)
        )
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
    open func configure(for indexPath: IndexPath, with data: ViewModel, delegate: (LMFeedPostDocumentCellProtocol & LMFeedTableCellToViewControllerProtocol)?) {
        self.indexPath = indexPath
        self.delegate = delegate
        self.actionDelegate = delegate
        
        postID = data.postID
        userUUID = data.userUUID
        
        headerView.configure(with: data.headerData)
        
        setupPostText(text: data.postText, showMore: data.isShowMore)
        
        topicFeed.configure(with: data.topics)
        topicFeed.isHidden = data.topics.topics.isEmpty
        
        footerView.configure(with: data.footerData)
        
        documentContainerStack.removeAllArrangedSubviews()
        
        data.documents.enumerated().forEach { index, document in
            guard index < Constants.shared.number.maxDocumentView || data.isShowAllDocuments else { return }
            let documentView = LMUIComponents.shared.documentPreview.init()
            
            documentView.setHeightConstraint(with: Constants.shared.number.documentPreviewSize)
            
            documentView.configure(with: document, delegate: self)
            documentContainerStack.addArrangedSubview(documentView)
            
            NSLayoutConstraint.activate([
                documentView.leadingAnchor.constraint(equalTo: documentContainerStack.leadingAnchor),
                documentView.trailingAnchor.constraint(equalTo: documentContainerStack.trailingAnchor)
            ])
        }
        
        if data.documents.count > Constants.shared.number.maxDocumentView && !data.isShowAllDocuments {
            seeMoreDocumentsButton.setTitle("+\(data.documents.count - 2) more", for: .normal)
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
extension LMFeedPostDocumentCell: LMFeedDocumentPreviewProtocol {
    open func didTapDocument(documentID: String) {
        delegate?.didTapDocument(with: documentID)
    }
}
