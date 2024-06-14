//
//  DropDownBaseViewController.swift
//  MiPlanIt
//
//  Created by MS Nischal on 20/03/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit

class DropDownBaseViewController: UIViewController {
    var itemSelectionDropDown: DropDownItem?
    var dropDownItems: [DropDownItem] = [] {
        didSet {
            self.tableViewDropDownOptions.reloadData()
        }
    }
    
    @IBOutlet weak var labelDopDownTitle: UILabel!
    @IBOutlet weak var tableViewDropDownOptions: UITableView!
    @IBOutlet weak var bottomDropDownConstraints: NSLayoutConstraint!
    @IBOutlet weak var heightDropDownConstraints: NSLayoutConstraint!
    @IBOutlet weak var buttonCancel: UIButton?

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
        return 300.0
    }
    
    func sendSelectedOption(_ option: DropDownItem) {
    }
    
    @IBAction func dismissDropDownButtonTouched(_ sender: UIButton) {
        self.showOrHideDropDownOptions(false)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.26) {
            self.dismiss(animated: false, completion: nil)
        }
    }
    
    @IBAction func doneButtonTouched(_ sender: UIButton) {
        
    }
    
    @IBAction func cancelOptionClicked(_ sender: UIButton) {
        self.dismissDropDownButtonTouched(sender)
    }
}
