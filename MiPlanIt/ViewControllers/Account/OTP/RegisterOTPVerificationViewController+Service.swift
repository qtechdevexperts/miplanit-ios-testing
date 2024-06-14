//
//  RegisterOTPVerificationViewController+Service.swift
//  MiPlanIt
//
//  Created by Arun on 26/03/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

extension RegisterOTPVerificationViewController {
    
    func createServiceToRegisterUser(_ user: SocialUser) {
        UserService().register(user: user, callback: { planItUser, newUser, error in
            if let bPlanItUser = planItUser {
                self.buttonSendOTP.clearButtonTitleForAnimation()
                self.buttonSendOTP.stopAnimation(animationStyle: .normal, revertAfterDelay: 0) {
                    self.buttonSendOTP.showTickAnimation { (result) in
                        Session.shared.saveUser(bPlanItUser)
                        self.performSegue(withIdentifier: Segues.toUpdateProfile, sender: self)
                    }
                }
            }
            else {
                let message = error ?? Message.unknownError
                self.buttonSendOTP.stopAnimation(animationStyle: .shake, revertAfterDelay: 0) {
                    self.performSegue(withIdentifier: Segues.toMessageScreen, sender: [Message.error, message])
                }
            }
        })
    }
}
