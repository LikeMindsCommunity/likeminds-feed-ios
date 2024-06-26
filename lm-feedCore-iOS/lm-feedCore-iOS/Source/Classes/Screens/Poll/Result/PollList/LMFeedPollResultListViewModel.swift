//
//  LMFeedPollResultListViewModel.swift
//  LikeMindsFeedCore
//
//  Created by Devansh Mohata on 25/06/24.
//

import LikeMindsFeed
import LikeMindsFeedUI

public protocol LMFeedPollResultListViewModelProtocol: LMBaseViewControllerProtocol {
    func reloadResults(with userList: [LMFeedMemberItem.ContentModel])
    func showLoader()
    func showHideTableFooter(isShow: Bool)
}

public final class LMFeedPollResultListViewModel {
    let pollID: String
    let optionID: String
    var pageNo: Int
    let pageSize: Int
    var isFetching: Bool
    var shouldCallAPI: Bool
    var userList: [LMFeedUserDataModel]
    weak var delegate: LMFeedPollResultListViewModelProtocol?
    
    init(pollID: String, optionID: String, delegate: LMFeedPollResultListViewModelProtocol?) {
        self.pollID = pollID
        self.optionID = optionID
        self.pageNo = 1
        self.pageSize = 10
        self.isFetching = false
        self.shouldCallAPI = true
        self.userList = []
        self.delegate = delegate
    }
    
    public static func createModule(for pollID: String, optionID: String) -> LMFeedPollResultListScreen {
        let viewcontroller = Components.shared.pollResultList.init()
        
        let viewmodel = Self.init(pollID: pollID, optionID: optionID, delegate: viewcontroller)
        viewcontroller.viewmodel = viewmodel
        
        return viewcontroller
    }
    
    public func fetchUserList() {
        guard shouldCallAPI,
              !isFetching else { return }
        
        let request = GetPollVotesRequest
            .builder()
            .pollID(pollID)
            .options([optionID])
            .page(pageNo)
            .pageSize(pageSize)
            .build()
        
        LMFeedClient.shared.getPollVotes(request) { [weak self] response in
            defer {
                self?.isFetching = false
                self?.reloadResults(with: self?.userList ?? [])
            }
            
            if let users = response.data?.users,
               let voterList = response.data?.votes?.first(where: { $0.id == self?.optionID })?.users {
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
