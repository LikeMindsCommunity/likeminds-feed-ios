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
}

public class LMUniversalFeedViewModel {
    public var selectedTopics: [(topicName: String, topicID: String)] = []
    public weak var delegate: LMUniversalFeedViewModelProtocol?
    
    init(delegate: LMUniversalFeedViewModelProtocol?) {
        self.selectedTopics = []
        self.delegate = delegate
    }
    
    public static func createModule() -> LMUniversalFeedViewController {
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
}
