//
//  CalendarListViewController.swift
//  MiPlanIt
//
//  Created by Febin Paul on 10/06/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation
import UIKit
import Lottie


protocol CalendarListViewControllerDelegate: AnyObject {
    func calendarListViewController(_ controller: UserCalendarListViewController, selectedOptions: [PlanItCalendar], selectedUsers: [OtherUser])
    func calendarListViewControllerSuccessFullySyncedCalendar(_ controller: UserCalendarListViewController)
    func calendarListViewController(_ controller: UserCalendarListViewController, deleted calendars: [PlanItCalendar])
    func calendarListViewController(_ controller: UserCalendarListViewController, updated calendars: [PlanItCalendar])
}

class UserCalendarListViewController: CalanderDropDownBaseListViewController {
    
    @IBOutlet weak var dotLoader: DotsLoader?
    @IBOutlet weak var viewLoadingGradient: UIView!
    @IBOutlet weak var viewFetchingData: UIView!
    @IBOutlet var lottieAnimationView: LottieAnimationView!
    var selectedCalendars: [PlanItCalendar] = []
    var deletedCalendars: [PlanItCalendar] = []
    var updatedCalendars: [PlanItCalendar] = []
    var otherUsers: [OtherUser] = []
    weak var delegate: CalendarListViewControllerDelegate?
    
    @IBAction func searchButtonClicked(_ sender: UIButton) {
        self.toggleSearch()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initializeView()
        self.setCalendarUsers()
        self.createWebServiceGetDefaultCalendarShare()
//        self.syncIndex = 1
//        self.test2()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.addObserver()
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if self.isModified {
            self.delegate?.calendarListViewControllerSuccessFullySyncedCalendar(self)
        }
        if !self.updatedCalendars.isEmpty {
            self.delegate?.calendarListViewController(self, updated: self.updatedCalendars)
        }
        if !self.deletedCalendars.isEmpty {
            self.delegate?.calendarListViewController(self, deleted: self.deletedCalendars)
        }
        self.removeObserver()
        super.viewWillDisappear(animated)
    }
    
    override func doneButtonClicked(_ sender: UIButton) {
        self.sendSelectedUsersAndCalendars()
    }
    //TODO: test
    override func readAllAvailableCalendars() -> [UserCalendarType] {
        var userCalendarTypes: [UserCalendarType] = []
        let availableCalendars = DatabasePlanItCalendar().readAllPlanitCalendars()
        let usersAndMiPlanItCalendars = availableCalendars.filter({ return $0.isOwnersCalendar() })
        let groupedCalendar = Dictionary(grouping: usersAndMiPlanItCalendars, by: { $0.readValueOfCalendarType() + Strings.hyphen + $0.readValueOfCalendarTypeLabel() })
        userCalendarTypes = groupedCalendar.map({ key, values in
            let splittedValues = key.components(separatedBy: Strings.hyphen)
            return UserCalendarType(with: splittedValues.first, title: splittedValues.last, calendars: values, selectedCalendars: self.selectedCalendars)
        })
        let disabledCalendars = availableCalendars.filter({ return $0.calendarType != 0 && $0.createdBy?.readValueOfUserId() != Session.shared.readUserId() })
        if !disabledCalendars.isEmpty {
            self.allDisabledCalendars = disabledCalendars.map({ return UserCalendarVisibility(with: $0, isDisabled: true) })
        }
        return userCalendarTypes
    }
    
    override func readAllOtherUserCalendars() -> [CalendarUser] {
        let nonOwnerCalendars = self.selectedCalendars.filter({ return !$0.isOwnersCalendar() && $0.calendarType == 0 })
        let parentCalendarSelected = self.selectedCalendars.contains(where: { $0.parentCalendarId == 0 && $0.isOwnersCalendar() })
        self.selectedCalendars.removeAll(where: { return !$0.isOwnersCalendar() && $0.calendarType == 0 })
        if !parentCalendarSelected {
            self.selectedUsers += nonOwnerCalendars.map({ CalendarUser($0) })
        }
        let availableCalendars = DatabasePlanItCalendar().readAllPlanitCalendars()
        let usersAndMiPlanItCalendars = availableCalendars.filter({ return !$0.isOwnersCalendar() && $0.calendarType == 0 })
        return usersAndMiPlanItCalendars.map({ return CalendarUser($0, disabled: parentCalendarSelected) })
    }
    
    override func updateUserCalendarDisabledFlag(_ flag: Bool) {
        self.allUsers.forEach({ $0.updateDisabledFlag(with: flag) })
        self.selectedUsers.removeAll(where: { $0.isSharedMiPlanItCalendar() })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        switch segue.destination {
        case is AddCalendarViewController:
            if let planItCalendar = sender as? PlanItCalendar {
                let addCalendarViewController = segue.destination as! AddCalendarViewController
                addCalendarViewController.delegate = self
                addCalendarViewController.calendar = NewCalendar(planItCalendar: planItCalendar)
            }
        
        case is ShareMiPlaniTCalendarViewController:
            let shareMiPlaniTCalendarViewController = segue.destination as! ShareMiPlaniTCalendarViewController
            if let index = sender as? IndexPath {
                shareMiPlaniTCalendarViewController.selectedCalendarIndex = index
                shareMiPlaniTCalendarViewController.delegateShare = self
                shareMiPlaniTCalendarViewController.calendar.allUsers = selectedCalendars[index.row].readAllCalendarSharedUser().map({ CalendarUser($0) })
                if shareMiPlaniTCalendarViewController.calendar.allUsers.count != 0 {
                    shareMiPlaniTCalendarViewController.calendar.fullAccesUsers = shareMiPlaniTCalendarViewController.calendar.allUsers.filter({ $0.visibility == 0 })
                    shareMiPlaniTCalendarViewController.calendar.partailAccesUsers = shareMiPlaniTCalendarViewController.calendar.allUsers.filter({ $0.visibility == 1 })
                }
            }
        case is SharedViewController:
            let sharedViewController = segue.destination as! SharedViewController
            if let (calendar, calendarUsers) = sender as? (PlanItCalendar, [CalendarUser]) {
                let categoryOwnerUser = calendarUsers.filter({ $0.userId == calendar.createdBy?.readValueOfUserId() }).first
                let sharedUsers = calendarUsers.sorted { (user1, user2) -> Bool in
                    user1.userId == categoryOwnerUser?.userId
                }
                sharedViewController.categoryOwnerId = categoryOwnerUser?.userId
                sharedViewController.selectedInvitees = sharedUsers
            }
        default:
            break
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        switch indexPath.section {
        case 0..<self.userCalendarTypes.count:
            return self.userCalendarTypes[indexPath.section].calendars[indexPath.row].calendar.isOwnersCalendar()
        default:
            switch indexPath.section {
            case self.userCalendarTypes.count where !self.showingUsers.isEmpty:
                return true
            case self.userCalendarTypes.count + (self.showingUsers.isEmpty ? 0 : 1) where !self.showingDisabledCalendars.isEmpty:
                return true
            default:
                return false
            }
        }
    }
    //TODO: Swipe Control
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        switch indexPath.section {
        case 0..<self.userCalendarTypes.count:
            let deleteAction = UIContextualAction(style: .normal, title:  "", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
                self.deleteCalendar(self.userCalendarTypes[indexPath.section].calendars[indexPath.row].calendar, indexPath: indexPath)
                success(true)
            })
            deleteAction.image = #imageLiteral(resourceName: "icon-cell-swipe-delete")
            deleteAction.backgroundColor = UIColor.init(red: 241/255.0, green: 101/255.0, blue: 101/255.0, alpha: 1.0)
            if self.userCalendarTypes[indexPath.section].calendars[indexPath.row].calendar.parentCalendarId != 0.0 {
                return UISwipeActionsConfiguration(actions: [deleteAction])
            }
            return UISwipeActionsConfiguration()
            
        case self.userCalendarTypes.count + (self.showingUsers.isEmpty ? 0 : 1) where !self.showingDisabledCalendars.isEmpty:
            self.showingDisabledCalendars.count
            print(self.showingDisabledCalendars.count)
            let deleteAction = UIContextualAction(style: .normal, title:  "", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
                self.deleteShareCalendar(self.showingDisabledCalendars[indexPath.row].calendar, indexPath: indexPath)
                success(true)
            })
            deleteAction.image = #imageLiteral(resourceName: "icon-cell-swipe-delete")
            deleteAction.backgroundColor = UIColor.init(red: 241/255.0, green: 101/255.0, blue: 101/255.0, alpha: 1.0)
            
            return UISwipeActionsConfiguration(actions: [deleteAction])

        default:
            //TODO: delete Calendar
//            if self.showingUsers[indexPath.section].planItCalendarShared?.isNotifyCalendar() == true{
//                return UISwipeActionsConfiguration()
//
//            }else{
                let deleteAction = UIContextualAction(style: .normal, title:  "", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in

                    if self.showingUsers[indexPath.row].planItCalendarShared == nil{
                        self.showAlertWithAction(message: Message.deleteShareCalendar(""), title: Message.confirm, items: [Message.yes, Message.no], callback: { index in
                            if index == 0 {
                                self.deleteDefaultShareCalendar(self.showingUsers[indexPath.row].calendarId) { status, message in
                                    if status {
                                        self.buttonDone.stopAnimation(animationStyle: .normal, revertAfterDelay: 0) {
                                            self.navigationController?.popViewController(animated: true)
                                        }
                                    }
                                }
                            }
                        })
                    }else{
                        self.deleteShareCalendar(self.showingUsers[indexPath.row].planItCalendarShared!, indexPath: indexPath) // shared calendar delet working
                    }
//                    self.deleteShareCalendar(self.showingUsers[indexPath.row].planItCalendarShared!, indexPath: indexPath)
//                    success(true)
//                    self.deleteShareCalendar12(String(self.showingUsers[indexPath.row].calendarId))
    //                userCalendarTypes[indexPath.section].calendars[indexPath.row].calendar
                })
                deleteAction.image = #imageLiteral(resourceName: "icon-cell-swipe-delete")
                deleteAction.backgroundColor = UIColor.init(red: 241/255.0, green: 101/255.0, blue: 101/255.0, alpha: 1.0)
    //            if self.userCalendarTypes[indexPath.section].calendars[indexPath.row].calendar.parentCalendarId != 0.0 {
                    return UISwipeActionsConfiguration(actions: [deleteAction])
//            }

//            }
        }
    }
    
    func deleteDefaultShareCalendar(_ calendarId: Int, callback: @escaping (Bool, String?) -> ()) {
            self.buttonDone.startAnimation()

        let calendarCommand = CalendarCommand()
        calendarCommand.deleteSharedCalendar(["userId": Session.shared.readUserId(), "calendarId": calendarId,"cal_type":""]) { (response, error) in
            if let status = response, status {
                callback(true, nil)
            }
            else {
                callback(false, error ?? Message.unknownError)
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        switch indexPath.section {
        case 0..<self.userCalendarTypes.count:
            let shareAction = UIContextualAction(style: .normal, title:  "", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
                self.performSegue(withIdentifier: Segues.toShareCalendar, sender: indexPath)
                success(true)
            })
            shareAction.image = #imageLiteral(resourceName: "icon-cell-swipe-share")
            shareAction.backgroundColor = UIColor.init(red: 86/255.0, green: 173/255.0, blue: 189/255.0, alpha: 1.0)
            
            let editAction = UIContextualAction(style: .normal, title:  "", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
                self.performSegue(withIdentifier: Segues.toEditCalendar, sender: [self.userCalendarTypes[indexPath.section].calendars[indexPath.row].calendar].first)
                success(true)
            })
            editAction.image = #imageLiteral(resourceName: "icon-cell-swipe-edit")
            editAction.backgroundColor = UIColor.init(red: 90/255.0, green: 110/255.0, blue: 206/255.0, alpha: 1.0)
            if self.userCalendarTypes[indexPath.section].calendars[indexPath.row].calendar.parentCalendarId == 0.0 {
                return UISwipeActionsConfiguration(actions: [shareAction])
            }
            return UISwipeActionsConfiguration(actions: [editAction])
        default:
            return UISwipeActionsConfiguration()
        }
    }
    
    func deleteCalendar(_ calendar: PlanItCalendar, indexPath: IndexPath) {
        self.showAlertWithAction(message: Message.deleteCalendar(calendar.readValueOfCalendarName()), title: Message.confirm, items: [Message.yes, Message.no], callback: { index in
            if index == 0 {
                self.saveCalendarDeleteToServerUsingNetwotk(calendar, index: indexPath)
            }
        })
    }
    func deleteShareCalendar(_ calendar: PlanItCalendar, indexPath: IndexPath) {
        self.showAlertWithAction(message: Message.deleteCalendar(calendar.readValueOfCalendarName()), title: Message.confirm, items: [Message.yes, Message.no], callback: { index in
            if index == 0 {
                self.saveSharedCalendarDeleteToServerUsingNetwotk(calendar, index: indexPath)
            }
        })
    }

    //CRASH: Remove
    func createWebServiceToDeleteCalendar(_ calendar: PlanItCalendar, index: IndexPath) {
        self.buttonDone.startAnimation()
        CalendarService().deleteCalendar(calendar) { (status, error) in
            if status {
                self.buttonDone.stopAnimation(animationStyle: .normal, revertAfterDelay: 0) {
//                    self.refreshCalendarAfterDelete(calendar, index: index)
                    self.navigationController?.popViewController(animated: true)
                }
            }
            else {
                self.buttonDone.stopAnimation(animationStyle: .shake, revertAfterDelay: 0) {
                    let message = error ?? Message.unknownError
                    self.performSegue(withIdentifier: Segues.toMessageScreen, sender: [Message.error, message])
                }
            }
        }
    }
    func createWebServiceToDeleteSharedCalendar(_ calendar: PlanItCalendar, index: IndexPath) {
        self.buttonDone.startAnimation()
        CalendarService().deleteShareCalendar(calendar) { (status, error) in
            if status {
                self.buttonDone.stopAnimation(animationStyle: .normal, revertAfterDelay: 0) {
//                    self.refreshCalendarAfterDelete(calendar, index: index)
                    self.navigationController?.popViewController(animated: true)
                }
            }
            else {
                self.buttonDone.stopAnimation(animationStyle: .shake, revertAfterDelay: 0) {
                    let message = error ?? Message.unknownError
                    self.performSegue(withIdentifier: Segues.toMessageScreen, sender: [Message.error, message])
                }
            }
        }
    }
    
    func refreshCalendarAfterDelete(_ calendar: PlanItCalendar, index: IndexPath) {
        self.deletedCalendars.append(calendar)
        if let mainIndex = self.userAvailableCalendarTypes.firstIndex(where: { return $0.type == self.userCalendarTypes[index.section].type }) {
            self.userAvailableCalendarTypes[mainIndex].calendars.removeAll(where: { return $0.calendar == calendar })
            if self.userAvailableCalendarTypes[mainIndex].calendars.isEmpty {
                self.userAvailableCalendarTypes.remove(at: mainIndex)
            }
        }
        self.userCalendarTypes[index.section].calendars.removeAll(where: { return $0.calendar == calendar })
        if self.userCalendarTypes[index.section].calendars.isEmpty {
            self.userCalendarTypes.remove(at: index.section)
        }
        self.tableView.reloadData()
    }
}
