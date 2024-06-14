//
//  SearchFilterDateViewController+Action.swift
//  MiPlanIt
//
//  Created by Febin Paul on 22/12/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

extension SearchFilterDateViewController {
    
    func initializeUIComponents() {
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeGesture))
        swipeDown.direction = .down
        self.view.addGestureRecognizer(swipeDown)
        if self.segmentedControl.selectedSegmentIndex == 0 {
            self.datePicker.date = self.startDateSelected
        }
        else {
            self.datePicker.date = self.endDateSelected
        }
        let titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]//UIColor.init(red: 82/255.0, green: 146/255.0, blue: 163/255.0, alpha: 1.0)]
        let titleTextAttributesSel = [NSAttributedString.Key.foregroundColor: UIColor.white]
        self.segmentedControl.setTitleTextAttributes(titleTextAttributes, for: .normal)
        self.segmentedControl.setTitleTextAttributes(titleTextAttributesSel, for: .selected)
        self.segmentedControl.tintColor = UIColor(red: 82/255.0, green: 146/255.0, blue: 163/255.0, alpha: 1)
        self.datePicker.setValue(UIColor.white, forKeyPath: "textColor")
    }
    
    @objc func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        self.showOrHideDropDownOptions(false)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.26) {
            self.dismiss(animated: false, completion: nil)
        }
    }
    
    func showOrHideDropDownOptions(_ show: Bool) {
        self.bottomDropDownConstraints.constant = show ? -10 : -350
        self.heightDropDownConstraints.constant = 350
        self.view.setNeedsUpdateConstraints()
        UIView.animate(withDuration: 0.25) {
            self.view.layoutIfNeeded()
        }
    }
}
