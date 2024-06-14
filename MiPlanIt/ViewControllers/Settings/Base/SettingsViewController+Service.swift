//
//  SettingsViewController+Service.swift
//  MiPlanIt
//
//  Created by Febin Paul on 30/03/21.
//  Copyright © 2021 Arun. All rights reserved.
//

import Foundation


extension SettingsViewController {
    
    func createServiceForLinkExpiryTime() {
        guard let user = Session.shared.readUser() else { return }
        self.fetchingExpiryDate(true)
        UserService().getLinkExpiryTime(user) { [weak self] (time, error) in
            guard let self = self else { return }
            self.fetchingExpiryDate(false)
            if let expiryTime = time {
                self.showExpiryTime(expiryTime)
            }
        }
    }
}
