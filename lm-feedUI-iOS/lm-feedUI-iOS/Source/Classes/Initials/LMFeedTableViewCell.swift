//
//  CellViewTableViewCell.swift
//  LMFramework
//
//  Created by Devansh Mohata on 27/11/23.
//

import UIKit

@IBDesignable
open class LMFeedTableViewCell: UITableViewCell {
    // MARK: UI Elements
    open private(set) lazy var containerView: LMFeedView = {
        let view = LMFeedView().translatesAutoresizingMaskIntoConstraints()
        view.backgroundColor = LMFeedAppearance.shared.colors.white
        return view
    }()
    
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initUI()
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        initUI()
    }
    
    deinit { }
    
    private func initUI() {
        setupViews()
        setupLayouts()
        setupActions()
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        setupAppearance()
    }
}

// MARK: LMViewLifeCycle
// Default Implementation is Empty.
extension LMFeedTableViewCell: LMFeedViewLifeCycle {
    open func setupViews() { }
    
    open func setupLayouts() { }
    
    open func setupActions() { }
    
    open func setupAppearance() { 
        selectionStyle = .none
        contentView.backgroundColor = LMFeedAppearance.shared.colors.clear
    }
    
    open func setupObservers() { }
}
