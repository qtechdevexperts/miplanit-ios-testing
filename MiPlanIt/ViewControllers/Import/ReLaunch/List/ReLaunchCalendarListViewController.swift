//
//  ReLaunchCalendarListViewController.swift
//  MiPlanIt
//
//  Created by Arun on 09/04/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit

class ReLaunchCalendarListViewController: CalendarListBaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func cancelButtonClicked(_ sender: Any) {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    override func importCalendarSuccessfully() {
        self.navigationController?.storyboard(StoryBoards.calendar, setRootViewController: StoryBoardIdentifier.calendar)
    }
}
