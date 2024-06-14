//
//  RequestNotificationViewController+Offline.swift
//  MiPlanIt
//
//  Created by Febin Paul on 12/01/21.
//  Copyright © 2021 Arun. All rights reserved.
//

import Foundation

extension RequestNotificationViewController {
    
    func getUserNotificationFromNetwork() {
        if SocialManager.default.isNetworkReachable() {
            self.createWebServiceToFetchNotification()
        }
        else {
            self.getPlanItUserNotification()
        }
    }
}
