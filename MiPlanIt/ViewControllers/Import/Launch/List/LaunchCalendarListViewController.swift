//
//  LaunchCalendarListViewController.swift
//  MiPlanIt
//
//  Created by Arun on 09/04/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit

class LaunchCalendarListViewController: CalendarListBaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func skipButtonClicked(_ sender: Any) {
        if let user = Session.shared.readUser(), user.readUserSettings().isCustomDashboard {
            self.navigationController?.storyboard(StoryBoards.customDashboard, setRootViewController: StoryBoardIdentifier.customDashboard)
        }
        else  {
            self.navigationController?.storyboard(StoryBoards.dashboard, setRootViewController: StoryBoardIdentifier.dashboard)
        }
    }
    
    override func importCalendarSuccessfully() {
        if let user = Session.shared.readUser(), user.readUserSettings().isCustomDashboard {
            self.navigationController?.storyboard(StoryBoards.customDashboard, setRootViewController: StoryBoardIdentifier.customDashboard)
        }
        else  {
            self.navigationController?.storyboard(StoryBoards.dashboard, setRootViewController: StoryBoardIdentifier.dashboard)
        }
    }
}
