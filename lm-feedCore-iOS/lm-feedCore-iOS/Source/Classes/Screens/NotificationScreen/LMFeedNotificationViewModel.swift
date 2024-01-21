//
//  LMFeedNotificationViewModel.swift
//  lm-feedCore-iOS
//
//  Created by Devansh Mohata on 21/01/24.
//

import lm_feedUI_iOS
import LikeMindsFeed

public protocol LMFeedNotificationViewModelProtocol: LMBaseViewControllerProtocol {
    func showNotifications(with data: [LMFeedNotificationView.ViewModel])
    func showHideTableLoader(isShow: Bool)
    func showError(with message: String)
}

public final class LMFeedNotificationViewModel {
    public var currentPage: Int
    public var isFetchingNotifications: Bool
    public var isLastPage: Bool
    public var notifications: [LMFeedNotificationDataModel]
    public weak var delegate: LMFeedNotificationViewModelProtocol?
    
    public init(delegate: LMFeedNotificationViewModelProtocol?) {
        self.currentPage = 1
        self.isFetchingNotifications = false
        self.isLastPage = false
        self.notifications = []
        self.delegate = delegate
    }
    
    public static func createModule() -> LMFeedNotificationViewController {
        let viewcontroller = Components.shared.notificationScreen.init()
        let viewModel = LMFeedNotificationViewModel(delegate: viewcontroller)
        
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
        fetchNotifications()
    }
    
    private func fetchNotifications() {
        let request = GetNotificationFeedRequest.builder()
            .page(currentPage)
            .build()
        
        LMFeedClient.shared.getNotificationFeed(request) { [weak self] response in
            guard let self else { return }
            
            if response.success,
               let activities = response.data?.activities,
               let users = response.data?.users {
                let tempNotifications: [LMFeedNotificationDataModel] = activities.compactMap { activity in
                    return self.convertToDataModel(from: activity, users: users)
                }
                
                isLastPage = activities.isEmpty
                notifications.append(contentsOf: tempNotifications)
                currentPage += 1
                convertToViewModel()
            } else if currentPage == 1 {
                
            }
        }
    }
    
//    func markReadNotification(activityId: String?) {
//        guard let activityId = activityId else {return}
//        let request = MarkReadNotificationRequest.builder()
//            .activityId(activityId)
//            .build()
//        
//        LMFeedClient.shared.markReadNotification(request) {[weak self] response in
//            if response.success {
////                self?.delegate?.didReceiveMarkReadNotificationResponse()
//            } else {
////                self?.postErrorMessageNotification(error: response.errorMessage)
//            }
//        }
//    }
    
    
    
    func convertToDataModel(from activity: Activity, users: [String: User]?) -> LMFeedNotificationDataModel? {
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
    
    func getAttachmentType(from attachment: AttachmentType) -> LMFeedNotificationDataModel.AttachmentType {
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

extension LMFeedNotificationViewModel {
    func convertToViewModel() {
        let convertedData: [LMFeedNotificationView.ViewModel] = notifications.map { notification in
                .init(
                    notification: notification.activityText,
                    user: notification.user,
                    time: DateUtility.timeIntervalPostWidget(timeIntervalInMilliSeconds: notification.createdAt),
                    isRead: notification.isRead,
                    mediaImage: notification.attachmentType.imageIcon,
                    route: notification.cta
                )
        }
        
        delegate?.showNotifications(with: convertedData)
    }
}
