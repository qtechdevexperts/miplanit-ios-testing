//
//  AccountListViewController+Actions.swift
//  MiPlanIt
//
//  Created by Aneesh Asokan on 10/09/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

extension AccountListViewController {
    
    func readAllSocialUserAndReload() {
        let allSocialUsers = DatabasePlanItSocialUser().readAllUsersSocialAccounts()
        let groupedUsers = Dictionary(grouping: allSocialUsers, by: { $0.socialAccType })
        self.socialUsers = groupedUsers.map({ type, users in return SocialUserType(with: type, users: users) })
        self.tableView.reloadData()
    }
    
    func addNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(refreshSocialAccount), name: NSNotification.Name(rawValue: Notifications.detectedSocialAccountsRenewal), object: nil)
    }
    
    func removeNotifications() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: Notifications.detectedSocialAccountsRenewal), object: nil)
    }
    
    @objc func refreshSocialAccount() {
        self.tableView.reloadData()
    }
    
    func startLottieAnimations() {
        self.viewFetchingData.isHidden = false
        self.lottieAnimationView.play(fromProgress: 0, toProgress: 0.1, loopMode: .loop, completion: nil)
    }
    
    func stopLottieAnimations() {
        self.viewFetchingData.isHidden = true
        if self.lottieAnimationView.isAnimationPlaying { self.lottieAnimationView.stop() }
    }
}
