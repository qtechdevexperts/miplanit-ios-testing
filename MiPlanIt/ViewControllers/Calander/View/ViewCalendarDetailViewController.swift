//
//  ViewCalendarDetailViewController.swift
//  MiPlanIt
//
//  Created by Febin Paul on 20/08/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit


class ViewCalendarDetailViewController: UIViewController {
    
    var calendar = NewCalendar()
    
    @IBOutlet weak var labelCalendarName: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var constraintTableViewHeight: NSLayoutConstraint!
    @IBOutlet weak var imageViewCalendarImage: UIImageView!
    @IBOutlet weak var viewCalendarColor: UIView!
    @IBOutlet weak var labelNotifyUserCount: UILabel!
    @IBOutlet weak var viewAddInvitees: UIView!
    @IBOutlet weak var viewNotify: UIView!
    @IBOutlet weak var imageViewColorCode: UIImageView!
    
    @IBAction func closeButtonClicked(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initialiseUIComponents()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.destination {
        case is SharedViewController:
            let sharedViewController = segue.destination as! SharedViewController
            sharedViewController.selectedInvitees = calendar.notifyUsers
        default: break
        }
    }
}
