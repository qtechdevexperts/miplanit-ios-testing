//
//  AddShareLinkTimeViewController+Action.swift
//  MiPlanIt
//
//  Created by Febin Paul on 31/03/21.
//  Copyright © 2021 Arun. All rights reserved.
//

import Foundation


extension AddShareLinkTimeViewController {
    
    func initializeUI() {
        guard let user = Session.shared.readUser(), user.readLinkExpiryTime() != 0 else { return }
        self.textFieldExpiryTime.text = "\(Int((user.readLinkExpiryTime()) / (60 * 60)))"
    }
    
    func updateExpiryTime(_ time: Double) {
        self.dismiss(animated: false) {
            self.delegate?.addShareLinkTimeViewController(self, updatedTime: time)
        }
    }
}
