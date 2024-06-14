//
//  ReLaunchImportCalendarViewController.swift
//  MiPlanIt
//
//  Created by Arun on 09/04/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit

class ReLaunchImportCalendarViewController: ImportCalendarBaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func cancelButtonClicked(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        switch segue.destination {
        case is ReLaunchCalendarListViewController:
            let reLaunchCalendarListViewController = segue.destination as! ReLaunchCalendarListViewController
            if let outlookData = sender as? (MiPlanItEnumCalendarType, String, String) {
                reLaunchCalendarListViewController.calendarType = outlookData.0
                reLaunchCalendarListViewController.outlookAuthenticationCode = outlookData.1
                reLaunchCalendarListViewController.outlookRedirectionUrl = outlookData.2
            }
            else {
                reLaunchCalendarListViewController.calendarType = sender as? MiPlanItEnumCalendarType
            }
            reLaunchCalendarListViewController.delegate = self
            reLaunchCalendarListViewController.appliedColorCodeObjects = self.addedColorCodes
        default: break
        }
    }
}
