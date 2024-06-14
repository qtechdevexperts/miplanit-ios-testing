//
//  AddCalendarViewController.swift
//  MiPlanIt
//
//  Created by Febin Paul on 03/04/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit

protocol AddCalendarViewControllerDelegate: class {
    func addCalendarViewController(_ viewController: AddCalendarViewController, createdNewCalendar calendar: PlanItCalendar)
}

class AddCalendarViewController: UIViewController {
    
    var calendar = NewCalendar()
    weak var delegate: AddCalendarViewControllerDelegate?
   
    @IBOutlet weak var labelCalendarTitle: UILabel!
    @IBOutlet weak var buttonSave: ProcessingButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var viewImageHolder: UIView!
    @IBOutlet weak var textFieldCalendarName: FloatingTextField!
    @IBOutlet weak var imageViewDefaultUser: UIImageView!
    @IBOutlet weak var constraintTableViewHeight: NSLayoutConstraint!
    @IBOutlet var arrayCalendarImageViews: [CalendarImageView]!
    @IBOutlet weak var viewCalendarColor: CalendarColorView!
    @IBOutlet weak var imageViewCalendarImage: UIImageView!
    @IBOutlet weak var viewAddInvitees: UIView!
    @IBOutlet weak var buttonNotifyUsers: UIButton!
    @IBOutlet weak var viewNotifyUsers: UIView!
    @IBOutlet weak var labelNotifyUser: UILabel!
    @IBOutlet weak var inviteUserButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initialiseUIComponents()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.view.endEditing(true)
        super.viewWillDisappear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !self.isHelpShown() && !self.viewNotifyUsers.isHidden {
            self.performSegue(withIdentifier: "toNotifyCalendarHelp", sender: nil)
            Storage().saveBool(flag: true, forkey: UserDefault.notifyCalendarHelp)
        }
    }
    
    @IBAction func closeButtonClicked(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func saveButtonClicked(_ sender: UIButton) {
        if self.validateCalendarName() {
            self.saveCalendarToServerUsingNetwotk()
        }
    }
    
    @IBAction func changeButtonClicked(_ sender: UIButton) {
        self.performSegue(withIdentifier: Segues.toProfileDropDown, sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.destination {
        case is InviteUsersViewController:
            let inviteUsersViewController = segue.destination as! InviteUsersViewController
            inviteUsersViewController.delegate = self
            inviteUsersViewController.calendar.fullAccesUsers = self.calendar.fullAccesUsers
            inviteUsersViewController.calendar.partailAccesUsers = self.calendar.partailAccesUsers
        case is MessageViewController:
            let messageViewController = segue.destination as! MessageViewController
            messageViewController.caption = (sender as? [String])?.first
            messageViewController.errorDescription = (sender as? [String])?.last
        case is ProfileMediaDropDownViewController:
            let uploadOptionsDropDownViewController = segue.destination as? ProfileMediaDropDownViewController
            uploadOptionsDropDownViewController?.delegate = self
        case is NotifyUserViewController:
            let notifyUserViewController = segue.destination as? NotifyUserViewController
            notifyUserViewController?.delegate = self
            notifyUserViewController?.selectedInvitees = self.calendar.notifyUsers.map({ return OtherUser(calendarUser: $0) })
        default: break
        }
    }
}
