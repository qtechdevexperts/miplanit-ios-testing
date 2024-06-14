//
//  AppDelegate.swift
//  MiPlanIt
//
//  Created by Arun on 13/03/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit
import Firebase
import GoogleMaps
//import GooglePlaces
import UserNotifications
import FirebaseMessaging
import PINRemoteImage
import IQKeyboardManagerSwift
import FirebaseCrashlytics
import CoreLocation
import BackgroundTasks
import GoogleMobileAds

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate {

    var window: UIWindow?
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        Session.shared.applicationDidFinishLaunchFromRemoteNotification(launchOptions)
        SocialManager.default.application(application, didFinishLaunchingWithOptions: launchOptions)
        // Override point for customization after application launch.
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.enableAutoToolbar = false
        UITextField.appearance().defaultPlaceholderColor = .white
        
        // Use Firebase library to configure APIs
        FirebaseApp.configure()
        FirebaseConfiguration.shared.setLoggerLevel(.min)
        GMSServices.provideAPIKey("AIzaSyBnFHw0maiGfi76KU5JhbfjeSeArGZiWzg")
        Messaging.messaging().delegate = Session.shared
        InAppPurchase.shared.addPaymentObserver()
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().delegate = Session.shared
        UNUserNotificationCenter.current().requestAuthorization(
          options: authOptions,
          completionHandler: { granted, _ in
            if granted {
                DispatchQueue.main.async {
                    application.registerForRemoteNotifications()
                }
            }
        })
        
        // MARK: Registering Launch Handlers for Tasks
        if #available(iOS 13.0, *) {
            BGTaskScheduler.shared.register(forTaskWithIdentifier: "com.miplanitapp.bgtask", using: nil) { task in
                // Downcast the parameter to an app refresh task as this identifier is used for a refresh request.
                self.handleAppRefresh(task: task as! BGAppRefreshTask)
            }
        } else {
            // Fallback on earlier versions
        }
        GADMobileAds.sharedInstance().start(completionHandler: nil)
        return true
    }
    
    @available(iOS 13.0, *)
    func scheduleAppRefresh() {
        let request = BGAppRefreshTaskRequest(identifier: "com.miplanitapp.bgtask")
        request.earliestBeginDate = Date(timeIntervalSinceNow: 3 * 60) // Fetch no earlier than 15 minutes from now
        
        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            print("Could not schedule app refresh: \(error)")
        }
    }
    
    @available(iOS 13.0, *)
    func handleAppRefresh(task: BGAppRefreshTask) {
        scheduleAppRefresh()
        
        task.expirationHandler = { debugPrint("Expired") }
        Session.shared.createServiceToFetchUsersEventData({ result in
            task.setTaskCompleted(success: result)
        })
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        if #available(iOS 13.0, *) {
            scheduleAppRefresh()
        }
        
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        Session.shared.checkAppVersionChange()
        if let user = Session.shared.readUser() {
            UserService().checkUserStorageExhausted()
            Session.shared.getAllContactUsers()
            Session.shared.saveAppFromForeGround(true)
            Session.shared.reRegisterUserLocationNotification()
            if SocialManager.default.isNetworkReachable() {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    Session.shared.refreshAppleCalendarsEvents()
                    SocialManager.default.readyToCallNextExpirySocialToken()
                }
            }
            if UIApplication.shared.applicationIconBadgeNumber > Int(user.readValueOfNotificationCount()) {
                user.saveNotificationCount(Double(UIApplication.shared.applicationIconBadgeNumber))
            }
        }
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        Session.shared.endBackgroundTask()
        guard let navigationController = self.window?.rootViewController as? UINavigationController else { return }
        navigationController.topViewController?.view.isUserInteractionEnabled = true
        Session.shared.updateEventIfAnyHiddenEvents()
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
        return SocialManager.default.application(app, open: url, options: options)
    }
    
    //MARK: - Remote notification
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        if let notificationDetails = userInfo["gcm.notification.notificationData"] as? String, let data =  notificationDetails.data(using: .utf8),  let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary, let notificationTo = jsonObject["notificationTo"] as? [String: Any], let reciever = notificationTo["userId"] as? Double, let user = Session.shared.readUser(), reciever.cleanValue() == user.readValueOfUserId() {
            if let count = jsonObject["count"] as? Double { user.saveNotificationCount(count) }
            if let jsonDict =   jsonObject as? [String : Any] { Session.shared.notificationRedirectToSpecificController(jsonDict) }
            Session.shared.updateRequestNotification(jsonObject)
        }
        else if let notificationDetails = userInfo["gcm.notification.notificationData"] as? String, let data =  notificationDetails.data(using: .utf8),  let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary, let notificationTo = jsonObject["notificationTo"] as? Double, let user = Session.shared.readUser(), notificationTo.cleanValue() == user.readValueOfUserId() {
            if let jsonDict =   jsonObject as? [String : Any] {
                Session.shared.manageUsersDataUpdatedPayload(jsonDict)
            }
        }
        completionHandler(UIBackgroundFetchResult.newData)
    }
}
