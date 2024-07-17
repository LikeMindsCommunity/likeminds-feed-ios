//
//  LMUniversalFeedViewModel.swift
//  likeminds-feed-iOS
//
//  Created by Devansh Mohata on 28/12/23.
//

import LikeMindsFeedUI
import LikeMindsFeed

// MARK: LMUniversalFeedViewModelProtocol
/// Protocol defining the interface for the Universal Feed View Controller.
/// This protocol extends LMBaseViewControllerProtocol and adds specific methods
/// for handling topic loading and initial view setup in the Universal Feed context.
public protocol LMUniversalFeedViewModelProtocol: LMBaseViewControllerProtocol {
    /// Loads and displays a list of topics in the view.
    /// This method should update the UI to reflect the current set of topics.
    /// - Parameter topics: An array of topic data models to be displayed in the feed.
    func loadTopics(with topics: [LMFeedTopicCollectionCellDataModel])
    
    /// Configures the initial state of the Universal Feed view.
    /// This method is called after the view model has determined the visibility states
    /// of various UI components based on fetched data and user permissions.
    /// - Parameters:
    ///   - isShowTopicFeed: Boolean indicating whether the topic feed should be visible.
    ///   - isShowCreatePost: Boolean indicating whether the create post button should be displayed.
    func setupInitialView(isShowTopicFeed: Bool, isShowCreatePost: Bool)
}

/// View Model for the Universal Feed Screen.
/// This class manages the business logic, data fetching, and state for the Universal Feed feature.
public class LMUniversalFeedViewModel {
    /// Indicates whether the topic feed should be displayed.
    /// This is determined based on whether any topics are available from the server.
    public var isShowTopicFeed: Bool
    
    /// Indicates whether the create post button should be shown.
    /// This is based on the user's permissions fetched from the server.
    public var isShowCreatePostButton: Bool
    
    /// Array of currently selected topics in the feed.
    /// This is used to filter the feed content based on user selection.
    public var selectedTopics: [LMFeedTopicDataModel]
    
    /// Dispatch group used to synchronize multiple asynchronous operations.
    /// This ensures that all necessary data is fetched before updating the UI.
    public let dispatchGroup: DispatchGroup
    
    /// Weak reference to the delegate implementing LMUniversalFeedViewModelProtocol.
    /// This is typically the view controller that will receive updates from this view model.
    public weak var delegate: LMUniversalFeedViewModelProtocol?
    
    /// Initializes the view model with default values and sets up the delegate.
    /// - Parameter delegate: The object that will receive updates from this view model.
    init(delegate: LMUniversalFeedViewModelProtocol?) {
        self.isShowTopicFeed = false
        self.isShowCreatePostButton = false
        self.selectedTopics = []
        self.dispatchGroup = DispatchGroup()
        self.delegate = delegate
    }
    
    /// Creates and returns a configured LMUniversalFeedScreen instance.
    /// This factory method ensures that the view controller and view model are properly connected.
    /// - Returns: An optional LMUniversalFeedScreen instance, or nil if LMFeedCore is not initialized.
    public static func createModule() -> LMUniversalFeedScreen? {
        // Check if the package is initialized. If setupFeed() hasn't been called, abort the function.
        guard LMFeedCore.isInitialized else { return nil }
        
        // Create the view controller using the shared component.
        // This allows clients to replace the default universal feed screen with their own custom implementation.
        let viewController = Components.shared.universalFeedScreen.init()
        
        // Create and associate the view model with the view controller
        let viewModel: LMUniversalFeedViewModel = .init(delegate: viewController)
        viewController.viewModel = viewModel
        
        return viewController
    }
    
    /// Updates the list of selected topics and notifies the delegate to update the UI.
    /// - Parameter selectedTopics: New array of selected topics to replace the current selection.
    func updateSelectedTopics(with selectedTopics: [LMFeedTopicDataModel]) {
        self.selectedTopics = selectedTopics
        // Convert the topic data models to collection cell data models and update the UI
        delegate?.loadTopics(with: selectedTopics.map { .init(topic: $0.topicName, topicID: $0.topicID) })
    }
    
    /// Removes a specific topic from the selected topics list and updates the UI.
    /// - Parameter id: Unique identifier of the topic to be removed.
    func removeTopic(id: String) {
        selectedTopics.removeAll(where: { $0.topicID == id })
        // Update the UI with the new list of selected topics
        delegate?.loadTopics(with: selectedTopics.map { .init(topic: $0.topicName, topicID: $0.topicID) })
    }
    
    /// Performs the initial setup by fetching necessary data from the server.
    /// This method triggers the fetching of topics and member state, then updates the UI.
    func initialSetup() {
        fetchTopics()
        fetchMemberState()
        
        // Once all async operations are complete, update the initial view state
        dispatchGroup.notify(queue: .main) { [weak self] in
            guard let self else { return }
            delegate?.setupInitialView(isShowTopicFeed: isShowTopicFeed, isShowCreatePost: isShowCreatePostButton)
        }
    }
    
    /// Fetches the list of available topics from the server.
    /// This method determines whether the topic feed should be displayed based on the server response.
    private func fetchTopics() {
        dispatchGroup.enter()
        let request = TopicFeedRequest.builder()
            .setEnableState(true)
            .build()
        
        LMFeedClient.shared.getTopicFeed(request) { [weak self] response in
            // Determine if the topic feed should be shown based on whether any topics are returned
            self?.isShowTopicFeed = !(response.data?.topics?.isEmpty ?? true)
            self?.dispatchGroup.leave()
        }
    }
    
    /// Fetches the current user's member state from the server.
    /// This determines the user's permissions, including whether they can create posts.
    private func fetchMemberState() {
        dispatchGroup.enter()
        
        LMFeedClient.shared.getMemberState { [weak self] response in
            if response.success,
               let memberState = response.data {
                LocalPreferences.memberState = memberState
                // Determine if the create post button should be shown based on member state and rights
                // memberState.state == 1 indicates the user is a community manager
                self?.isShowCreatePostButton = memberState.state == 1 || (memberState.memberRights ?? []).contains(where: { $0.state == .createPost })
            }
            
            self?.dispatchGroup.leave()
        }
    }
}
