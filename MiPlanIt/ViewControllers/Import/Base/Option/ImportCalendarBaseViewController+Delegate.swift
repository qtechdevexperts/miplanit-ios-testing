//
//  ImportCalendarBaseViewController+Delegate.swift
//  MiPlanIt
//
//  Created by Febin Paul on 30/09/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation


extension ImportCalendarBaseViewController: CalendarListBaseViewControllerDelegate {
    
    func calendarListBaseViewController(_ calendarListBaseViewController: CalendarListBaseViewController, allAddedColorCodes: [ColorCode]) {
        self.addedColorCodes = allAddedColorCodes
    }
}


extension ImportCalendarBaseViewController: OutlookWebViewControllerDelegate {
    
    func outlookWebViewController(_ outlookWebViewController: OutlookWebViewController, authenticationCode: String, redirectUri url: String) {
        DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
            guard SocialManager.default.isNetworkReachable() else { return }
            self.performSegue(withIdentifier: Segues.toCalanderList, sender: (MiPlanItEnumCalendarType.outlook, authenticationCode, url))
        }
    }
}
