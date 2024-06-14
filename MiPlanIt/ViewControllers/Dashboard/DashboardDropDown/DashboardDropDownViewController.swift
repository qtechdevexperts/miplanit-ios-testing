//
//  DashboardDropDownViewController.swift
//  MiPlanIt
//
//  Created by MS Nischal on 20/03/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit

protocol DashboardDropDownViewControllerDelegate: AnyObject {
    func dashboardDropDownViewController(_ controller: DashboardDropDownViewController, selectedOption: DropDownOptionType)
}

class DashboardDropDownViewController: UIViewController {
    
    weak var delegate: DashboardDropDownViewControllerDelegate?
    @IBOutlet weak var bottomDropDownConstraints: NSLayoutConstraint!
    @IBOutlet weak var heightDropDownConstraints: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initializeUIComponents()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.showOrHideDropDownOptions(true)
        super.viewDidAppear(animated)
    }
    
    @IBAction func buttonOptionClicked(_ sender: UIButton) {
        self.sendSelectedOption(sender)
    }
    
    @IBAction func dismissDropDownButtonTouched(_ sender: UIButton) {
        self.showOrHideDropDownOptions(false)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.26) {
            self.dismiss(animated: false, completion: nil)
        }
    }
    
}
