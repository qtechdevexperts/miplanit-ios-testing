//
//  SearchFilterDateViewController.swift
//  MiPlanIt
//
//  Created by Febin Paul on 22/12/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit

protocol SearchFilterDateViewControllerDelegate: AnyObject {
    func searchFilterDateViewController(_ searchFilterDateViewController: SearchFilterDateViewController, selectedStartDate: Date, selectedEndDate: Date)
    func searchFilterDateViewControllerClearDate(_ searchFilterDateViewController: SearchFilterDateViewController)
}

class SearchFilterDateViewController: UIViewController {
    
    weak var delegate: SearchFilterDateViewControllerDelegate?
    var startDateSelected: Date = Date()
    var endDateSelected: Date = Date()
    
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var bottomDropDownConstraints: NSLayoutConstraint!
    @IBOutlet weak var heightDropDownConstraints: NSLayoutConstraint!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initializeUIComponents()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.showOrHideDropDownOptions(true)
        super.viewDidAppear(animated)
    }
    
    @IBAction func dismissDropDownButtonTouched(_ sender: UIButton) {
        self.showOrHideDropDownOptions(false)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.26) {
            self.dismiss(animated: false, completion: nil)
        }
    }
    
    @IBAction func clearButtonClicked(_ sender: UIButton) {
        self.showOrHideDropDownOptions(false)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.26) {
            self.dismiss(animated: false) {
                self.delegate?.searchFilterDateViewControllerClearDate(self)
            }
        }
    }
    
    @IBAction func switchSegment(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            self.datePicker.date = self.startDateSelected
        }
        else {
            self.datePicker.date = self.endDateSelected
        }
    }
    
    @IBAction func doneButtonClicked(_ sender: UIButton) {
        self.showOrHideDropDownOptions(false)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.26) {
            self.dismiss(animated: false) {
                self.delegate?.searchFilterDateViewController(self, selectedStartDate: self.startDateSelected, selectedEndDate: self.endDateSelected)
            }
        }
    }
    
    @IBAction func dateChanged(_ sender: UIDatePicker) {
        if self.segmentedControl.selectedSegmentIndex == 0 {
            self.startDateSelected = self.datePicker.date
            if self.startDateSelected > self.endDateSelected {
                self.endDateSelected = self.startDateSelected
            }
        }
        else {
            self.endDateSelected = self.datePicker.date
            if self.endDateSelected < self.startDateSelected {
                self.startDateSelected = self.endDateSelected
            }
        }
        if self.endDateSelected > self.startDateSelected.adding(years: 1) {
            self.endDateSelected = self.startDateSelected.adding(years: 1)
            if self.segmentedControl.selectedSegmentIndex == 1 {self.datePicker.date = self.endDateSelected}
        }
    }
    
    
}
