//
//  RepeatMultiSelectionDropDownController+Action.swift
//  MiPlanIt
//
//  Created by Febin Paul on 23/06/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

extension RepeatMultiSelectionDropDownController {
    
    func initializeUIComponents() {
        self.labelDopDownTitle.text = self.readDropDownCaption()
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
    func initialiseDropDownValues() {
        self.dropDownItems = self.readAllDropDownValues()
        self.setAllSelectedDropDownValues()
    }
    
    func showOrHideDropDownOptions(_ show: Bool) {
        self.bottomDropDownConstraints.constant = show ? 0 : -(self.readHeightForDropDownView())
        self.view.setNeedsUpdateConstraints()
        UIView.animate(withDuration: 0.25) {
            self.view.layoutIfNeeded()
        }
    }
    
    func getWeekDayName(value: Int) -> DropDownItem? {
        switch value {
        case 1:
            return DropDownItem(name: Strings.Sunday, type: .eSunday)
        case 2:
            return DropDownItem(name: Strings.Monday, type: .eMonday)
        case 3:
            return DropDownItem(name: Strings.Tuesday, type: .eTuesday)
        case 4:
            return DropDownItem(name: Strings.Wednesday, type: .eWednesday)
        case 5:
            return DropDownItem(name: Strings.Thursday, type: .eThursday)
        case 6:
            return DropDownItem(name: Strings.Friday, type: .eFriday)
        default:
            return DropDownItem(name: Strings.Saturday, type: .eSaturday)
        }
    }
}
