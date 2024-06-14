//
//  AccountListViewController+Social.swift
//  MiPlanIt
//
//  Created by Arun on 11/09/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

extension AccountListViewController: SocialManagerDelegate {
    
    func loadAccountWithType(_ account: PlanItSocialUser) {
        switch account.socialAccType {
        case 1:
            SocialManager.default.loginGoogleFromViewController(self, client: ConfigureKeys.googleClientKey, scopes: ServiceData.googleScope, result: self)
        case 2:
            self.performSegue(withIdentifier: Segues.showOutlookWebViewController, sender: nil)
        default:
            break
        }
    }

    func socialManager(_ manager: SocialManager, loginWithResult result: SocialUser) {
        self.createWebServiceToRefreshSocialToken(result)
    }
    
    func socialManagerFailedToLogin(_ manager: SocialManager) {
        self.showAlert(message: Message.socialLoginFailed, title: Message.warning)
    }

    func socialManagerFailedToRestore(_ manager: SocialManager) {
    }
}
