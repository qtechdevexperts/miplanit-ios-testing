//
//  DashboardSettingViewController.swift
//  MiPlanIt
//
//  Created by Aneesh Asokan on 10/12/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit

class DashboardSettingViewController: UIViewController {

    @IBOutlet weak var buttonStandard: UIButton!
    @IBOutlet weak var buttonCustom: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initialiseUIComponents()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func changeDashboardTypeClicked(_ sender: UIButton) {
        if sender == self.buttonCustom {
            self.buttonCustom.isSelected = true
            self.buttonStandard.isSelected = false
        }
        if sender == self.buttonStandard {
            self.buttonCustom.isSelected = false
            self.buttonStandard.isSelected = true
        }
        Session.shared.readUser()?.readUserSettings().saveCustomDashboard(self.buttonCustom.isSelected)
    }

    //MARK: - IBActions
    @IBAction func backButtonClicked(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
