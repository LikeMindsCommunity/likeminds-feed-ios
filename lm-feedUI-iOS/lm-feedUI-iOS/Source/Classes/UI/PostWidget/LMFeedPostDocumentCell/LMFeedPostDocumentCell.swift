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
        public var postID: String
        public var userUUID: String
        public var headerData: LMFeedPostHeaderView.ViewModel
        public var postText: String
        public var topics: LMFeedTopicView.ViewModel
        public let documents: [LMFeedPostDocumentCellView.ViewModel]
        public let isShowFullText: Bool
        public var isShowAllDocuments: Bool
        public var footerData: LMFeedPostFooterView.ViewModel
        
        public init( postID: String,
                     userUUID: String,
                     headerData: LMFeedPostHeaderView.ViewModel,
                     topics: LMFeedTopicView.ViewModel?,
                     postText: String?,
                     documents: [LMFeedPostDocumentCellView.ViewModel],
                     footerData: LMFeedPostFooterView.ViewModel,
                     isShowFullText: Bool = false,
                     isShowAllDocuments: Bool = false) {
            self.postID = postID
            self.userUUID = userUUID
            self.headerData = headerData
            self.postText = postText ?? ""
            self.topics = topics ?? .init()
            self.documents = documents
            self.footerData = footerData
            self.isShowFullText = isShowFullText
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
    open var delegate: LMFeedPostDocumentCellProtocol?
    var indexPath: IndexPath?
    
    
    // MARK: setupViews
    open override func setupViews() {
        super.setupViews()
        
        contentView.addSubview(containerView)
        
        containerView.addSubview(headerView)
        containerView.addSubview(contentStack)
        containerView.addSubview(footerView)
        
        [topicFeed, postText, documentContainerStack].forEach { subView in
            contentStack.addArrangedSubview(subView)
        }
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
            headerView.bottomAnchor.constraint(equalTo: contentStack.topAnchor),
            headerView.heightAnchor.constraint(equalToConstant: Constants.shared.number.postHeaderSize),
            
            contentStack.leadingAnchor.constraint(equalTo: headerView.leadingAnchor),
            contentStack.trailingAnchor.constraint(equalTo: headerView.trailingAnchor),
            
            topicFeed.leadingAnchor.constraint(equalTo: contentStack.leadingAnchor, constant: 16),
            topicFeed.trailingAnchor.constraint(equalTo: contentStack.trailingAnchor, constant: -16),
            
            postText.leadingAnchor.constraint(equalTo: contentStack.leadingAnchor, constant: 16),
            postText.trailingAnchor.constraint(equalTo: contentStack.trailingAnchor, constant: -16),
            
            documentContainerStack.leadingAnchor.constraint(equalTo: contentStack.leadingAnchor, constant: 16),
            documentContainerStack.trailingAnchor.constraint(equalTo: contentStack.trailingAnchor, constant: -16),
            
            footerView.topAnchor.constraint(equalTo: contentStack.bottomAnchor),
            footerView.leadingAnchor.constraint(equalTo: contentStack.leadingAnchor, constant: 16),
            footerView.trailingAnchor.constraint(equalTo: contentStack.trailingAnchor, constant: -16),
            footerView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            footerView.heightAnchor.constraint(equalToConstant: 44)
        ])
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
        
        postText.attributedText = GetAttributedTextWithRoutes.getAttributedText(from: data.postText)
        postText.isHidden = data.postText.isEmpty
        
        topicFeed.configure(with: data.topics)
        topicFeed.isHidden = data.topics.topics.isEmpty
        
        footerView.configure(with: data.footerData)
        
        documentContainerStack.removeAllArrangedSubviews()
        
        data.documents.enumerated().forEach { index, document in
            guard index < 2 || data.isShowAllDocuments else { return }
            let documentView = LMFeedPostDocumentCellView(frame: .init(x: 0, y: 0, width: documentContainerStack.frame.width, height: 90))
            documentView.configure(with: document, delegate: self)
            documentContainerStack.addArrangedSubview(documentView)
            
            NSLayoutConstraint.activate([
                documentView.leadingAnchor.constraint(equalTo: documentContainerStack.leadingAnchor),
                documentView.trailingAnchor.constraint(equalTo: documentContainerStack.trailingAnchor)
            ])
        }
        
        if data.documents.count > 2 && !data.isShowAllDocuments {
            seeMoreDocumentsButton.setTitle("+\(data.documents.count - 2) more", for: .normal)
            seeMoreDocumentsButton.setImage(nil, for: .normal)
            
            documentContainerStack.addArrangedSubview(seeMoreDocumentsButton)
            
            NSLayoutConstraint.activate([
                seeMoreDocumentsButton.leadingAnchor.constraint(equalTo: documentContainerStack.leadingAnchor)
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
