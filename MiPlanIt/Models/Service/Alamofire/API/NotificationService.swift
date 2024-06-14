//
//  NotificationService.swift
//  MiPlanIt
//
//  Created by Arun on 16/04/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

class NotificationService {
    
    func fetchNotificationOfUser(_ user: PlanItUser, page: Int, itemsPerPage:
        Int, callback: @escaping ([PlanItUserNotification]?, String?) -> ()) {
        let notificationCommand = NotificationCommand()
        notificationCommand.notifications(["userId": user.readValueOfUserId(), "page": page, "perPage": itemsPerPage], callback: { response, error in
            if let result = response, let notifications = result["UserNotifications"] as? [[String: Any]] {
                if let count = result["count"] as? Double { user.saveNotificationCount(count) }
                if page == 1 { DatabasePlanItUserNotification().deleteAllNotifications() }
                let planitUserNotification = DatabasePlanItUserNotification().insertOrUpdateUserNotification(notifications)
                callback(planitUserNotification, nil)
            }
            else {
                callback(nil, error)
            }
        })
    }
    
    func sendUser(_ user: PlanItUser, notifications: [UserNotification], status: Int, callback: @escaping ([PlanItUserNotification]?, String?) -> ()) {
        let notificationCommand = NotificationCommand()
        let params = notifications.map({ return ["userId": user.readValueOfUserId(), "notificationId": $0.readNotificationId(), "actvityType": $0.readActvityType(), "notificationAction": $0.readOrginalNotificationAction(), "receiverStatus": status, "modifiedAt": Date().stringFromDate(format: DateFormatters.YYYYHMMDDSHHMMSS, timeZone: TimeZone(abbreviation: "UTC")!)] })
        notificationCommand.sendAction(["reqData": params], callback: { response, error in
            if let result = response, let notificationData = result["notificationData"] as? [[String: Any]] {
                let planitUserNotification = DatabasePlanItUserNotification().insertOrUpdateUserNotification(notificationData)
                callback(planitUserNotification, nil)
            }
            else {
                callback(nil, error)
            }
        })
    }
    
    func registerNotificationForUser(completion: (() -> ())? = nil) {
        guard !Session.shared.readDeviceToken().isEmpty else { return }
        let notificationCommand = NotificationCommand()
        notificationCommand.remoteNotification(["userId": Session.shared.readUserId(), "deviceId": Session.shared.readDeviceId(), "deviceToken": Session.shared.readDeviceToken()], callback: { result , error in
            completion?()
        })
    }
    
    func deregisterNotificationForUser(completion: (() -> ())? = nil) {
        let notificationCommand = NotificationCommand()
        notificationCommand.remoteNotification(["userId": Session.shared.readUserId(), "deviceId": Session.shared.readDeviceId(), "deviceToken": Strings.empty], callback: { result , error in
            completion?()
        })
    }
    
    func deleteNotification(_ user: PlanItUser, notifications: [UserNotification], type: NotificationDelete, activityType: [Int], completion: @escaping (Bool, String?) -> ()) {
        guard !Session.shared.readDeviceToken().isEmpty else { return }
        let notificationCommand = NotificationCommand()
        let params: [String: Any] = ["userId": user.readValueOfUserId(), "notificationId": notifications.compactMap({$0.readNotificationId()}), "activityType": activityType, "type": type.rawValue]
        notificationCommand.deleteNotification(["deleteNotification": [params]]) { (response, error) in
            if let result = response {
                if let count = result["count"] as? Double { user.saveNotificationCount(count) }
                DatabasePlanItUserNotification().deleteNotifications(notifications.compactMap({Double($0.readNotificationId())}), type: type, activityType: activityType)
                completion(true, error)
            }
            else {
                completion(false, error)
            }
        }
    }
    
    func notificationPayload(_ notification: UserNotification, completion: @escaping ([String: Any]?, String?, String?) -> ()) {
        let notificationCommand = NotificationCommand()
        notificationCommand.payload(["notificationTo": Session.shared.readUserId(), "actvityType": notification.readActvityType(), "activityId": notification.readActvityId(), "notificationId": notification.readNotificationId()], callback: { response, statusCode, error in
            if let result = response {
                completion(result, statusCode, nil)
            }
            else {
                completion(nil, statusCode, error)
            }
        })
    }
    
    func notificationPayloadGetActivityData(_ activityType: Int, id activityId: Int, completion: @escaping ([String: Any]?, String?, String?) -> ()) {
        let notificationCommand = NotificationCommand()
        notificationCommand.getActivityData(["userId": Session.shared.readUserId(), "activityType": activityType, "activityId": activityId], callback: { response, statusCode, error in
            if let result = response {
                completion(result, statusCode, nil)
            }
            else {
                completion(nil, statusCode, error)
            }
        })
    }
}

class NotificationCommand: WSManager {
    
    func notifications(_ params: [String: Any]?, callback: @escaping (Dictionary<String, Any>?, String?) -> ()) {
        self.get(endPoint: ServiceData.notification, params: params, callback: { response, error in
            if let result = response {
                if let data = result.data as? [[String: Any]], let details = data.first {
                    callback(details, nil)
                }
                else {
                    callback(nil, result.error)
                }
            }
            else {
                callback(nil, error?.message ?? Message.unknownError)
            }
        })
    }
    
    func sendAction(_ params: [String: Any]?, callback: @escaping (Dictionary<String, Any>?, String?) -> ()) {
        self.post(endPoint: ServiceData.notificationAction, params: params, callback: { response, error in
            if let result = response {
                if let data = result.data as? [[String: Any]], let details = data.first {
                    callback(details, nil)
                }
                else {
                    callback(nil, result.error)
                }
            }
            else {
                callback(nil, error?.message ?? Message.unknownError)
            }
        })
    }
    
    func remoteNotification(_ params: [String: Any]?, callback: @escaping (Bool?, String?) -> ()) {
        self.post(endPoint: ServiceData.remoteNotification, params: params, callback: { response, error in
            if let result = response {
                callback(result.isSuccessful(), result.error)
            }
            else {
                callback(nil, error?.message ?? Message.unknownError)
            }
        })
    }
    
    func deleteNotification(_ params: [String: Any]?, callback: @escaping (Dictionary<String, Any>?, String?) -> ()) {
        self.delete(endPoint: ServiceData.notificationDelete, params: params, callback: { response, error in
            if let result = response {
                if let data = result.data as? [[String: Any]], let details = data.first {
                    callback(details, nil)
                }
                else {
                    callback(nil, result.error)
                }
            }
            else {
                callback(nil, error?.message ?? Message.unknownError)
            }
        })
    }
    
    func payload(_ params: [String: Any]?, callback: @escaping (Dictionary<String, Any>?, String?, String?) -> ()) {
        self.post(endPoint: ServiceData.notificationPayload, params: params, callback: { response, error in
            if let result = response {
                if let data = result.data as? [[String: Any]], let details = data.first {
                    callback(details, result.statusCode, nil)
                }
                else {
                    callback(nil, result.statusCode, result.error)
                }
            }
            else {
                callback(nil, nil, error?.message ?? Message.unknownError)
            }
        })
    }
    
    func getActivityData(_ params: [String: Any]?, callback: @escaping (Dictionary<String, Any>?, String?, String?) -> ()) {
        self.get(endPoint: ServiceData.activityData, params: params, callback: { response, error in
            if let result = response {
                if let data = result.data as? [[String: Any]], let details = data.first {
                    callback(details, result.statusCode, nil)
                }
                else {
                    callback(nil, result.statusCode, result.error)
                }
            }
            else {
                callback(nil, nil, error?.message ?? Message.unknownError)
            }
        })
    }
}
