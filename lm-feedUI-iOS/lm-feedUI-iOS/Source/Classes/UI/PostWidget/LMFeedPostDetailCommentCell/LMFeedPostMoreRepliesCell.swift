//
//  LMFeedPostMoreRepliesCell.swift
//  LMFramework
//
//  Created by Devansh Mohata on 18/12/23.
//

import UIKit

public protocol LMFeedPostMoreRepliesCellProtocol: AnyObject {
    func didTapMoreComments(for commentID: String)
}

@IBDesignable
open class LMFeedPostMoreRepliesCell: LMTableViewCell {
    public struct ViewModel: LMFeedPostCommentCellProtocol {
        let parentCommentId: String
        let commentCount: Int
        let totalComments: Int
        
        public init(parentCommentId: String, commentCount: Int, totalComments: Int) {
            self.parentCommentId = parentCommentId
            self.commentCount = commentCount
            self.totalComments = totalComments
        }
    }
    
    // MARK: UI Elements
    open private(set) lazy var staticLabel: LMLabel = {
        let label = LMLabel().translatesAutoresizingMaskIntoConstraints()
        label.font = Appearance.shared.fonts.headingFont3
        label.textColor = Appearance.shared.colors.blueGray
        label.text = "View more replies"
        return label
    }()
    
    open private(set) lazy var countLabel: LMLabel = {
        let label = LMLabel().translatesAutoresizingMaskIntoConstraints()
        label.font = Appearance.shared.fonts.subHeadingFont1
        label.textColor = Appearance.shared.colors.gray155
        return label
    }()
    
    open private(set) lazy var sepratorView: LMView = {
        let view = LMView().translatesAutoresizingMaskIntoConstraints()
        view.backgroundColor = Appearance.shared.colors.gray4
        return view
    }()
    
    
    // MARK: Data Variables
    public var commentId: String?
    weak var delegate: LMFeedPostMoreRepliesCellProtocol?
    
    
    // MARK: setupViews
    open override func setupViews() {
        super.setupViews()
        
        contentView.addSubview(containerView)
        
        containerView.addSubview(staticLabel)
        containerView.addSubview(countLabel)
        containerView.addSubview(sepratorView)
    }
    
    
    // MARK: setupLayouts
    open override func setupLayouts() {
        super.setupLayouts()
        
        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor),
            
            sepratorView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            sepratorView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            sepratorView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            sepratorView.heightAnchor.constraint(equalToConstant: 1),
            
            staticLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 32),
            staticLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 24),
            staticLabel.bottomAnchor.constraint(equalTo: sepratorView.topAnchor, constant: -24),
            
            countLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            countLabel.centerYAnchor.constraint(equalTo: staticLabel.centerYAnchor),
            countLabel.leadingAnchor.constraint(greaterThanOrEqualTo: staticLabel.trailingAnchor, constant: 16)
        ])
    }
    
    
    // MARK: setupActions
    open override func setupActions() {
        super.setupActions()
        
        containerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapView)))
    }
    
    @objc
    open func didTapView() {
        guard let commentId else { return }
        delegate?.didTapMoreComments(for: commentId)
    }
    
    
    // MARK: configure
    open func configure(with data: ViewModel, delegate: LMFeedPostMoreRepliesCellProtocol) {
        self.delegate = delegate
        countLabel.text = "\(data.commentCount) of \(data.totalComments)"
    }
}
