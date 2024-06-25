//
//  LMFeedPollResultViewModel.swift
//  LikeMindsFeedCore
//
//  Created by Devansh Mohata on 17/06/24.
//

import LikeMindsFeed
import LikeMindsFeedUI

public protocol LMFeedPollResultViewModelProtocol: LMBaseViewControllerProtocol {
    func setupViewControllers(with pollID: String, optionList: [String], selectedID: Int)
    func loadOptionList(with data: [LMFeedPollResultCollectionCell.ContentModel], index: Int)
}

public final class LMFeedPollResultViewModel {
    let pollID: String
    var selectedOptionID: String?
    var optionList: [LMFeedPollDataModel.Option]
    weak var delegate: LMFeedPollResultViewModelProtocol?
    var userList: [LMFeedUserDataModel]
    var pageNo: Int
    let pageSize: Int
    var isAPIWorking: Bool
    var shouldCallAPI: Bool {
        didSet {
            print("Value changed: \(shouldCallAPI)")
        }
    }
    
    
    init(pollID: String, selectedOptionID: String? = nil, optionList: [LMFeedPollDataModel.Option], delegate: LMFeedPollResultViewModelProtocol? = nil) {
        self.pollID = pollID
        self.selectedOptionID = selectedOptionID ?? optionList.first?.id
        self.optionList = optionList
        self.delegate = delegate
        self.pageNo = 1
        self.pageSize = 10
        self.userList = []
        self.isAPIWorking = false
        self.shouldCallAPI = true
    }
    
    public static func createModule(with pollID: String, optionList: [LMFeedPollDataModel.Option], selectedOption: String?) throws -> LMFeedPollResultScreen {
        guard LMFeedCore.isInitialized else { throw LMFeedError.feedNotInitialized }
        
        let viewcontroller = Components.shared.pollResultScreen.init()
        let viewmodel = Self.init(pollID: pollID, selectedOptionID: selectedOption, optionList: optionList, delegate: viewcontroller)
        
        viewcontroller.viewmodel = viewmodel
        
        return viewcontroller
    }
    
    public func initializeView() {
        var selectedIndex = 0
        
        let transformedOptions: [LMFeedPollResultCollectionCell.ContentModel] = optionList.enumerated().map { id, option in
            if option.id == selectedOptionID {
                selectedIndex = id
            }
            
            return .init(optionID: option.id, title: option.option, voteCount: option.voteCount, isSelected: option.id == selectedOptionID)
        }
        
        delegate?.loadOptionList(with: transformedOptions, index: selectedIndex)
        delegate?.setupViewControllers(with: pollID, optionList: optionList.map(\.id), selectedID: selectedIndex)
    }
}
