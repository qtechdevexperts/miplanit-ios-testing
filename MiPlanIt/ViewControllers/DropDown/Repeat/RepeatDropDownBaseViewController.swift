//
//  RepeatDropDownBaseViewController.swift
//  MiPlanIt
//
//  Created by Febin Paul on 05/05/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit

class RepeatDropDownBaseViewController: UIViewController {
    
    var dropDownItems: [DropDownItem] = []
    var itemSelectionDropDown: DropDownItem?
    
    @IBOutlet weak var labelDopDownTitle: UILabel!
    @IBOutlet weak var tableViewDropDownOptions: UITableView!
    @IBOutlet weak var bottomDropDownConstraints: NSLayoutConstraint!
    @IBOutlet weak var bottomCalendarDropDownConstraints: NSLayoutConstraint!
    @IBOutlet weak var viewHeightDropDownConstraints: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initializeUIComponents()
        self.initialiseDropDownValues()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.showOrHideDropDownOptions(true)
        super.viewDidAppear(animated)
    }
    
    //MARK: - Override Methods
    func readDropDownCaption() -> String? {
        return ""
    }
    
    func readAllDropDownValues() -> [DropDownItem] {
        return []
    }
    
    func readHeightForCell() -> CGFloat {
        return 54
    }
    
    func readHeightForDropDownView() -> CGFloat {
        return 500.0
    }
    
    func readHeightForCalendarDropDownView() -> CGFloat {
        return 250.0
    }
    
    func sendSelectedOption(_ option: RepeatDropDown) {
    }
    
    @IBAction func dismissDropDownButtonTouched(_ sender: UIButton) {
        self.showOrHideDropDownOptions(false)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.26) {
            self.dismiss(animated: false, completion: nil)
        }
    }
    
    @IBAction func doneButtonClicked(_ sender: UIButton) {
        guard let selectionDropDown = self.itemSelectionDropDown else {
            return
        }
        self.showOrHideDropDownOptions(false)
        self.sendSelectedOption(RepeatDropDown(dropDownItem: selectionDropDown))
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.26) {
            self.dismiss(animated: false, completion: nil)
        }
    }
}
