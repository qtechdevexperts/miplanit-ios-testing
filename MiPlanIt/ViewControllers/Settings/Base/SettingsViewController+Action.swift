//
//  SettingsViewController+Action.swift
//  MiPlanIt
//
//  Created by Febin Paul on 31/03/21.
//  Copyright © 2021 Arun. All rights reserved.
//

import Foundation

extension SettingsViewController {
    
    func initializeUI() {
        guard let user = Session.shared.readUser() else { return }
        self.imageViewExpiryIcon.isHidden = !SocialManager.default.isSocialAccountsExpiredAfterRefresh()
        self.showExpiryTime(user.readLinkExpiryTime())
    }
    
    func showExpiryTime(_ time: Double) {
        let (d,h) = self.secondsToHoursMinutesSeconds(seconds: Int(time))
        var timeText = Strings.empty
        if d > 0 {
            timeText = "\(d) "+"\(d > 1 ? "Days" : "Day")"
        }
        if h > 0 {
            if timeText != Strings.empty {
                timeText += " ,"
            }
            timeText += "\(h) "+"\(h > 1 ? "Hours" : "Hour")"
        }
        self.labelEventLinkExpiry.text = "\(timeText)"
    }
    
    func secondsToHoursMinutesSeconds (seconds : Int) -> (Int, Int) {
      return (seconds / (24*3600), (seconds % (24*3600)) / 3600)
    }
    
    func fetchingExpiryDate(_ status: Bool) {
        self.isFetchingLinkExipryTime = status
        if status {
            self.buttonLinkExpirySpinner.startAnimation()
            self.labelEventLinkExpiry.isHidden = true
        }
        else {
            self.buttonLinkExpirySpinner.stopAnimation(animationStyle: .normal, revertAfterDelay: 0.0, completion: {
                self.labelEventLinkExpiry.isHidden = status
            })
        }
    }
}
