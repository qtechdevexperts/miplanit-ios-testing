//
//  ShareShoppingViewController+Actions.swift
//  MiPlanIt
//
//  Created by Aneesh Asokan on 08/05/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation
extension ShareShoppingViewController {
    
    func initialiseUIComponents() {
        self.lottieAnimationView.backgroundBehavior = .pauseAndRestore
        self.lottieLoaderAnimation.backgroundBehavior = .pauseAndRestore
    }
    
    func fillSelectedInvitees() {
        self.calenderUsers.selectedUsers = self.selectedInvitees.filter({ $0.readResponseStatus() != .eRejected }).map({ return CalendarUser($0) })
//        self.viewNoData.isHidden = !self.calenderUsers.selectedUsers.isEmpty
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
