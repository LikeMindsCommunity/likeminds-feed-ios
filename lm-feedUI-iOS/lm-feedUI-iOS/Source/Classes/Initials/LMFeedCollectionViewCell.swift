//
//  LMCollectionViewCell.swift
//  LMFramework
//
//  Created by Devansh Mohata on 01/12/23.
//

import UIKit

@IBDesignable
open class LMFeedCollectionViewCell: UICollectionViewCell {
    // MARK: UI Elements
    open private(set) lazy var containerView: LMFeedView = {
        let view = LMFeedView().translatesAutoresizingMaskIntoConstraints()
        view.backgroundColor = LMFeedAppearance.shared.colors.white
        return view
    }()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        initUI()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        initUI()
    }
    
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
// Default Implementation is Empty
extension LMFeedCollectionViewCell: LMFeedViewLifeCycle {
    open func setupViews() { }
    
    open func setupLayouts() { }
    
    open func setupActions() { }
    
    open func setupAppearance() { }
    
    open func setupObservers() { }
}
