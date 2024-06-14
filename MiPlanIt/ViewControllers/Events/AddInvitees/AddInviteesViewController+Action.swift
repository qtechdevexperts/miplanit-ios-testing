//
//  AddInviteesViewController+Lottie.swift
//  MiPlanIt
//
//  Created by Arun on 20/04/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

extension AddInviteesViewController {
    
    func initialiseUIComponents() {
        self.lottieAnimationView.backgroundBehavior = .pauseAndRestore
        self.lottieLoaderAnimation.backgroundBehavior = .pauseAndRestore
    }
    
    func fillSelectedInvitees() {
        self.calenderUsers.selectedUsers = self.selectedInvitees.map({ return CalendarUser($0) })
    }
    
    func startLottieAnimations() {
        UIApplication.shared.beginIgnoringInteractionEvents()
        self.viewFetchingData.isHidden = false
        self.lottieAnimationView.play(fromProgress: 0, toProgress: 0.1, loopMode: .loop, completion: nil)
    }
    
    func stopLottieAnimations() {
        UIApplication.shared.endIgnoringInteractionEvents()
        self.viewFetchingData.isHidden = true
        if self.lottieAnimationView.isAnimationPlaying { self.lottieAnimationView.stop() }
    }
}
