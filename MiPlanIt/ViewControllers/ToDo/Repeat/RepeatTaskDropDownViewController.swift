//
//  RepeatTaskDropDownViewController.swift
//  MiPlanIt
//
//  Created by Febin Paul on 05/05/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit

protocol RepeatTaskDropDownViewControllerDelegate: class {
    func repeatTaskDropDownViewController(_ controller: RepeatTaskDropDownViewController, selectedDone: RepeatDropDown)
}

class RepeatTaskDropDownViewController: RepeatDropDownBaseViewController {
    
    weak var delegate: RepeatTaskDropDownViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func readDropDownCaption() -> String? {
        return Strings.chooseRepeatType
    }
    
    override func readAllDropDownValues() -> [DropDownItem] {
        return self.readDropDownOptions()
    }

    override func readHeightForCell() -> CGFloat {
        return 54
    }

    
    override func readHeightForDropDownView() -> CGFloat {
        return 500.0
    }
    
    override func readHeightForCalendarDropDownView() -> CGFloat {
        return 250.0
    }
    
    override func sendSelectedOption(_ option: RepeatDropDown) {
        self.delegate?.repeatTaskDropDownViewController(self, selectedDone: option)
    }
    
    func readDropDownOptions() -> [DropDownItem] {
        return [DropDownItem(name: Strings.never, type: .eNever), DropDownItem(name: Strings.everyDay, type: .eEveryDay), DropDownItem(name: Strings.everyWeek, type: .eEveryWeek), DropDownItem(name: Strings.everyMonth, type: .eEveryMonth), DropDownItem(name: Strings.everyYear, type: .eEveryYear)]
    }
    
}
