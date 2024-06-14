//
//  AccountRegistrationViewController+Service.swift
//  MiPlanIt
//
//  Created by Arun on 26/03/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

extension AccountRegistrationViewController {
    
    func callWebServiceForUserAlreadyExist()  {
        self.buttonSignUp.startAnimation()
        UserService().checkUserAlreadyExist(self.readUserAccountName(), callback: { status, error in
            if let result = status, result {
                self.sendNewUserRegistrationToAWSServer()
            }
            else {
                let message = error ?? Message.unknownError
                self.buttonSignUp.stopAnimation(animationStyle: .shake, revertAfterDelay: 0) {
                    self.performSegue(withIdentifier: Segues.toMessageScreen, sender: [Message.error, message])
                }
            }
        })
    }
    
    func createServiceToRegisterUser(_ user: SocialUser, alreadyAnimating: Bool = false) {
        if !alreadyAnimating {
            self.buttonSignUp.startAnimation()
        }
        UserService().register(user: user, callback: { planItUser, newUser, error in
            if let bPlanItUser = planItUser {
                self.buttonSignUp.stopAnimation(animationStyle: .normal, revertAfterDelay: 0) {
                    Session.shared.saveUser(bPlanItUser)
                    if newUser {
                        self.performSegue(withIdentifier: Segues.toUpdateProfile, sender: self)
                    }
                    else {
                        if let user = Session.shared.readUser(), user.readUserSettings().isCustomDashboard {
                            self.navigationController?.storyboard(StoryBoards.customDashboard, setRootViewController: StoryBoardIdentifier.customDashboard)
                        }
                        else  {
                            self.navigationController?.storyboard(StoryBoards.dashboard, setRootViewController: StoryBoardIdentifier.dashboard)
                        }
                    }
                }
            }
            else {
                let message = error ?? Message.unknownError
                self.buttonSignUp.stopAnimation(animationStyle: .shake, revertAfterDelay: 0) {
                    self.performSegue(withIdentifier: Segues.toMessageScreen, sender: [Message.error, message])
                }
            }
        })
    }
}
