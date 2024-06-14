//
//  RepeatMultiSelectionDropDownController.swift
//  MiPlanIt
//
//  Created by Febin Paul on 23/06/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit

protocol RepeatMultiSelectionDropDownControllerDelegate: class {
    func repeatMultiSelectionDropDownController(_ repeatMultiSelectionDropDownController: RepeatMultiSelectionDropDownController, selectedItem: [Any])
}

class RepeatMultiSelectionDropDownController: UIViewController {
    
    var dropDownItems: [Any] = []
    var itemSelectedDropDown: [Any] = []
    var repeatModel: RepeatModel?
    weak var delegate: RepeatMultiSelectionDropDownControllerDelegate?
    
    @IBOutlet weak var labelDopDownTitle: UILabel!
    @IBOutlet weak var bottomDropDownConstraints: NSLayoutConstraint!
    @IBOutlet weak var tableViewDropDownOptions: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.initializeUIComponents()
        self.initialiseDropDownValues()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.showOrHideDropDownOptions(true)
    }
    
    func readDropDownCaption() -> String? {
        return self.repeatModel?.frequency.dropDownType == .eEveryWeek ? "On Week Days" : "On Day"
    }
    
    func readAllDropDownValues() -> [Any] {
        guard let frequency = self.repeatModel?.frequency else {
            return []
        }
        if frequency.dropDownType == .eEveryWeek {
            return [DropDownItem(name: Strings.Sunday, type: .eSunday), DropDownItem(name: Strings.Monday, type: .eMonday), DropDownItem(name: Strings.Tuesday, type: .eTuesday), DropDownItem(name: Strings.Wednesday, type: .eWednesday), DropDownItem(name: Strings.Thursday, type: .eThursday), DropDownItem(name: Strings.Friday, type: .eFriday), DropDownItem(name: Strings.Saturday, type: .eSaturday)]
        }
        else if frequency.dropDownType == .eEveryMonth {
            return Array(1...31)
        }
        return []
    }
    
    func setAllSelectedDropDownValues() {
        guard let frequency = self.repeatModel?.frequency else {
            return
        }
        if frequency.dropDownType == .eEveryWeek, let _ = self.dropDownItems as? [DropDownItem] {
            self.repeatModel?.onDays.forEach({ (value) in
                if let weekDay = self.getWeekDayName(value: value) {
                    self.itemSelectedDropDown.append(weekDay)
                }
            })
        }
        else if frequency.dropDownType == .eEveryMonth {
            self.repeatModel?.onDays.forEach({ (value) in
                self.itemSelectedDropDown.append(value)
            })
        }
        self.tableViewDropDownOptions.reloadData()
    }
    
    func readHeightForDropDownView() -> CGFloat {
        return 400.0
    }
    
    func readHeightForCell() -> CGFloat {
        return 54
    }
    
    @IBAction func doneButtonClicked(_ sender: UIButton) {
        self.delegate?.repeatMultiSelectionDropDownController(self, selectedItem: self.itemSelectedDropDown)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.26) {
            self.dismiss(animated: false, completion: nil)
        }
    }
    @IBAction func dismissDropDownButtonTouched(_ sender: UIButton) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.26) {
            self.dismiss(animated: false, completion: nil)
        }
    }
    
}
