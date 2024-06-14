//
//  TimePickerViewController.swift
//  MiPlanIt
//
//  Created by Febin Paul on 09/03/21.
//  Copyright © 2021 Arun. All rights reserved.
//

import UIKit

protocol TimePickerViewControllerDelegate: class {
    func timePickerViewController(_ timePickerViewController: TimePickerViewController, startDate: Date, endDate: Date)
}

class TimePickerViewController: UIViewController {
    
    enum DateSelection {
        case start, end
    }
    
    var startingTime: Date = Date()
    var endingTime: Date = Date()
    var currentSelection: DateSelection = .start {
        didSet {
            switch self.currentSelection {
            case .start:
                self.buttonStartTime?.isSelected = true
                self.butttonEndTime?.isSelected = false
            case .end:
                self.buttonStartTime?.isSelected = false
                self.butttonEndTime?.isSelected = true
            }
        }
    }
    weak var delegate: TimePickerViewControllerDelegate?

    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var buttonStartTime: UIButton?
    @IBOutlet weak var butttonEndTime: UIButton?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.initializeUI()
    }
    
    @IBAction func startTimeButtonClicked(_ sender: UIButton) {
        self.currentSelection = .start
        self.datePicker.setDate(self.startingTime, animated: false)
    }
    
    @IBAction func endTimeButtonClicked(_ sender: UIButton) {
        self.currentSelection = .end
        self.datePicker.setDate(self.endingTime, animated: false)
    }
    
    @IBAction func backButtonClicked(_ sender: UIButton) {
        self.dismiss(animated: false, completion: nil)
    }
    
    @IBAction func doneButtonClicked(_ sender: UIButton) {
        self.dismiss(animated: true) {
            self.delegate?.timePickerViewController(self, startDate: self.startingTime, endDate: self.endingTime)
        }
    }
    
    @IBAction func timeValueChanged(_ sender: UIDatePicker) {
        switch self.currentSelection {
        case .start:
            self.updateStartTime(sender.date)
        case .end:
            self.updateEndTime(sender.date)
        }
    }
    
}
