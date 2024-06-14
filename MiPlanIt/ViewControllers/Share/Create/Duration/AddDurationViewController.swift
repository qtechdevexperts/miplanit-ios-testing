//
//  AddDurationViewController.swift
//  MiPlanIt
//
//  Created by Febin Paul on 26/03/21.
//  Copyright © 2021 Arun. All rights reserved.
//

import UIKit

protocol AddDurationViewControllerDelegate: AnyObject {
    func addDurationViewController(_ addDurationViewController: AddDurationViewController, duartion: DurationModel)
}

class AddDurationViewController: UIViewController {
    
    let arrayUnits: [String] = ["mins", "hours"]
    var arrayCustomDurationNumbers: [Int] = [] {
        didSet {
            self.pickerViewNumber.reloadAllComponents()
        }
    }
    var durationModel: DurationModel = DurationModel()
    weak var delegate: AddDurationViewControllerDelegate?
    
    @IBOutlet weak var viewCustomPicker: UIView!
    @IBOutlet var arrayViewsDuration: [ReminderOptionView]!
    @IBOutlet weak var pickerViewNumber: UIPickerView!
    @IBOutlet weak var pickerViewTimeUnit: UIPickerView!
    @IBOutlet weak var buttonRemoveCustomDuration: UIButton!
    @IBOutlet weak var buttonCustomDuration: UIButton!
    @IBOutlet weak var viewCustomTimeLabel: UIView!
    @IBOutlet weak var labelCustomDuration: UILabel!
    @IBOutlet weak var scrollView: UIScrollView?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.initializeUI()
    }
    
    @IBAction func backButtonClicked(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func doneButtonClicked(_ sender: UIButton) {
        self.delegate?.addDurationViewController(self, duartion: durationModel)
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func customReminderClicked(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        self.viewCustomPicker.isHidden = !sender.isSelected
        self.durationModel.setDurationOption(.custom)
        self.clearDurationOptionSelection()
        self.updateCustomDurationNumbers(unit: self.durationModel.durationUnit)
        self.updateCustomDurationUnit(unit: self.durationModel.durationUnit)
        self.updatedCustomDurationValue(self.durationModel.durationValue)
        self.updateCustomDurationlabel()
    }
    
    @IBAction func removeCustomReminderClicked(_ sender: UIButton) {
        self.durationModel.setInitDefaultReminder()
        self.updateDurationOptionSelection()
        self.buttonRemoveCustomDuration.isSelected = false
        self.buttonCustomDuration.isSelected = false
        self.buttonRemoveCustomDuration.isUserInteractionEnabled = false
        self.viewCustomPicker.isHidden = true
        self.updateCustomDurationlabel()
    }
    
    @IBAction func durationOptionClicked(_ sender: UIButton) {
        if let reminderView = sender.superview as? ReminderOptionView {
            self.updateDurationOption(reminderView)
        }
    }
}
