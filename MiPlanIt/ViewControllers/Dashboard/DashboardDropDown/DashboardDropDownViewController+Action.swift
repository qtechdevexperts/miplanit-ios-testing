//
//  DashboardDropDownViewController+Action.swift
//  MiPlanIt
//
//  Created by MS Nischal on 20/03/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit

extension DashboardDropDownViewController {
 
    func initializeUIComponents() {
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeGesture))
        swipeDown.direction = .down
        self.view.addGestureRecognizer(swipeDown)
    }
    
    @objc func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        self.showOrHideDropDownOptions(false)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.26) {
            self.dismiss(animated: false, completion: nil)
        }
    }
    
    func sendSelectedOption(_ sender: UIButton) {
        self.showOrHideDropDownOptions(false)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.26) {
            self.dismiss(animated: false) {
                switch sender.tag {
                case 1:
                    self.delegate?.dashboardDropDownViewController(self, selectedOption: .eSwitchDashBoard)
                default:
                    self.delegate?.dashboardDropDownViewController(self, selectedOption: .eNewDashBoard)
                }
            }
        }
        
        
    }
    
    func showOrHideDropDownOptions(_ show: Bool) {
        self.bottomDropDownConstraints.constant = show ? -10 : -300
        self.heightDropDownConstraints.constant = 300
        self.view.setNeedsUpdateConstraints()
        UIView.animate(withDuration: 0.25) {
            self.view.layoutIfNeeded()
        }
    }
}
