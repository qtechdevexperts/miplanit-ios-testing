//
//  ToDoDueDateViewController.swift
//  MiPlanIt
//
//  Created by Febin Paul on 14/07/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit

protocol DueDateViewControllerDelegate: AnyObject {
    func dueDateViewController(_ dueDateViewController: DueDateViewController, dueDate: Date)
}

class DueDateViewController: UIViewController {
    
    var selectedDate: Date = Date()
    weak var delegate: DueDateViewControllerDelegate?
    @IBOutlet weak var bottomDropDownConstraints: NSLayoutConstraint!
    @IBOutlet weak var dayDatePicker: DayDatePicker?
    
    @IBAction func dismissDropDownButtonTouched(_ sender: UIButton) {
        self.showOrHideDropDownOptions(false)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.26) {
            self.dismiss(animated: false, completion: nil)
        }
    }
    
    @IBAction func doneButtonClicked(_ sender: UIButton) {
        self.showOrHideDropDownOptions(false)
        self.delegate?.dueDateViewController(self, dueDate: self.selectedDate)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.26) {
            self.dismiss(animated: false, completion: nil)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.initializeUIComponents()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.showOrHideDropDownOptions(true)
        super.viewDidAppear(animated)
    }

}
