//
//  LMFeedTopicSelectionViewModel.swift
//  likeminds-feed-iOS
//
//  Created by Devansh Mohata on 01/01/24.
//

import lm_feedUI_iOS
import LikeMindsFeed

public protocol LMFeedTopicSelectionViewModelProtocol: LMBaseViewControllerProtocol {
    func updateTopicList(with data: [[LMFeedTopicSelectionCell.ViewModel]], selectedCount: Int)
    func updateTopicFeed(with topics: [LMFeedTopicDataModel])
}

public class LMFeedTopicSelectionViewModel {
    public var currentPage: Int
    public var pageSize: Int
    public var isEnabled: Bool
    public var isShowAllTopicsButton: Bool
    public var searchType: String
    public var isFetching: Bool
    public var isLastTopicReached: Bool
    public var selectedTopicIds: [LMFeedTopicDataModel]
    public var searchString: String?
    public var topicList: [LMFeedTopicDataModel]
    public weak var delegate: LMFeedTopicSelectionViewModelProtocol?
    
    init(showOnlyEnabledTopics: Bool, isShowAllTopicsButton: Bool, selectedTopicIds: [LMFeedTopicDataModel], delegate: LMFeedTopicSelectionViewModelProtocol?) {
        self.currentPage = 1
        self.pageSize = 10
        self.isEnabled = showOnlyEnabledTopics
        self.isShowAllTopicsButton = isShowAllTopicsButton
        self.searchType = "name"
        self.isFetching = false
        self.isLastTopicReached = false
        self.selectedTopicIds = selectedTopicIds
        self.topicList = []
        self.delegate = delegate
    }
    
    public static func createModule(topicEnabledState: Bool, isShowAllTopicsButton: Bool, selectedTopicIds: [LMFeedTopicDataModel] = [], delegate: LMFeedTopicSelectionViewProtocol?) throws -> LMFeedTopicSelectionViewController {
        guard LMFeedMain.isInitialized else { throw LMFeedError.feedNotInitialized }
        
        let viewController = Components.shared.topicFeedSelectionScreen.init()
        let viewModel: LMFeedTopicSelectionViewModel = .init(
            showOnlyEnabledTopics: topicEnabledState,
            isShowAllTopicsButton: isShowAllTopicsButton,
            selectedTopicIds: selectedTopicIds,
            delegate: viewController
        )
        
        viewController.viewModel = viewModel
        viewController.delegate = delegate
        
        return viewController
    }
    
    public func getTopics(for search: String? = nil, isFreshSearch: Bool = false) {
        if isFreshSearch {
            currentPage = 1
            isLastTopicReached = false
            topicList.removeAll()
        }
        
        guard !isLastTopicReached,
              !isFetching else { return }
        
        isFetching = true
        
        var request = TopicFeedRequest.builder()
            .setEnableState(isEnabled)
            .setPage(currentPage)
            .setPageSize(pageSize)
        
        if let search,
           !search.isEmpty {
            request = request
                .setSearchTopic(search)
                .setSearchType(searchType)
                .build()
        }
        
        searchString = search
        
        LMFeedClient.shared.getTopicFeed(request) { [weak self] response in
            guard let self else { return }
            
            self.isFetching = false
            
            guard response.success,
            let topics = response.data?.topics else {
                return
            }
            
            
            var tempData: [LMFeedTopicDataModel] = topics.compactMap { topic in
                guard let id = topic.id,
                      let name = topic.name else { return nil }
                return .init(topicName: name, topicID: id, isEnabled: topic.isEnabled ?? false)
            }
            
            if isEnabled,
               currentPage == 1 {
                tempData.append(contentsOf: selectedTopicIds.filter({ !$0.isEnabled }))
            }

            self.topicList.append(contentsOf: tempData)
            self.convertToViewData()
            
            self.currentPage += 1
            self.isLastTopicReached = topics.isEmpty
        }
    }
    
    public func convertToViewData() {
        let convertedTopics: [LMFeedTopicSelectionCell.ViewModel] = topicList.map { topic in
                .init(topic: topic.topicName, topicID: topic.topicID, isSelected: selectedTopicIds.contains(where: { $0.topicID == topic.topicID }))
        }
        
        var convertedData: [[LMFeedTopicSelectionCell.ViewModel]] = []
        
        if isShowAllTopicsButton,
           searchString?.isEmpty != false {
            convertedData.append([.init(topic: "All Topics", topicID: nil, isSelected: selectedTopicIds.isEmpty)])
        }
        
        convertedData.append(convertedTopics)
        
        delegate?.updateTopicList(with: convertedData, selectedCount: selectedTopicIds.count)
    }
    
    public func didSelectTopic(at index: IndexPath) {
        if isShowAllTopicsButton,
           index.section == 0 {
            selectedTopicIds.removeAll()
        } else if let topic = topicList[safe: index.row] {
            if selectedTopicIds.contains(where: { $0.topicID == topic.topicID }) {
                selectedTopicIds.removeAll(where: { $0.topicID == topic.topicID })
            } else {
                selectedTopicIds.append(topic)
            }
        }
        
        convertToViewData()
    }
    
    public func didTapDoneButton() {
        let filteredTopics = topicList.filter { topic in
            selectedTopicIds.contains(where: { $0.topicID == topic.topicID })
        }
        
        delegate?.updateTopicFeed(with: filteredTopics)
    }
}
