//
//  LMFeedNotificationFeedViewModel.swift
//  lm-feedCore-iOS
//
//  Created by Devansh Mohata on 21/01/24.
//

import LikeMindsFeedUI
import LikeMindsFeed

public protocol LMFeedNotificationViewModelProtocol: LMBaseViewControllerProtocol {
    func showNotifications(with data: [LMFeedNotificationItem.ContentModel], indexPath: IndexPath?)
    func showHideTableLoader(isShow: Bool)
    func showError(with message: String)
    func showEmptyNotificationView()
}

public final class LMFeedNotificationFeedViewModel {
    public var currentPage: Int
    public var isFetchingNotifications: Bool
    public var isLastPage: Bool
    public var notifications: [LMFeedNotificationFeedDataModel]
    public weak var delegate: LMFeedNotificationViewModelProtocol?
    
    public init(delegate: LMFeedNotificationViewModelProtocol?) {
        self.currentPage = 1
        self.isFetchingNotifications = false
        self.isLastPage = false
        self.notifications = []
        self.delegate = delegate
    }
    
    public static func createModule() -> LMFeedNotificationFeedScreen {
        let viewcontroller = Components.shared.notificationScreen.init()
        let viewModel = LMFeedNotificationFeedViewModel(delegate: viewcontroller)
        
        viewcontroller.viewModel = viewModel
        return viewcontroller
    }
    
    func getNotifications(isInitialFetch: Bool) {
        if isInitialFetch {
            currentPage = 1
            isFetchingNotifications = false
            isLastPage = false
            notifications.removeAll(keepingCapacity: true)
        }
        
        guard !isFetchingNotifications,
              !isLastPage else { return }
        
        if currentPage == 1 {
            delegate?.showHideLoaderView(isShow: true)
        } else {
            delegate?.showHideTableLoader(isShow: true)
        }
        
        fetchNotifications()
    }
    
    private func fetchNotifications() {
        let request = GetNotificationFeedRequest.builder()
            .page(currentPage)
            .build()
        
        LMFeedClient.shared.getNotificationFeed(request) { [weak self] response in
            guard let self else { return }
            
            if currentPage == 1 {
                delegate?.showHideLoaderView(isShow: false)
            } else {
                delegate?.showHideTableLoader(isShow: false)
            }
            
            if response.success,
               let activities = response.data?.activities,
               let users = response.data?.users {
                let tempNotifications: [LMFeedNotificationFeedDataModel] = activities.compactMap { activity in
                    return self.convertToDataModel(from: activity, users: users)
                }
                
                isLastPage = activities.isEmpty
                notifications.append(contentsOf: tempNotifications)
                currentPage += 1
                convertToViewModel()
            } else if currentPage == 1 {
                delegate?.showEmptyNotificationView()
            }
        }
    }
    
    func convertToDataModel(from activity: Activity, users: [String: User]?) -> LMFeedNotificationFeedDataModel? {
        let users: [LMFeedUserDataModel] = activity.actionBy?.compactMap { actionBy in
            guard let userInfo = users?[actionBy],
                  let user = convertToUserModel(from: userInfo) else { return nil }
            return user
        } ?? []
        
        
        guard let id = activity.id,
              let text = activity.activityText,
              let cta = activity.cta,
              let user = users.last else { return nil }
        
        return .init(
            id: id,
            activityText: text,
            cta: cta,
            createdAt: activity.createdAt ?? .zero,
            attachmentType: getAttachmentType(from: activity.activityEntityData?.attachments?.first?.attachmentType ?? .unknown),
            isRead: activity.isRead ?? false,
            user: user)
    }
    
    func convertToUserModel(from user: User) -> LMFeedUserDataModel? {
        guard let username = user.name,
              let uuid = user.sdkClientInfo?.uuid else { return nil }
        return .init(userName: username, userUUID: uuid, userProfileImage: user.imageUrl, customTitle: user.customTitle)
    }
    
    func getAttachmentType(from attachment: AttachmentType) -> LMFeedNotificationFeedDataModel.AttachmentType {
        switch attachment {
        case .image:
            return .image
        case .video:
            return .video
        case .doc:
            return .document
        default:
            return .none
        }
    }
}

extension LMFeedNotificationFeedViewModel {
    func convertToViewModel(indexPath: IndexPath? = nil) {
        let convertedData: [LMFeedNotificationItem.ContentModel] = notifications.map { notification in
                .init(
                    notificationID: notification.id,
                    notification: notification.activityText,
                    user: notification.user,
                    time: DateUtility.timeIntervalPostWidget(timeIntervalInMilliSeconds: notification.createdAt),
                    isRead: notification.isRead,
                    mediaImage: notification.attachmentType.imageIcon,
                    route: notification.cta
                )
        }
        
        if convertedData.isEmpty {
            delegate?.showEmptyNotificationView()
        } else {
            delegate?.showNotifications(with: convertedData, indexPath: indexPath)
        }
    }
}

// MARK: Read Notification
extension LMFeedNotificationFeedViewModel {
    func markReadNotification(activityId: String) {
        guard let index = notifications.firstIndex(where: { $0.id == activityId }),
              !notifications[index].isRead else { return }
        
        let request = MarkReadNotificationRequest.builder()
            .activityId(activityId)
            .build()
        LMFeedClient.shared.markReadNotification(request) { [weak self] response in
            guard let self,
                  response.success else { return }
            notifications[index].isRead = true
            convertToViewModel(indexPath: IndexPath(row: index, section: 0))
        }
    }
}
