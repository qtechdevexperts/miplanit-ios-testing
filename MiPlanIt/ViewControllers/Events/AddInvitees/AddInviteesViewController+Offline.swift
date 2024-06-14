//
//  AddInviteesViewController+Offline.swift
//  MiPlanIt
//
//  Created by Arun Aniyappan on 02/12/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

extension AddInviteesViewController {
    
    func readInviteesStatusUsingNetwotk(_ users: [CalendarUser]) {
        if SocialManager.default.isNetworkReachable() {
            self.createWebServiceForFetchUserEvents(users)
        }
        else {
            var index = -1
            let storedColorCodes: [String] = Storage().getColorCodes().compactMap({ $0.readColorCodeKey() })
            let otherUsers: [OtherUser] = users.map({ index += 1; return OtherUser(calendarUser: $0, colors: storedColorCodes, index: index) })
            self.delegate?.addInviteesViewController(self, selected: otherUsers)
            self.navigationController?.popViewController(animated: true)
        }
    }
}
