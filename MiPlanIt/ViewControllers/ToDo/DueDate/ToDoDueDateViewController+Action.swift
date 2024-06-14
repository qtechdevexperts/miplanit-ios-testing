//
//  ToDoDueDateViewController+Action.swift
//  MiPlanIt
//
//  Created by Febin Paul on 14/07/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

extension DueDateViewController {
    
    func initializeUIComponents() {
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeGesture))
        swipeDown.direction = .down
        self.dayDatePicker?.dataSource = self.dayDatePicker
        self.dayDatePicker?.delegate = self.dayDatePicker
        self.dayDatePicker?.dayDatePickerDelegate = self
        self.dayDatePicker?.setUpData()
        self.dayDatePicker?.selectRow(self.dayDatePicker?.selectedDate(date: Date()) ?? 0, inComponent: 0, animated: true)
        self.view.addGestureRecognizer(swipeDown)
        self.dayDatePicker?.setValue(UIColor.white, forKeyPath: "textColor")
    }
    
    @objc func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        self.showOrHideDropDownOptions(false)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.26) {
            self.dismiss(animated: false, completion: nil)
        }
    }
    
    func readHeightForDropDownView() -> CGFloat {
        return 370.0
    }
    
    func showOrHideDropDownOptions(_ show: Bool) {
        self.bottomDropDownConstraints.constant = show ? 0 : -(self.readHeightForDropDownView())
        self.view.setNeedsUpdateConstraints()
        UIView.animate(withDuration: 0.25) {
            self.view.layoutIfNeeded()
        }
    }
}
