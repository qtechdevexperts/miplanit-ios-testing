//
//  ShareToDoListViewController+Action.swift
//  MiPlanIt
//
//  Created by Febin Paul on 09/07/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation
extension ShareToDoListViewController {
    
    func initialiseUIComponents() {
        self.lottieAnimationView.backgroundBehavior = .pauseAndRestore
        self.lottieLoaderAnimation.backgroundBehavior = .pauseAndRestore
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeGesture))
        swipeDown.direction = .down
        self.view.addGestureRecognizer(swipeDown)
    }
    
    @objc func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.26) {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func fillSelectedInvitees() {
        self.calenderUsers.selectedUsers = self.selectedInvitees.map({ return CalendarUser($0) })
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

