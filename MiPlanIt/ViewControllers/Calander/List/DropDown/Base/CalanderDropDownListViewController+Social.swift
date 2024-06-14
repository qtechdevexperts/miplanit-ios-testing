//
//  CalanderDropDownListViewController+Social.swift
//  MiPlanIt
//
//  Created by Arun on 24/06/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

extension CalanderDropDownBaseListViewController: SocialManagerDelegate {
    
    func socialManagerFailedToLogin(_ manager: SocialManager) {
        switch manager.type {
        case .google:
            self.showAlert(message: Message.socialLoginFailed, title: Message.warning)
        case .outlook:
            self.showAlert(message: Message.socialLoginFailed, title: Message.warning)
        default: break
        }
    }
    
    func socialManagerFailedToRestore(_ manager: SocialManager) {
        switch manager.type {
        case .outlook:
            SocialManager.default.loginOutlookFromViewController(self, client: ConfigureKeys.outlookClientId, scopes: ServiceData.outlookScopes, result: self)
        default: break
        }
    }
    
    func socialManager(_ manager: SocialManager, loginWithResult result: SocialUser) {
        switch manager.type {
        case .google:
            self.createServiceToFetchGoogleUsersCalendar(result)
        case .outlook:
            self.createServiceToFetchOutlookUsersCalendar(result)
        default: break
        }
    }
}
