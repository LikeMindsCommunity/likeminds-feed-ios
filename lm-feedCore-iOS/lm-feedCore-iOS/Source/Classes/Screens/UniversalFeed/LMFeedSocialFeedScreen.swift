//
//  LMFeedSocialFeedScreen.swift
//  LMFramework
//
//  Created by Devansh Mohata on 28/11/23.
//

import LikeMindsFeedUI
import UIKit

open class LMFeedSocialFeedScreen: LMFeedBaseUniversalFeed {
    // MARK: UI Elements
    open private(set) lazy var postList: LMFeedPostListScreen? = {
        do {
            let vc = try LMFeedPostListViewModel.createModule(with: self)
            return vc
        } catch let error {
            print(error.localizedDescription)
            return nil
        }
    }()

    
    // MARK: setupViews
    open override func setupViews() {
        super.setupViews()
        view.addSubview(contentStack)
        view.addSubview(createPostButton)
        
        contentStack.addArrangedSubview(createPostLoaderView)
        contentStack.addArrangedSubview(topicContainerView)
        if let postList {
            addChild(postList)
            contentStack.addArrangedSubview(postList.view)
            postList.didMove(toParent: self)
        }
        
        topicContainerView.addSubview(topicStackView)
        topicStackView.addArrangedSubview(topicSelectionButton)
        topicStackView.addArrangedSubview(topicCollection)
        topicStackView.addArrangedSubview(clearButton)
    }
    
    
    // MARK: setupLayouts
    open override func setupLayouts() {
        super.setupLayouts()
        
        view.pinSubView(subView: contentStack)
        
        topicStackView.addConstraint(top: (topicContainerView.topAnchor, 0),
                                     bottom: (topicContainerView.bottomAnchor, 0),
                                     leading: (topicContainerView.leadingAnchor, 16))
        
        topicCollection.addConstraint(top: (topicStackView.topAnchor, 0),
                                      bottom: (topicStackView.bottomAnchor, 0))
        
        createPostButton.addConstraint(bottom: (view.safeAreaLayoutGuide.bottomAnchor, -16),
                                       trailing: (view.safeAreaLayoutGuide.trailingAnchor, -16))
        NSLayoutConstraint.activate([
            topicStackView.trailingAnchor.constraint(lessThanOrEqualTo: topicContainerView.trailingAnchor, constant: -16),
        ])
        
        createPostLoaderView.setHeightConstraint(with: 64)
        topicContainerView.setHeightConstraint(with: 50)
        createPostButton.setHeightConstraint(with: 50)
        topicCollection.setWidthConstraint(with: 100, relatedBy: .greaterThanOrEqual)
        topicCollection.setWidthConstraint(with: 500, priority: .defaultLow)
        
        createPostButtonWidth = createPostButton.setWidthConstraint(with: createPostButton.heightAnchor)
        createPostButtonWidth?.isActive = false
        
        topicSelectionButton.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        clearButton.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
    }
    
    
    // MARK: setupActions
    open override func setupActions() {
        super.setupActions()
        
        feedListDelegate = postList
    }
    
    open override func didTapSearchButton() {
        do {
            let viewcontroller = try LMFeedSearchPostViewModel.createModule()
            navigationController?.pushViewController(viewcontroller, animated: true)
        } catch {
            print(error.localizedDescription)
        }
    }
}
