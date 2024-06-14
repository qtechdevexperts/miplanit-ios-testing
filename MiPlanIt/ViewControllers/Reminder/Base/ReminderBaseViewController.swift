//
//  ReminderBaseViewController.swift
//  MiPlanIt
//
//  Created by Febin Paul on 12/08/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit

protocol ReminderBaseViewControllerDelegate: AnyObject {
    func reminderBaseViewController(_ reminderBaseViewController: ReminderBaseViewController, reminderValue: ReminderModel)
    func reminderBaseViewControllerBackClicked(_ reminderBaseViewController: ReminderBaseViewController)
}

class ReminderBaseViewController: UIViewController {
    
    var startDate: Date!
    var toDoReminder: ReminderModel? {
        didSet {
            self.remindModel = toDoReminder
        }
    }
    var remindModel: ReminderModel!
    var arrayCustomReminderNumbers: [Int] = [] {
        didSet {
            self.pickerViewNumber.reloadAllComponents()
        }
    }
    let arrayUnits: [String] = ["mins", "hours", "days", "weeks", "months"]
    weak var delegate: ReminderBaseViewControllerDelegate?
    
    @IBOutlet weak var viewTopColorHeader: UIView!
    @IBOutlet weak var viewTopNonColorHeader: UIView!
    @IBOutlet weak var viewTopBarGradient: UIView!
    @IBOutlet weak var pickerViewNumber: UIPickerView!
    @IBOutlet weak var pickerViewTimeUnit: UIPickerView!
    @IBOutlet weak var viewTimePicker: UIView!
    @IBOutlet weak var viewCustomTimeLabel: UIView!
    @IBOutlet weak var viewCustomPicker: UIView!
    @IBOutlet weak var buttonTimePicker: UIButton!
    @IBOutlet weak var dateTimePicker: UIDatePicker!
    @IBOutlet var arrayViewsReminders: [ReminderOptionView]!
    @IBOutlet weak var labelReminderTime: UILabel!
    @IBOutlet weak var buttonRemoveCustomReminder: UIButton!
    @IBOutlet weak var labelCustomReminderBeforeTime: UILabel!
    @IBOutlet weak var buttonCustomReminderBefore: UIButton!
    @IBOutlet weak var labelReminderDate: UILabel!
    @IBOutlet weak var imageViewTimeArrow: UIImageView?
    @IBOutlet weak var scrollView: UIScrollView?
    
    @IBAction func backButtonPopClicked(_ sender: UIButton) {
        self.delegate?.reminderBaseViewControllerBackClicked(self)
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func backButtonDismissClicked(_ sender: UIButton) {
        self.delegate?.reminderBaseViewControllerBackClicked(self)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func doneButtonPopClicked(_ sender: UIButton) {
        self.delegate?.reminderBaseViewController(self, reminderValue: self.remindModel)
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func doneButtonDismissClicked(_ sender: UIButton) {
        self.delegate?.reminderBaseViewController(self, reminderValue: self.remindModel)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func timeButtonClicked(_ sender: UIButton) {
        self.buttonTimePicker.isSelected = !self.buttonTimePicker.isSelected
        self.viewTimePicker.isHidden = !self.buttonTimePicker.isSelected
        self.dateTimePicker.setDate(self.remindModel.getReminderTimeDate(), animated: true)
    }
    
    @IBAction func customReminderClicked(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        self.viewCustomPicker.isHidden = !sender.isSelected
        self.remindModel.setReminderOption(.custom)
        self.clearReminderOptionSelection()
        self.updateCustomReminderNumbers(unit: self.remindModel.reminderBeforeUnit)
        self.updateCustomReminderUnit(unit: self.remindModel.reminderBeforeUnit)
        self.updatedCustomReminderValue(self.remindModel.reminderBeforeValue)
        self.updateCustomReminderlabel()
    }
    
    @IBAction func removeCustomReminderClicked(_ sender: UIButton) {
        self.remindModel.setInitDefaultReminder()
        self.updateReminderOptionSelection()
        self.buttonRemoveCustomReminder.isSelected = false
        self.buttonCustomReminderBefore.isSelected = false
        self.buttonRemoveCustomReminder.isUserInteractionEnabled = false
        self.viewCustomPicker.isHidden = true
        self.updateCustomReminderlabel()
    }
    
    @IBAction func timePickerOnChange(_ sender: UIDatePicker) {
        self.remindModel.setReminderTimeFrom(sender.date)
        self.labelReminderTime.text = self.remindModel.readReminderTimeString()
    }
    
    @IBAction func reminderOptionClicked(_ sender: UIButton) {
        if let reminderView = sender.superview as? ReminderOptionView {
            self.updateReminderOption(reminderView)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.initializeUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if self.remindModel.reminderOption == .custom, let view = self.scrollView {
            let bottomOffset = CGPoint(x: 0, y: view.contentSize.height - view.bounds.size.height)
            if bottomOffset.y > 0 {
                self.scrollView?.setContentOffset(bottomOffset, animated: true)
            }
        }
    }

}
