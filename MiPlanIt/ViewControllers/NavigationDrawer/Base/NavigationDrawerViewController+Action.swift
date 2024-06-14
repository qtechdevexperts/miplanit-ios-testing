//
//  NavigationDrawerViewController+Action.swift
//  MiPlanIt
//
//  Created by Arun on 25/03/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit

extension NavigationDrawerViewController {
    
    func initialiseMenuButtons() {
        self.viewNotification.isHidden = true
        self.labelUser.text = Session.shared.readUser()?.readValueOfName() ?? Strings.empty
        
//        self.buttonNavigationItemList.filter({ $0.tag == self.selectedOption.rawValue }).first?.setBackgroundColor(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.1), for: .normal)
//        self.buttonNavigationItemList.filter({ $0.tag == self.selectedOption.rawValue }).first?.backgroundColor = .grayLight
        
        self.viewNavigationItemList.filter({ $0.tag == self.selectedOption.rawValue }).first?.backgroundColor = .grayLightPlus
        
        
        
        self.labelNavigationItemList.filter({ $0.tag == self.selectedOption.rawValue }).first?.textColor = .black
        
        self.iconNavigationItemList.filter({ $0.tag == self.selectedOption.rawValue }).first?.tintColor = .black
        
        
        
        self.updateValueOfNotificationCount()
        self.downloadUserProfileImageFromServer()
        self.imageViewExpiryIcon?.isHidden = !SocialManager.default.isSocialAccountsExpiredAfterRefresh()
    }
    
    func addNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(updateValueOfNotificationCount), name: NSNotification.Name(rawValue: Notifications.userNotifications), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(refreshExpiryIcon), name: NSNotification.Name(rawValue: Notifications.detectedSocialAccountsRenewal), object: nil)
    }
    
    func removeNotifications() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: Notifications.userNotifications), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: Notifications.detectedSocialAccountsRenewal), object: nil)
    }
    
    @objc func updateValueOfNotificationCount() {
        guard let count = Session.shared.readUser()?.readValueOfNotificationCount(), count > 0 else { self.viewNotification.isHidden = true; return }
        self.viewNotification.isHidden = false
        self.labelNotificationCount.text = count > 99 ? "99+" : count.cleanValue()
    }
    
    @objc func refreshExpiryIcon() {
        self.imageViewExpiryIcon?.isHidden = !SocialManager.default.isSocialAccountsExpiredAfterRefresh()
    }
    
    func refreshUI() {
        self.labelUser.text = Session.shared.readUser()?.readValueOfName() ?? Strings.empty
        self.downloadUserProfileImageFromServer()
    }
    
    func readMenuView() -> MenuView? {
        return self.view.superview as? MenuView
    }
    
    func forceSignOutUserFromAWSServer() {
        if let user = Session.shared.readUser(), user.readValueOfLoginType() == "0" {//AWS User
            AWSRequest().signOutAWS(callback: { _, _ in
                Session.shared.deregisterUserLocalNotification {
                    DispatchQueue.main.async {
                        NotificationService().deregisterNotificationForUser()
                        Session.shared.clearUser()
                        self.navigationController?.storyboard(StoryBoards.main, setRootViewController: StoryBoardIdentifier.splash)
                    }
                }
            })
        }
        else {
            Session.shared.deregisterUserLocalNotification {
                DispatchQueue.main.async {
                    NotificationService().deregisterNotificationForUser()
                    Session.shared.clearUser()
                    self.navigationController?.storyboard(StoryBoards.main, setRootViewController: StoryBoardIdentifier.splash)
                }
            }
        }
    }
    
    func downloadUserProfileImageFromServer() {
        guard let user = Session.shared.readUser() else { return }
        if let imageData = user.readProfileImageData(), !imageData.isEmpty {
            self.imageViewProfilePic.image = UIImage(data: imageData)
        }
        else {
            self.imageViewProfilePic.pinImageFromURL(URL(string: user.readValueOfProfile()), placeholderImage: user.readValueOfName().shortStringImage())
        }
    }
}
    

