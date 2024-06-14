//
//  AddInviteesViewController+Service.swift
//  MiPlanIt
//
//  Created by Febin Paul on 15/04/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

extension AddInviteesViewController {
    
    func createWebServiceForFetchUserEvents(_ users: [CalendarUser]) {
        self.startLottieAnimations()
        CalendarService().fetchOtherUserEvents(users, callback: { response, error in
            self.stopLottieAnimations()
            if let result = response {
                self.delegate?.addInviteesViewController(self, selected: result)
                self.navigationController?.popViewController(animated: true)
            }
            else {
                let message = error ?? Message.unknownError
                self.performSegue(withIdentifier: Segues.toMessageScreen, sender: [Message.error, message])
            }
        })
    }
}


