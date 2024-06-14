//
//  SplashViewController+Action.swift
//  MiPlanIt
//
//  Created by MS Nischal on 16/03/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit
import Speech

extension SplashViewController {
    
    func initializeUIComponents() {
//        if DatabasePlanItUser().readLoggedInUser() == nil {
//            self.labelsToAnimate.forEach({ return $0.alpha = 0 })
//        }
    }
    
    func moveLogoAnimation() {
        if let user = DatabasePlanItUser().readLoggedInUser() {
            self.showAllItemsWithoutAnimation(user)
        }
//        else {
//            var logoFrame = self.imageViewLogo.frame
//            framePosition = Double(logoFrame.origin.y)
//            logoFrame.origin.y = -logoFrame.size.height/8
//            self.imageViewLogo.frame = logoFrame
//            logoFrame.origin.y = CGFloat(framePosition)
//            self.imageViewLogo.alpha = 0.0
//            self.imageViewLogo.isHidden = false
//            UIView.animate(withDuration: 0.5, delay: 0.2, options: .curveLinear, animations: {
//                self.imageViewLogo.frame = logoFrame
//                self.imageViewLogo.alpha = 1.0
//            }, completion: { _ in
//                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    self.showSplashAnimation()
//                }
//            })
//        }
    }
    
    func showAllItemsWithoutAnimation(_ user: PlanItUser) {
//        self.imageViewLogo.isHidden = false
        DispatchQueue.main.asyncAfter(deadline: .now()+2) {
            self.requestSpeechAuthorization()
            self.registerLocalNotificationWithLoggedInUser(user)
        }
        
    }
    func showSplashAnimation() {
        self.animateLabelFading()
    }
    
    func isAnimationFinished() -> Bool {
        return self.buttonType.filter({ return $0.alpha == 0.0 }).isEmpty
    }
    
    func animateLabelFading() {
//        UIView.animate(withDuration: 2.0, delay: 0, options: .curveLinear, animations: {
//            self.labelsToAnimate.forEach({ return $0.alpha = 1 })
//        }, completion: { _ in
            self.manageLoginOptionsAnimation()
//        })
    }
    
    func manageLoginOptionsAnimation() {
        self.buttonType.forEach({ return $0.transform = CGAffineTransform.identity.scaledBy(x: 0.91, y: 0.91) })
        self.animateButtons(index: 1)
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            self.animateButtons(index: 0)
        }
    }
    
    func animateButtons(index : Int) {
        UIView.animate(withDuration: 1.0, delay: 0, usingSpringWithDamping: 0.28, initialSpringVelocity: 0.46, options: .curveLinear, animations: {
            self.buttonType[index].alpha = 1
            self.buttonType[index].transform = CGAffineTransform.identity
        }, completion: { _ in
            self.requestSpeechAuthorization()
            self.registerLocalNotificationWithLoggedInUser()
        })
    }
    
    func showLoginButtonAsDefault() {
        self.buttonType.forEach { (button) in
            button.alpha = 1
            button.transform = CGAffineTransform.identity
        }
//        self.imageViewLogo.alpha = 1.0
//        self.imageViewLogo.isHidden = false
//        self.labelsToAnimate.forEach({ return $0.alpha = 1 })
        Session.shared.saveAnimationShowStatus(true)
    }

    func registerLocalNotificationWithLoggedInUser(_ user: PlanItUser? = nil) {
        Session.shared.registerLocalNotificationWithStatus(completionHandler: { authorizationStatus in
            if authorizationStatus == .denied {
                self.showAlertWithAction(message: Message.notificationPermission, title: Message.permissionError, items: [Message.cancel, Message.settings], callback: { index in
                    if index == 0 {
                        self.saveUserLoginSeesion(user)
                    }
                    else {
                        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(settingsUrl) else { return }
                        UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                            self.saveUserLoginSeesion(user)
                        })
                    }
                })
            }
            else {
                self.saveUserLoginSeesion(user)
            }
        })
    }
    
    func saveUserLoginSeesion(_ user: PlanItUser? = nil) {
        guard let planitUser = user else { return }
        Session.shared.saveUser(planitUser)
        if let user = Session.shared.readUser(), user.readUserSettings().isCustomDashboard {
            self.navigationController?.storyboard(StoryBoards.customDashboard, setRootViewController: StoryBoardIdentifier.customDashboard)
        }
        else  {
            self.navigationController?.storyboard(StoryBoards.dashboard, setRootViewController: StoryBoardIdentifier.dashboard)
        }
    }
}
