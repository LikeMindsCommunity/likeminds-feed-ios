//
//  LMUniversalFeedViewModel.swift
//  likeminds-feed-iOS
//
//  Created by Devansh Mohata on 28/12/23.
//

import lm_feedUI_iOS
import LikeMindsFeed

// MARK: LMUniversalFeedViewModelProtocol
public protocol LMUniversalFeedViewModelProtocol: LMBaseViewControllerProtocol {
    func loadTopics(with topics: [LMFeedTopicCollectionCellDataModel])
    func setupInitialView(isShowTopicFeed: Bool, isShowCreatePost: Bool)
}

public class LMUniversalFeedViewModel {
    public var isShowTopicFeed: Bool
    public var isShowCreatePostButton: Bool
    public var selectedTopics: [(topicName: String, topicID: String)] = []
    public let dispatchGroup: DispatchGroup
    public weak var delegate: LMUniversalFeedViewModelProtocol?
    
    init(delegate: LMUniversalFeedViewModelProtocol?) {
        self.isShowTopicFeed = false
        self.isShowCreatePostButton = false
        self.selectedTopics = []
        self.dispatchGroup = DispatchGroup()
        self.delegate = delegate
    }
    
    public static func createModule() -> LMUniversalFeedViewController? {
        guard LMFeedMain.isInitialized else { return nil }
        let viewController = Components.shared.universalFeedViewController.init()
        let viewModel: LMUniversalFeedViewModel = .init(delegate: viewController)
        
        viewController.viewModel = viewModel
        return viewController
    }
    
    func updateSelectedTopics(with selectedTopics: [(topicName: String, topicID: String)]) {
        self.selectedTopics = selectedTopics
        delegate?.loadTopics(with: selectedTopics.map { .init(topic: $0.topicName, topicID: $0.topicID) })
    }
    
    func removeTopic(id: String) {
        selectedTopics.removeAll(where: { $0.topicID == id })
        delegate?.loadTopics(with: selectedTopics.map { .init(topic: $0.topicName, topicID: $0.topicID) })
    }
    
    func initialSetup() {
        fetchTopics()
        fetchMemberState()
        
        dispatchGroup.notify(queue: .main) { [weak self] in
            guard let self else { return }
            delegate?.setupInitialView(isShowTopicFeed: isShowTopicFeed, isShowCreatePost: isShowCreatePostButton)
        }
    }
    
    func fetchTopics() {
        dispatchGroup.enter()
        let request = TopicFeedRequest.builder()
            .setEnableState(true)
            .build()
        
        LMFeedClient.shared.getTopicFeed(request) { [weak self] response in
            self?.isShowTopicFeed = !(response.data?.topics?.isEmpty ?? true)
            self?.dispatchGroup.leave()
        }
    }
    
    func fetchMemberState() {
        dispatchGroup.enter()
        
        LMFeedClient.shared.getMemberState { [weak self] response in
            if response.success,
               let memberState = response.data {
                LocalPreferences.memberState = memberState
                self?.isShowCreatePostButton = memberState.state == 1 || (memberState.memberRights ?? []).contains(where: { $0.state == .createPost })
            }
            
            self?.dispatchGroup.leave()
        }
    }
}
