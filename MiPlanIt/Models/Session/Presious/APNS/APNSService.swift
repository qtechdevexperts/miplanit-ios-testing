//
//  APNSService.swift
//  MiPlanIt
//
//  Created by Arun on 06/08/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation
import Firebase
import UserNotifications

extension Session {
    
    func resetPayload() {
        self.pushNotificationPayload = nil
    }
    
    func notificationRedirectToSpecificController(_ data: [String : Any], onTap tapFlag: Bool = false) {
//        let window = UIApplication.shared.keyWindow!
//        let v = UIView(frame: window.bounds)
//        window.addSubview(v)
//        v.backgroundColor = UIColor.lightGray//1
        self.resetPayload()
        
        let notification = UserNotification(with: data)
        if #available(iOS 13.0, *) {
            if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate, let rootViewController = sceneDelegate.window!.rootViewController  as? UINavigationController, let currentController = rootViewController.topViewController {
          
                switch notification.readActvityType() {
                case 1:
                    self.manageCalendarNotification(notification, from: currentController)
                case 2, 9:
                    self.manageEventNotification(notification, from: currentController)
                case 3, 5:
                    self.manageTodoNotification(notification, from: currentController, onTap: tapFlag)
                case 4, 7:
                    self.manageShoppingoNotification(notification, from: currentController, onTap: tapFlag)
                default:
                    break
                }
            }
        } else {
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate, let rootViewController = appDelegate.window?.rootViewController as? UINavigationController, let currentController = rootViewController.topViewController else { return }
            let vc = TestVC()
            vc.value = "app delegate 123"
            currentController.present(vc, animated: true)
            switch notification.readActvityType() {
            case 1:
                self.manageCalendarNotification(notification, from: currentController)
            case 2, 9:
                self.manageEventNotification(notification, from: currentController)
            case 3, 5:
                self.manageTodoNotification(notification, from: currentController, onTap: tapFlag)
            case 4, 7:
                self.manageShoppingoNotification(notification, from: currentController, onTap: tapFlag)
            default:
                break
            }
        }
    }
    func manageUserActionNotification(_ notification: UserNotification, from controller: UIViewController) {
//        let window = UIApplication.shared.keyWindow!
//        let v = UIView(frame: window.bounds)
//        window.addSubview(v)
//        v.backgroundColor = UIColor.magenta//1
        controller.navigationController?.storyboard(StoryBoards.requestNotification, setRootViewController: StoryBoardIdentifier.requestNotification, animated: false, force: true)
    }
    
    func localNotificationRedirectToSpecificController(_ userInfo: [String : AnyObject]) {
//        let window = UIApplication.shared.keyWindow!
//        let v = UIView(frame: window.bounds)
//        window.addSubview(v)
//        v.backgroundColor = UIColor.red//1
        self.resetPayload()
        if let type = userInfo["type"] as? String {
            switch type {
            case "Event":
                self.manageEventLocalNotification(userInfo)
            case "Todo":
                self.manageTodoLocalNotification(userInfo)
            case "ShopingListItem":
                self.manageShopingLocalNotification(userInfo)
            default: break
            }
        }
    }
    
    func updateRequestNotification(_ notificationData: Any) {
//        let window = UIApplication.shared.keyWindow!
//        let v = UIView(frame: window.bounds)
//        window.addSubview(v)
//        v.backgroundColor = UIColor.orange//1
//        guard UIApplication.shared.applicationState == .active else { return }
        DispatchQueue.main.asyncAfter(deadline: .now()+1.0) {
            if let jsonDict = notificationData as? [String : Any] {
//                guard let appDelegate = UIApplication.shared.delegate as? AppDelegate, let rootViewController = appDelegate.window?.rootViewController as? UINavigationController, let currentController = rootViewController.topViewController else { return }
//                let notification = UserNotification(with: jsonDict)
//                if !notification.readIsAutoSync(), let navController = currentController.navigationController, let baseViewController = navController.viewControllers.first, let requestNotificationViewController = baseViewController as? RequestNotificationViewController, SocialManager.default.isNetworkReachable() {
//                    requestNotificationViewController.refreshData()
//                }
                if #available(iOS 13.0, *) {
                    if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate, let rootViewController = sceneDelegate.window!.rootViewController  as? UINavigationController, let currentController = rootViewController.topViewController {
                        
                        let notification = UserNotification(with: jsonDict)
                        if !notification.readIsAutoSync(), let navController = currentController.navigationController, let baseViewController = navController.viewControllers.first, let requestNotificationViewController = baseViewController as? RequestNotificationViewController, SocialManager.default.isNetworkReachable() {
//                            let vc = TestVC()
//                            vc.value = "notificationDetail Scene not to"
//                            currentController.present(vc, animated: true)
                            requestNotificationViewController.refreshData()

                        }
                    }
                } else {
                    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate, let rootViewController = appDelegate.window?.rootViewController as? UINavigationController, let currentController = rootViewController.topViewController else { return }
                    let notification = UserNotification(with: jsonDict)
                    if !notification.readIsAutoSync(), let navController = currentController.navigationController, let baseViewController = navController.viewControllers.first, let requestNotificationViewController = baseViewController as? RequestNotificationViewController, SocialManager.default.isNetworkReachable() {
//                        let vc = TestVC()
//                        vc.value = "app delegateto"
//                        currentController.present(vc, animated: true)
                        requestNotificationViewController.refreshData()
                    }
                    
                }
            }
        }
        
        


    }
    
    func updateLoaderInRequestNotification(show flag: Bool, on notification: UserNotification, from controller: UIViewController) {
//        let window = UIApplication.shared.keyWindow!
//        let v = UIView(frame: window.bounds)
//        window.addSubview(v)
//        v.backgroundColor = UIColor.lightGray//1
        if let requestController = controller as? RequestNotificationViewController {
            flag ? requestController.startLoadingIndicatorForNotification([notification]) : requestController.stopLoadingIndicatorForNotification([notification])
        }
    }
}

extension Session {
    
    func applicationDidFinishLaunchFromRemoteNotification(_ launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
//        let window = UIApplication.shared.keyWindow!
//        let v = UIView(frame: window.bounds)
//        window.addSubview(v)
//        v.backgroundColor = UIColor.darkGray//1
        guard let options = launchOptions, let userInfo = options[UIApplication.LaunchOptionsKey.remoteNotification] as? [AnyHashable: Any] else { return }
        if let notificationDetails = userInfo["gcm.notification.notificationData"] as? String, let data =  notificationDetails.data(using: .utf8),  let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary {
            self.pushNotificationPayload = jsonObject
        }
    }
}

extension Session: MessagingDelegate {
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        if let token = fcmToken {
            Storage().saveString(object: token, forkey: UserDefault.deviceToken)
            let dataDict:[String: String] = ["token": token]
            print("FCM TOKEN: ",token)
            NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)
        }
        
    }
}

extension Session {
    
    func createWebServiceToFetchPayloadOfNotification(_ notification: UserNotification, result: @escaping ([String: Any]?, String?, String?) -> ()) {
//        let window = UIApplication.shared.keyWindow!
//        let v = UIView(frame: window.bounds)
//        window.addSubview(v)
//        v.backgroundColor = UIColor.purple//1
        NotificationService().notificationPayload(notification, completion: result)
    }
    
    func createWebServiceToFetchActivityDataPayloadOfNotification(_ activityType: Int, activityId: Int, result: @escaping ([String: Any]?, String?, String?) -> ()) {
//        let window = UIApplication.shared.keyWindow!
//        let v = UIView(frame: window.bounds)
//        window.addSubview(v)
//        v.backgroundColor = UIColor.yellow//1
        NotificationService().notificationPayloadGetActivityData(activityType, id: activityId, completion: result)
    }
}

extension Session: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
//        let window = UIApplication.shared.keyWindow!
//        let v = UIView(frame: window.bounds)
//        window.addSubview(v)
//        v.backgroundColor = UIColor.white//1
        

        
        
        completionHandler([.badge, .alert, .sound])
        guard notification.request.trigger is UNPushNotificationTrigger else { return }
        if let userInfo = notification.request.content.userInfo as? [String : AnyObject] {
            if let notificationDetails = userInfo["gcm.notification.notificationData"] as? String, let data =  notificationDetails.data(using: .utf8),  let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary, let notificationTo = jsonObject["notificationTo"] as? [String: Any], let reciever = notificationTo["userId"] as? Double, let user = Session.shared.readUser(), reciever.cleanValue() == user.readValueOfUserId() {
                if let count = jsonObject["count"] as? Double { user.saveNotificationCount(count) }
                self.updateRequestNotification(jsonObject)
                
                
                
//                let window = UIApplication.shared.keyWindow!
//                let v = UIView(frame: window.bounds)
//                window.addSubview(v)
//                v.backgroundColor = UIColor.blue//1
//
//                if #available(iOS 13.0, *) {
//                    if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate, let rootViewController = sceneDelegate.window!.rootViewController  as? UINavigationController, let currentController = rootViewController.topViewController {
//                        let vc = TestVC()
//                        vc.value = "data = \(String(describing: notificationDetails.data(using: .utf8)))\n"
//                        currentController.present(vc, animated: true)
//                    }
//                } else {
//                    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate, let rootViewController = appDelegate.window?.rootViewController as? UINavigationController, let currentController = rootViewController.topViewController else { return }
//                    let vc = TestVC()
//                    let detail = userInfo["gcm.notification.notificationData"] as? String ?? ""
//                    var c = detail.data(using: .utf8)
//                    let json = try? JSONSerialization.jsonObject(with: c!, options: []) as? NSDictionary
//                    vc.value = "json = \(json)\n"
//                    currentController.present(vc, animated: true)
//
//                }
                
                
            }
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {

        completionHandler()
        
        
        
        DispatchQueue.main.asyncAfter(deadline: .now()+3, execute: {
            
            guard response.notification.request.trigger is UNPushNotificationTrigger else {
                if let userInfo = response.notification.request.content.userInfo as? [String : AnyObject] {
                    guard !Session.shared.readUserId().isEmpty else {
                        Session.shared.pushNotificationPayload = userInfo as AnyObject
                        return
                    }
                    self.localNotificationRedirectToSpecificController(userInfo)
                }
                return }
            if let userInfo = response.notification.request.content.userInfo as? [String : AnyObject] {
                if let notificationDetails = userInfo["gcm.notification.notificationData"] as? String, let data =  notificationDetails.data(using: .utf8),  let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary, let notificationTo = jsonObject["notificationTo"] as? [String: Any], let reciever = notificationTo["userId"] as? Double, let user = Session.shared.readUser(), reciever.cleanValue() == user.readValueOfUserId() {
                    if let count = jsonObject["count"] as? Double { user.saveNotificationCount(count) }
                    if let jsonDict =   jsonObject as? [String : Any] { Session.shared.notificationRedirectToSpecificController(jsonDict, onTap: true) }
                    self.updateRequestNotification(jsonObject)
                }
                else if let notificationDetails = userInfo["gcm.notification.notificationData"] as? String, let data =  notificationDetails.data(using: .utf8),  let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary, let notificationTo = jsonObject["notificationTo"] as? Double, let user = Session.shared.readUser(), notificationTo.cleanValue() == user.readValueOfUserId() {
                    if let jsonDict =   jsonObject as? [String : Any] {
                        self.manageUsersDataUpdatedPayload(jsonDict)
                    }
                }
            }
            
//    //        let window = UIApplication.shared.keyWindow!
//    //        let v = UIView(frame: window.bounds)
//    //        window.addSubview(v)
//    //        v.backgroundColor = UIColor.blue//1
//            guard response.notification.request.trigger is UNPushNotificationTrigger else {
//                if let userInfo = response.notification.request.content.userInfo as? [String : AnyObject] {
//                    guard !Session.shared.readUserId().isEmpty else {
//                        Session.shared.pushNotificationPayload = userInfo as AnyObject
//                        return
//                    }
//                    self.localNotificationRedirectToSpecificController(userInfo)
//                }
//                return }
//            if let userInfo = response.notification.request.content.userInfo as? [String : AnyObject] {
//    //            let window = UIApplication.shared.keyWindow!
//    //            let v = UIView(frame: window.bounds)
//    //            let label = UILabel()
//    //            label.text = "123"
//    //            v.addSubview(label)
//    //            window.addSubview(v)
//    //            v.backgroundColor = UIColor.red//1
//                if let notificationDetails = userInfo["gcm.notification.notificationData"] as? String, let data =  notificationDetails.data(using: .utf8),  let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary, let notificationTo = jsonObject["notificationTo"] as? [String: Any], let reciever = notificationTo["userId"] as? Double, let user = Session.shared.readUser(), reciever.cleanValue() == user.readValueOfUserId() {
//    //                let window = UIApplication.shared.keyWindow!
//    //                let v = UIView(frame: window.bounds)
//    //                window.addSubview(v)
//    //                v.backgroundColor = UIColor.magenta//1
//                    if let count = jsonObject["count"] as? Double { user.saveNotificationCount(count) }
//                    if let jsonDict =   jsonObject as? [String : Any] { Session.shared.notificationRedirectToSpecificController(jsonDict, onTap: true) }
//                    self.updateRequestNotification(jsonObject)
//
//
//
//                    if #available(iOS 13.0, *) {
//                        if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate, let rootViewController = sceneDelegate.window!.rootViewController  as? UINavigationController, let currentController = rootViewController.topViewController {
//                            let vc = TestVC()
//                            let detail = userInfo["gcm.notification.notificationData"] as? String ?? ""
//                            var c = detail.data(using: .utf8)
//                            let json = try? JSONSerialization.jsonObject(with: c!, options: []) as? NSDictionary
//                            let notTo = json!["notificationTo"] as? [String: Any]
//                            vc.value = "notificationDetail Scene not to = \(notTo))\n"
//                            currentController.present(vc, animated: true)
//                        }
//                    } else {
//                        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate, let rootViewController = appDelegate.window?.rootViewController as? UINavigationController, let currentController = rootViewController.topViewController else { return }
//                        let vc = TestVC()
//                        let detail = userInfo["gcm.notification.notificationData"] as? String ?? ""
//                        var c = detail.data(using: .utf8)
//                        let json = try? JSONSerialization.jsonObject(with: c!, options: []) as? NSDictionary
//                        let notTo = json!["notificationTo"] as? [String: Any]
//
//                        vc.value =  "notificationDetail App delegate json = \(notTo))\n"
//                        currentController.present(vc, animated: true)
//
//                    }
//
//                }
//                else if let notificationDetails = userInfo["gcm.notification.notificationData"] as? String, let data =  notificationDetails.data(using: .utf8),  let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary, let notificationTo = jsonObject["notificationTo"] as? Double, let user = Session.shared.readUser(), notificationTo.cleanValue() == user.readValueOfUserId() {
//                    let window = UIApplication.shared.keyWindow!
//                    let v = UIView(frame: window.bounds)
//                    window.addSubview(v)
//                    v.backgroundColor = UIColor.purple//1
//                    if let jsonDict =   jsonObject as? [String : Any] {
//                        self.manageUsersDataUpdatedPayload(jsonDict)
//                    }
//
//                }else{
//
//
//                    if #available(iOS 13.0, *) {
//                        if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate, let rootViewController = sceneDelegate.window!.rootViewController  as? UINavigationController, let currentController = rootViewController.topViewController {
//                            let vc = TestVC()
//                            let detail = userInfo["gcm.notification.notificationData"] as? String ?? ""
//                            var c = detail.data(using: .utf8)
//                            let json = try? JSONSerialization.jsonObject(with: c!, options: []) as? NSDictionary
//                            let notTo = json!["notificationTo"] as? [String: Any]
//                            let reciever = notTo!["userId"] as? Double
//                            var message = ""
//                            if let user = Session.shared.readUser(){
//                                message += "\nUser is available"
//                                if reciever!.cleanValue() == user.readValueOfUserId(){
//                                    message += "\n Recever is equal to userId"
//
//                                }else{
//                                    message += "\n Recever not equal to userId \(String(describing: reciever?.cleanValue())) \(user.readValueOfUserId())"
//                                }
//                            }else{
//                                let user = Session.shared.readUser()
//                                message += "\nUser not available"
//                                if reciever!.cleanValue() == "436"{
//    //                                if let count = json!["count"] as? Double { user!.saveNotificationCount(count) }
//    //                             vc.value =  "else App scene json = \(String(describing: notTo)))\n"
//    //                             if let jsonDict =   json as? [String : Any] { Session.shared.notificationRedirectToSpecificController(jsonDict, onTap: true) }
//                                    Session.shared.notificationRedirectToSpecificController(json as! [String : Any], onTap: true)
//                                  self.updateRequestNotification(json)
//                                    message += "\n Recever is equal to userId"
//                                }else{
//                                    message += "\n Recever not equal to userId \(String(describing: reciever?.cleanValue())) \(String(describing: user?.readValueOfUserId()))"
//                                }
//                            }
//
//
//    //                         {
//    //                            if let count = json!["count"] as? Double { user.saveNotificationCount(count) }
//    //                            vc.value =  "else App scene json = \(String(describing: notTo)))\n"
//    //                            if let jsonDict =   json as? [String : Any] { Session.shared.notificationRedirectToSpecificController(jsonDict, onTap: true) }
//    //                            self.updateRequestNotification(json)
//    //
//    //                        }
//
//    //                        vc.value =  message + "\nelse App scene json = \(String(describing: notTo)))\n"
//    //                        currentController.present(vc, animated: true)
//                        }
//                    } else {
//                        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate, let rootViewController = appDelegate.window?.rootViewController as? UINavigationController, let currentController = rootViewController.topViewController else { return }
//                        let vc = TestVC()
//                        let detail = userInfo["gcm.notification.notificationData"] as? String ?? ""
//                        var c = detail.data(using: .utf8)
//                        let json = try? JSONSerialization.jsonObject(with: c!, options: []) as? NSDictionary
//                        let notTo = json!["notificationTo"] as? [String: Any]
//
//                        vc.value =  "else notificationDetail App delegate json = \(String(describing: notTo)))\n"
//                        currentController.present(vc, animated: true)
//
//                    }
//
//
//
//
//
//    //                let v = UIView(frame: window.bounds)
//    //                let label = UILabel()
//    //                label.lineBreakMode = .byWordWrapping
//    //                label.text = "userInfo = \(userInfo["gcm.notification.notificationData"] as? String ?? "")\n"
//    //                label.sizeToFit()
//    //                label.tintColor = .red
//    //                label.frame = v.frame
//    //                v.addSubview(label)
//    //                window.addSubview(v)
//    //                v.backgroundColor = UIColor.yellow//1
//                }
//            }
            
        })
        
        
    }
}
