//
//  LoginViewController+Service.swift
//  MiPlanIt
//
//  Created by Arun on 26/03/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

extension LoginViewController {
    
    func createServiceToLoginUser(_ user: SocialUser) {
        UserService().login(user: user, callback: { planItUser, error in
            if let bPlanItUser = planItUser {
                self.buttonLogin.stopAnimation(animationStyle: .normal, revertAfterDelay: 0) {
                    Session.shared.saveUser(bPlanItUser)
                    if let user = Session.shared.readUser(), user.readUserSettings().isCustomDashboard {
                        self.navigationController?.storyboard(StoryBoards.customDashboard, setRootViewController: StoryBoardIdentifier.customDashboard)
                    }
                    else  {
                        self.navigationController?.storyboard(StoryBoards.dashboard, setRootViewController: StoryBoardIdentifier.dashboard)
                    }
                }
            }
            else {
                let message = error ?? Message.unknownError
                self.buttonLogin.stopAnimation(animationStyle: .shake, revertAfterDelay: 0) {
                    self.performSegue(withIdentifier: Segues.toMessageScreen, sender: [Message.error, message])
                }
            }
        })
    }
    
    func createServiceToRegisterUser(_ user: SocialUser) {
        self.buttonLogin.startAnimation()
        UserService().register(user: user, callback: { planItUser, newUser, error in
            if let bPlanItUser = planItUser {
                self.buttonLogin.stopAnimation(animationStyle: .normal, revertAfterDelay: 0) {
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
                self.buttonLogin.stopAnimation(animationStyle: .shake, revertAfterDelay: 0) {
                    self.performSegue(withIdentifier: Segues.toMessageScreen, sender: [Message.error, message])
                }
            }
        })
    }
}
