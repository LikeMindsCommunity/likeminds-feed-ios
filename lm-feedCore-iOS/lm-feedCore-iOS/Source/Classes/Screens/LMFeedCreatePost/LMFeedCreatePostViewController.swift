//
//  LMFeedCreatePostViewController.swift
//  lm-feedCore-iOS
//
//  Created by Devansh Mohata on 16/01/24.
//

import lm_feedUI_iOS
import UIKit

@IBDesignable
open class LMFeedCreatePostViewController: LMViewController {
    // MARK: UI Elements
    open private(set) lazy var containerView: LMView = {
        let view = LMView().translatesAutoresizingMaskIntoConstraints()
        view.backgroundColor = Appearance.shared.colors.white
        return view
    }()
    
    open private(set) lazy var containerStackView: LMStackView = {
        let stack = LMStackView().translatesAutoresizingMaskIntoConstraints()
        stack.axis = .vertical
        stack.alignment = .center
        stack.distribution = .fill
        return stack
    }()
    
    open private(set) lazy var scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        return scroll
    }()
    
    open private(set) lazy var scrollStackView: LMStackView = {
        let stack = LMStackView().translatesAutoresizingMaskIntoConstraints()
        stack.axis = .vertical
        stack.alignment = .fill
        stack.distribution = .fill
        return stack
    }()
    
    open private(set) lazy var headerView: LMView = {
        let view = LMView().translatesAutoresizingMaskIntoConstraints()
        view.backgroundColor = Appearance.shared.colors.clear
        return view
    }()
    
    open private(set) lazy var topicView: LMFeedTopicView = {
        let view = LMUIComponents.shared.topicFeed.init().translatesAutoresizingMaskIntoConstraints()
        return view
    }()
    
    open private(set) lazy var inputTextView: LMFeedTaggingTextView = {
        let textView = LMFeedTaggingTextView().translatesAutoresizingMaskIntoConstraints()
        textView.dataDetectorTypes = [.link]
        return textView
    }()
    
    open private(set) lazy var linkPreview: LMView = {
        let view = LMUIComponents.shared.createPostLinkPreview.init().translatesAutoresizingMaskIntoConstraints()
        view.backgroundColor = Appearance.shared.colors.white
        return view
    }()
    
    open private(set) lazy var mediaCollectionView: LMCollectionView = {
        let collection = LMCollectionView().translatesAutoresizingMaskIntoConstraints()
        return collection
    }()
    
    open private(set) lazy var documentTableView: LMTableView = {
        let table = LMTableView().translatesAutoresizingMaskIntoConstraints()
        return table
    }()
    
    open private(set) lazy var addMoreButton: LMButton = {
        let button = LMButton().translatesAutoresizingMaskIntoConstraints()
        button.setTitle("Add More", for: .normal)
        button.setImage(Constants.shared.images.plusIcon, for: .normal)
        button.semanticContentAttribute = .forceRightToLeft
        button.tintColor = Appearance.shared.colors.appTintColor
        button.layer.borderColor = Appearance.shared.colors.appTintColor.cgColor
        button.layer.borderWidth = 1
        return button
    }()
    
    
    open private(set) lazy var addMediaStack: LMStackView = {
        let stack = LMStackView().translatesAutoresizingMaskIntoConstraints()
        stack.axis = .vertical
        stack.alignment = .fill
        stack.distribution = .fillEqually
        return stack
    }()
    
    open private(set) lazy var addPhotosTab: LMFeedCreatePostAddMediaView = {
        let view = LMUIComponents.shared.createPostAddMediaView.init().translatesAutoresizingMaskIntoConstraints()
        return view
    }()
    
    open private(set) lazy var addVideoTab: LMFeedCreatePostAddMediaView = {
        let view = LMUIComponents.shared.createPostAddMediaView.init().translatesAutoresizingMaskIntoConstraints()
        return view
    }()
    
    open private(set) lazy var addDocumentsTab: LMFeedCreatePostAddMediaView = {
        let view = LMUIComponents.shared.createPostAddMediaView.init().translatesAutoresizingMaskIntoConstraints()
        return view
    }()
    
    open override func setupViews() {
        super.setupViews()
        
        view.addSubview(containerView)
        
        containerView.addSubview(containerStackView)
        
        containerStackView.addArrangedSubview(scrollView)
        containerStackView.addArrangedSubview(addMediaStack)
        
        scrollView.addSubview(scrollStackView)
        
        [headerView, topicView, inputTextView, linkPreview, mediaCollectionView, documentTableView, addMoreButton].forEach { subView in
            scrollStackView.addArrangedSubview(subView)
        }
        
        [addPhotosTab, addVideoTab, addDocumentsTab].forEach { subView in
            addMediaStack.addArrangedSubview(subView)
        }
    }
    
    open override func setupLayouts() {
        super.setupLayouts()
        
        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            containerView.topAnchor.constraint(equalTo: view.topAnchor),
            containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            containerStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            containerStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            containerStackView.topAnchor.constraint(equalTo: containerView.topAnchor),
            containerStackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            
            scrollView.widthAnchor.constraint(equalTo: containerStackView.widthAnchor),
            
            scrollStackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            scrollStackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            scrollStackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            scrollStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            scrollStackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            headerView.heightAnchor.constraint(equalToConstant: 64),
            mediaCollectionView.heightAnchor.constraint(equalTo: mediaCollectionView.widthAnchor),
            
            addPhotosTab.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        let tableHeightConstraint = NSLayoutConstraint(item: documentTableView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 10)
        tableHeightConstraint.isActive = true
        
        let heightConstraint = NSLayoutConstraint(item: scrollStackView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 100)
        heightConstraint.priority = .defaultLow
        heightConstraint.isActive = true
    }
    open override func viewDidLoad() {
        super.viewDidLoad()
    }
}
