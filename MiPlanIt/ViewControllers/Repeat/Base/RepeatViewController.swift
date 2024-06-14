//
//  RepeatViewController.swift
//  MiPlanIt
//
//  Created by Aneesh Asokan on 20/06/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit

protocol RepeatViewControllerDelegate: class {
    func repeatViewController(_ repeatViewController: RepeatViewController, recurrenceRule: String)
}

class RepeatViewController: UIViewController {
    
    var recurrenceRule: String = Strings.empty
    var orginalRecurrenceRule: String = Strings.empty {
        didSet {
            self.recurrenceRule = orginalRecurrenceRule
        }
    }
    var myPlanItEvent: MiPlanItEvent?
    var dropDownCategory: DropDownCategory = .eFrequency
    var repeatModel: RepeatModel = RepeatModel()
    var eventStartDate: Date?
    weak var delegate: RepeatViewControllerDelegate?
    
    @IBOutlet var buttonFrequencys: [UIButton]!
    @IBOutlet weak var txtFldInterval: FloatingTextField!
    @IBOutlet weak var buttonInterval: UIButton!
    @IBOutlet weak var txtFldUntil: FloatingTextField!
    @IBOutlet weak var buttonUntil: UIButton!
    @IBOutlet weak var txtFldNoOfOccurences: FloatingTextField!
    @IBOutlet weak var buttonNoOfOccurences: UIButton!
    @IBOutlet weak var viewFrequency: UIView!
    @IBOutlet weak var viewInterval: UIView!
    @IBOutlet weak var viewUntil: UIView!
    @IBOutlet weak var viewOccurence: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.setView()
    }
    
    @IBAction func backButtonClicked(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func applyButtonClicked(_ sender: UIButton) {
        let ruleString = self.createRecurrenceRule()
        self.delegate?.repeatViewController(self, recurrenceRule: ruleString)
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func frequencyButtonClicked(_ sender: UIButton) {
        for btn in buttonFrequencys {
            btn.isSelected = false
        }
        sender.isSelected = true
        self.repeatModel.frequency = self.getFrequencyDropDownItemFromButton(sender)
        self.resetRepeatData()
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        switch segue.destination {
        case is RepeatFullDropDownViewController:
            if let btnSender = sender as? UIButton {
                self.dropDownCategory = DropDownCategory(rawValue: btnSender.tag)!
                let repeatDropDownViewController = segue.destination as? RepeatFullDropDownViewController
                repeatDropDownViewController?.dropDownCategory = self.dropDownCategory
                repeatDropDownViewController?.repeatModel = self.repeatModel
                repeatDropDownViewController?.delegate = self
            }
        case is RepeatMultiSelectionDropDownController:
            let repeatMultiSelectionDropDownController = segue.destination as? RepeatMultiSelectionDropDownController
            repeatMultiSelectionDropDownController?.repeatModel = self.repeatModel
            repeatMultiSelectionDropDownController?.delegate = self
        case is RepeatUntilViewController:
            let repeatUntilViewController = segue.destination as? RepeatUntilViewController
            repeatUntilViewController?.repeatModel = self.repeatModel
            repeatUntilViewController?.minimumDate = self.eventStartDate ?? Date()
            repeatUntilViewController?.delegate = self
        default:
            break
        }
    }
    
}
