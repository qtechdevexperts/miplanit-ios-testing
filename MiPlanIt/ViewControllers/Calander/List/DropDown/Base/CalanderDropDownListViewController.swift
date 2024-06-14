//
//  CalanderDropDownListViewController.swift
//  MiPlanIt
//
//  Created by Nikhil RajG on 08/04/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit
import EventKit

class CalanderDropDownBaseListViewController: UIViewController {
    
    var syncIndex: Int = 0
    var isModified: Bool = false
    var isFromEvent: CalendarSelection = .allCalendar
    var isCheck = false
    var calanderList: [SocialCalendar] = [] {
        didSet {
//            self.stopLottieAnimations()
//            self.tableViewCalanderList.reloadData()
        }
    }
    var delegateRefresh:refresh?
    var buttonSyncCalendar: ProcessingButton?
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var buttonDone: ProcessingButton!
    @IBOutlet weak var txtfldSearch: PaddingTextField!
    @IBOutlet weak var constraintSearchHeight: NSLayoutConstraint!
    @IBOutlet weak var viewSearchBarContainer: UIView!
    @IBOutlet weak var buttonSearch: UIButton!
    @IBOutlet weak var imageViewNoResult: UIImageView?
    
    var selectedUsers: [CalendarUser] = []
    var allUsers: [CalendarUser] = [] {
        didSet {
            self.showingUsers = allUsers
            self.tableView.reloadData()
        }
    }
    var showingUsers: [CalendarUser] = []
    
    var allDisabledCalendars: [UserCalendarVisibility] = [] {
        didSet {
            self.showingDisabledCalendars = self.allDisabledCalendars
        }
    }
    var showingDisabledCalendars: [UserCalendarVisibility] = []
    
    lazy var userCalendarTypes: [UserCalendarType] = {
        return self.userAvailableCalendarTypes
    }()
    
    lazy var userAvailableCalendarTypes: [UserCalendarType] = {
        return self.getUserCalendarAvailableType()
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func readAllAvailableCalendars() -> [UserCalendarType] {
        return []
    }
    
    func readAllOtherUserCalendars() -> [CalendarUser] {
        return []
    }
    
    func updateUserCalendarDisabledFlag(_ flag: Bool) {

    }
    
    @IBAction func closeButtonClicked(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func doneButtonClicked(_ sender: UIButton) {
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.destination {
        case is MessageViewController:
            let messageViewController = segue.destination as! MessageViewController
            messageViewController.caption = (sender as? [String])?.first
            messageViewController.errorDescription = (sender as? [String])?.last
        case is SharedViewController:
            let sharedViewController = segue.destination as! SharedViewController
            sharedViewController.selectedInvitees = sender as? [CalendarUser] ?? []
        default:
            break
        }
    }
    func downloadCalnderEventsWithDelay(_ calander: SocialCalendar, atIndexPath: IndexPath) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            calander.readGoogleEvents { (status) in
                calander.calendarProgress = status ? 100 : -10
//                self.updateProgress(atIndexPath: atIndexPath)
            }
        }
    }
    func getUserCalendarAvailableType() -> [UserCalendarType] {
        /**
         "test@thesuitch.com"
         calendars/\(encoded)/events
         402792541132-mfgvak2bc69dsa4194dgj2p4u47ela1i.apps.googleusercontent.com
         
         calander.readGoogleEvents { (status) in
             calander.calendarProgress = status ? 100 : -10
             self.updateProgress(atIndexPath: atIndexPath)
         }
         
         let importedCalendars = self.calanderList.filter({ return $0.calendarStatus == .completed })
         guard !importedCalendars.isEmpty else { return }
         self.createServiceToImportCalendarEvents(importedCalendars)
         
         **/
        
//        self.downloadCalnderEventsWithDelay(nil, atIndexPath: IndexPath(row: 0, section: 0))
        
        
        let importedCalendars = self.calanderList.filter({ return $0.calendarStatus == .completed })
//        guard !importedCalendars.isEmpty else { return }
        self.createServiceToImportCalendarEvents(importedCalendars)

        let allCalendar = self.readAllAvailableCalendars().sorted(by: { return $0.type < $1.type })
        if let miPlanitCalendar = allCalendar.filter({ $0.type == "0" }).flatMap({ $0.calendars }).filter({ $0.selected }).filter({ $0.calendar.parentCalendarId == 0 }).first {
            allCalendar.forEach { (userCalendarType) in
                userCalendarType.calendars.forEach { (userCalendarVisibility) in
                    userCalendarVisibility.disabled = true
                }
            }
            miPlanitCalendar.disabled = false
        }
        return allCalendar
    }
}

