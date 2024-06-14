//
//  AppVersionSession.swift
//  MiPlanIt
//
//  Created by Febin Paul on 25/02/21.
//  Copyright © 2021 Arun. All rights reserved.
//

import Foundation


extension Session {
    
    func readDeviceAppVersion() -> String? {
        return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? Strings.empty
    }
    
    func checkAppVersionChange(finished: (()->())? = nil) {
        self.callWebServiceAppVersion { (status) in
            self.checkVersionWithUserDefault(finished)
        }
    }
    
    func checkVersionWithUserDefault(_ finished: (()->())? = nil) {
        if self.versionAlertShowing { finished?(); return }
        if let forceUpdateFlag = Storage().readBool(UserDefault.forceUpdate), let serverVersion = Storage().readString(UserDefault.appVersion), let version = self.readDeviceAppVersion(), let doubleLocalVersion = Double(version), let doubleServerVersion = Double(serverVersion), doubleLocalVersion < doubleServerVersion {
            self.showAppVersionAlert(forceUpdate: forceUpdateFlag, finished: finished)
        }
        else {
            finished?()
        }
    }
    
    
    func callWebServiceAppVersion(callback: @escaping (Bool) -> ()) {
        AppVersionService().getAppVersion { (result, error) in
            callback(true)
        }
    }
    
    func openAppStoreURL() {
        guard let bURL = URL(string: ServiceData.appstoreURL), UIApplication.shared.canOpenURL(bURL) else { return }
        UIApplication.shared.open(bURL, options: [:], completionHandler: nil)
    }
    
    func showAppVersionAlert(forceUpdate: Bool, finished: (()->())? = nil) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate, let rootViewController = appDelegate.window?.rootViewController as? UINavigationController, let topViewController = rootViewController.topViewController else { finished?(); return }
        self.versionAlertShowing = true
        let items = forceUpdate ? [Message.versionUpdate] : [Message.versionUpdate, Message.cancel]
        topViewController.showAlertWithAction(message: Storage().readString(UserDefault.appVersionMessage) ?? Message.newVersionAvailableMessage, title: Message.newVersionAvailable, items: items, callback: { (index) in
            if index == 0 {
                self.openAppStoreURL()
            }
            self.versionAlertShowing = false
            finished?()
        })
    }
}
