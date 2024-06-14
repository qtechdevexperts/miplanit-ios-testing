//
//  LaunchImportCalendarViewController.swift
//  MiPlanIt
//
//  Created by Arun on 09/04/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit

class LaunchImportCalendarViewController: ImportCalendarBaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        performSegue(withIdentifier: "test1", sender: self)
        // Do any additional setup after loading the view.
    }
    
    override func skipButtonClicked(_ sender: Any) {
        if let user = Session.shared.readUser(), user.readUserSettings().isCustomDashboard {
            self.navigationController?.storyboard(StoryBoards.customDashboard, setRootViewController: StoryBoardIdentifier.customDashboard)
        }
        else  {
            self.navigationController?.storyboard(StoryBoards.dashboard, setRootViewController: StoryBoardIdentifier.dashboard)
        }
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        switch segue.destination {
        case is LaunchCalendarListViewController:
            let launchCalendarListViewController = segue.destination as! LaunchCalendarListViewController
            if let outlookData = sender as? (MiPlanItEnumCalendarType, String, String) {
                launchCalendarListViewController.calendarType = outlookData.0
                launchCalendarListViewController.outlookAuthenticationCode = outlookData.1
                launchCalendarListViewController.outlookRedirectionUrl = outlookData.2
            }
            else {
                launchCalendarListViewController.calendarType = sender as? MiPlanItEnumCalendarType
            }
            launchCalendarListViewController.delegate = self
            launchCalendarListViewController.appliedColorCodeObjects = self.addedColorCodes
        default: break
        }
    }
}
