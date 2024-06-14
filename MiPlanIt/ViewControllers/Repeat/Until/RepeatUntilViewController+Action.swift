//
//  RepeatUntilViewController+Action.swift
//  MiPlanIt
//
//  Created by Febin Paul on 23/06/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation


extension RepeatUntilViewController {
    
    func initializeUIComponents() {
        self.labelDopDownTitle.text = "Until"
        self.labelUntilDate.text = "Until: " + self.untilDate.stringFromDate(format: DateFormatters.DDHMMHYYYY)
        self.datePicker.date = self.untilDate
        self.datePicker.minimumDate = self.minimumDate
        self.datePicker.setValue(UIColor.white, forKeyPath: "textColor")
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
    
    func showOrHideDropDownOptions(_ show: Bool) {
        self.bottomDropDownConstraints.constant = show ? 0 : -(self.readHeightForDropDownView())
        self.view.setNeedsUpdateConstraints()
        UIView.animate(withDuration: 0.25) {
            self.view.layoutIfNeeded()
        }
    }
    func readHeightForDropDownView() -> CGFloat {
        return 400.0
    }
}
