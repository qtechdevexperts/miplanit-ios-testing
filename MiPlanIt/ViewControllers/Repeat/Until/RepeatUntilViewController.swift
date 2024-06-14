//
//  RepeatUntilViewController.swift
//  MiPlanIt
//
//  Created by Febin Paul on 23/06/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit

protocol RepeatUntilViewControllerDelegate: AnyObject {
    func repeatUntilViewController(_ RepeatUntilViewController: RepeatUntilViewController, isForever: Bool, untilDate: Date?)
}

class RepeatUntilViewController: UIViewController {
    
    weak var delegate: RepeatUntilViewControllerDelegate?
    var untilDate: Date = Date()
    var minimumDate: Date = Date()
    @IBOutlet weak var buttonSelection: UIButton!
    @IBOutlet weak var viewUntilDate: UIView!
    @IBOutlet weak var bottomDropDownConstraints: NSLayoutConstraint!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var labelUntilDate: UILabel!
    @IBOutlet weak var labelDopDownTitle: UILabel!
    
    var repeatModel: RepeatModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.initializeUIComponents()
        self.setUntilValue()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.showOrHideDropDownOptions(true)
        super.viewDidAppear(animated)
    }
    
    func setUntilValue() {
        guard let repeatModel = self.repeatModel else { return }
        self.buttonSelection.isSelected = repeatModel.forever
        self.viewUntilDate.alpha = self.buttonSelection.isSelected ? 0.2 : 1.0
        self.viewUntilDate.isUserInteractionEnabled = self.buttonSelection.isSelected ? false : true
        if let untilDate = repeatModel.untilDate {
            self.datePicker.setDate(untilDate, animated: true)
            self.untilDate = self.datePicker.date
            self.labelUntilDate.text = "Until: "+self.untilDate.stringFromDate(format: DateFormatters.DDHMMHYYYY)
        }
    }
    
    @IBAction func foreverButtonClicked(_ sender: UIButton) {
        self.buttonSelection.isSelected = !self.buttonSelection.isSelected 
        self.viewUntilDate.alpha = self.buttonSelection.isSelected ? 0.2 : 1.0
        self.viewUntilDate.isUserInteractionEnabled = self.buttonSelection.isSelected ? false : true
    }
    
    @IBAction func doneButtonClicked(_ sender: UIButton) {
        self.delegate?.repeatUntilViewController(self, isForever: self.buttonSelection.isSelected, untilDate: self.untilDate)
        self.showOrHideDropDownOptions(false)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.26) {
            self.dismiss(animated: false, completion: nil)
        }
    }
    
    @IBAction func dismissDropDownButtonTouched(_ sender: UIButton) {
        self.showOrHideDropDownOptions(false)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.26) {
            self.dismiss(animated: false, completion: nil)
        }
    }
    
    @IBAction func datePickerChanged(_ sender: UIDatePicker) {
        self.untilDate = self.datePicker.date
        self.labelUntilDate.text = "Until: "+self.untilDate.stringFromDate(format: DateFormatters.DDHMMHYYYY)
    }
}
