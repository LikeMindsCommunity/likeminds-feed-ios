//
//  LMFeedPostDetailTotalCommentCell.swift
//  LMFramework
//
//  Created by Devansh Mohata on 18/12/23.
//

import UIKit

@IBDesignable
open class LMFeedPostDetailTotalCommentCell: LMTableViewCell {
    public struct ViewModel: LMFeedPostCommentCellProtocol {
        public var postID: String
        let totalComments: Int
        
        public init(postID: String, totalComments: Int) {
            self.postID = postID
            self.totalComments = totalComments
        }
    }
    
    // MARK: UI Elements
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
        
        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor),
            
            totalCommentLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            totalCommentLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 24),
            totalCommentLabel.trailingAnchor.constraint(lessThanOrEqualTo: containerView.trailingAnchor),
            totalCommentLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -4)
        ])
    }
    
    
    // MARK: setupAppearance
    open override func setupAppearance() {
        super.setupAppearance()
        
        backgroundColor = Appearance.shared.colors.clear
        contentView.backgroundColor = Appearance.shared.colors.clear
    }
    
    
    // MARK: configure
    func configure(with data: ViewModel) {
        totalCommentLabel.text = "\(data.totalComments) \(Constants.shared.strings.comments)"
    }
}
