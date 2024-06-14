//
//  AccountListViewController+Callback.swift
//  MiPlanIt
//
//  Created by Febin Paul on 20/01/21.
//  Copyright © 2021 Arun. All rights reserved.
//

import Foundation

extension AccountListViewController: OutlookWebViewControllerDelegate {
    
    func outlookWebViewController(_ outlookWebViewController: OutlookWebViewController, authenticationCode: String, redirectUri url: String) {
        SocialManager.default.getOutlookAssessRefreshTokens(authenticationCode, redirectUri: url, result: self)
    }
}
