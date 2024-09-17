//
//  LMFeedQnAFeedScreen.swift
//  LikeMindsFeedCore
//
//  Created by Devansh Mohata on 06/08/24.
//

import LikeMindsFeedUI
import UIKit

open class LMFeedQnAFeedScreen: LMFeedBaseUniversalFeed {
    // MARK: Variables
    public override var showHeadingInCreatePost: Bool { true }
    
    
    open private(set) lazy var postList: LMFeedQnAPostListScreen? = {
        do {
            let vc = try LMFeedQnAPostListViewModel.createModule(with: self)
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
            let viewcontroller = try LMFeedQnASearchPostViewModel.createModule()
            navigationController?.pushViewController(viewcontroller, animated: true)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    
    open override func setupNavigationBar() {
        super.setupNavigationBar()
        
        let searchButton = UIBarButtonItem(image: LMFeedConstants.shared.images.searchIcon,
                                           style: .plain,
                                           target: self,
                                           action: #selector(didTapSearchButton))
        searchButton.tintColor = .black
        
        let notificationBell =  UIBarButtonItem(
            image: LMFeedConstants.shared.images.notificationBell,
            style: .plain,
            target: self,
            action: #selector(didTapNotificationButton))
        notificationBell.tintColor = .black
        
        navigationItem.rightBarButtonItems = [searchButton, notificationBell]
    }
}
