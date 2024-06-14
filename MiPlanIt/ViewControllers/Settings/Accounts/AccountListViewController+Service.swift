//
//  AccountListViewController+Service.swift
//  MiPlanIt
//
//  Created by Arun on 11/09/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

extension AccountListViewController {
    
    func createWebserviceToFetchSocialUsers() {
         if SocialManager.default.isNetworkReachable() {
            self.serviceStarted = true
            CalendarService().socialCalendarUsers(callback: { result, error in
                self.serviceStarted = false
                if result {
                    self.readAllSocialUserAndReload()
                }
                else {
                    let message = error ?? Message.unknownError
                    self.performSegue(withIdentifier: Segues.toMessageScreen, sender: [Message.error, message])
                }
            })
        }
         else {
            self.readAllSocialUserAndReload()
        }
    }
    
    func createWebServiceToRefreshSocialToken(_ user: SocialUser) {
        guard  SocialManager.default.isNetworkReachable() else { return }
        self.serviceStarted = true
        CalendarService().syncUsers([user], callback: { result, _ in
            self.serviceStarted = false
            if result {
                SocialManager.default.refrshSocialAccountsFromServer()
                let type = user.userType == .eGoogleUser ? 1.0 : 2.0
                if let accountType = self.socialUsers.filter({ return $0.type == type }).first {
                    if let account = accountType.users.filter({ return $0.readSocialAccountId() == user.userId }).first {
                        account.saveUpdateSocialAccountInformation(user)
                        self.tableView.reloadData()
                    }
                }
            }
        })
    }
}
