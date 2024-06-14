//
//  SettingsViewController+Callback.swift
//  MiPlanIt
//
//  Created by Febin Paul on 31/03/21.
//  Copyright © 2021 Arun. All rights reserved.
//

import Foundation

extension SettingsViewController: AddShareLinkTimeViewControllerDelgate {
    func addShareLinkTimeViewController(_ addShareLinkTimeViewController: AddShareLinkTimeViewController, updatedTime: Double) {
        self.showExpiryTime(updatedTime)
    }
}
