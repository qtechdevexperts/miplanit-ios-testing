//
//  AddShareLinkTimeViewController+Service.swift
//  MiPlanIt
//
//  Created by Febin Paul on 31/03/21.
//  Copyright © 2021 Arun. All rights reserved.
//

import Foundation

extension AddShareLinkTimeViewController {
    
    func createServiceAddShareLinkTime() {
        guard let user = Session.shared.readUser(), let expiryTime = self.textFieldExpiryTime.text, let expiryTimeValue = Double(expiryTime) else { return }
        let time = expiryTimeValue*60*60
        UserService().saveLinkExpiryTime(user, linkExpiryTime: time) { (expiryTimeValue, error) in
            if let value = expiryTimeValue {
                self.updateExpiryTime(time)
            }
            else {
                
            }
        }
    }
}
