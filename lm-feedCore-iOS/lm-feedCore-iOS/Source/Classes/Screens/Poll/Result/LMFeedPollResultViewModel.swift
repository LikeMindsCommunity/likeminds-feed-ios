//
//  LMFeedPollResultViewModel.swift
//  LikeMindsFeedCore
//
//  Created by Devansh Mohata on 17/06/24.
//

import LikeMindsFeed
import LikeMindsFeedUI

public protocol LMFeedPollResultViewModelProtocol: LMBaseViewControllerProtocol {
    func reloadResults(with userList: [LMFeedMemberItem.ContentModel])
    func showLoader()
    func showHideTableFooter(isShow: Bool)
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
        
        let viewcontroller = LMFeedPollResultScreen()
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
        
        guard let selectedOptionID else { return }
        fetchUserList(for: selectedOptionID)
    }
    
    public func fetchUserList(for optionID: String) {
        self.selectedOptionID = optionID
        
        pageNo = 1
        shouldCallAPI = true
        isAPIWorking = false
        userList.removeAll(keepingCapacity: true)
        
        fetchOption(for: optionID)
    }
    
    public func fetchUserList() {
        guard let selectedOptionID else { return }
        
        fetchOption(for: selectedOptionID)
    }
    
    
    func fetchOption(for optionID: String) {
        guard !isAPIWorking,
                shouldCallAPI else { return }
        
        isAPIWorking = true
        
        if pageNo == 1 {
            delegate?.showLoader()
        } else {
            delegate?.showHideTableFooter(isShow: true)
        }
        
        let request = GetPollVotesRequest
            .builder()
            .pollID(pollID)
            .options([optionID])
            .page(pageNo)
            .pageSize(pageSize)
            .build()
        
        LMFeedClient.shared.getPollVotes(request) { [weak self] response in
            defer {
                self?.isAPIWorking = false
                self?.reloadResults(with: self?.userList ?? [])
            }
            
            if let users = response.data?.users,
               let voterList = response.data?.votes?.first(where: { $0.id == optionID })?.users {
                var transformedUsers: [LMFeedUserDataModel] = []
                
                voterList.forEach { id in
                    if let user = users[id],
                       let uuid = user.sdkClientInfo?.uuid {
                        transformedUsers.append(.init(userName: user.name ?? "User", userUUID: uuid, userProfileImage: user.imageUrl, customTitle: user.customTitle))
                    }
                }
                
                self?.userList.append(contentsOf: transformedUsers)
                self?.shouldCallAPI = !transformedUsers.isEmpty
                self?.pageNo += 1
            } else {
                self?.shouldCallAPI = false
            }
        }
    }
    
    
    func sortItems(_ items: [LMFeedUserDataModel], basedOn sortedIDs: [String]) -> [LMFeedUserDataModel] {
        // Create a dictionary to store the order of each id in the sortedIDs array
        let orderDict = Dictionary(uniqueKeysWithValues: sortedIDs.enumerated().map { ($1, $0) })

        // Sort the items array based on the order defined in the sortedIDs array
        let sortedItems = items.sorted { (a, b) -> Bool in
            let indexA = orderDict[a.userUUID] ?? Int.max
            let indexB = orderDict[b.userUUID] ?? Int.max
            return indexA < indexB
        }

        return sortedItems
    }
    
    func reloadResults(with transformedUsers: [LMFeedUserDataModel]) {
        userList = transformedUsers
        
        let memberItems: [LMFeedMemberItem.ContentModel] = transformedUsers.map {
            .init(
                username: $0.userName,
                uuid: $0.userUUID,
                customTitle: $0.customTitle,
                profileImage: $0.customTitle
            )
        }
        
        delegate?.reloadResults(with: memberItems)
    }
}
