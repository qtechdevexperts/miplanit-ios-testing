//
//  CreateEventsViewController+Invitees.swift
//  MiPlanIt
//
//  Created by Febin Paul on 15/04/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

extension CreateEventsViewController: AddInviteesViewControllerDelegate {
    
    func addInviteesViewController(_ viewController: AddInviteesViewController, selected users: [OtherUser]) {
        self.eventModel.invitees = users
        self.updateInviteesUI()
    }
}
