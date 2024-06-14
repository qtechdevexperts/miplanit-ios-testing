//
//  UserCalendarListViewController+Action.swift
//  MiPlanIt
//
//  Created by Febin Paul on 05/08/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation


extension UserCalendarListViewController {
    
    func startLoadingIndicator(at indexPath: IndexPath) {
        if let cell = self.tableView.cellForRow(at: indexPath) as? CalendarTableViewCell {
            cell.startGradientAnimation()
        }
    }
    
    func stopLoadingIndicator(at indexPath: IndexPath) {
        if let cell = self.tableView.cellForRow(at: indexPath) as? CalendarTableViewCell {
            cell.stopGradientAnimation()
        }
    }
    
    func initializeView() {
        self.lottieAnimationView.backgroundBehavior = .pauseAndRestore
        self.constraintSearchHeight.constant = 0.0
        self.buttonSearch.isHidden = true
        self.txtfldSearch.isHidden = true
        self.viewSearchBarContainer?.isHidden = true
        self.setLoaderSetDotLoader()
    }
    
    func setCalendarUsers() {
         self.allUsers = self.readAllOtherUserCalendars()
    }
    
    func setLoaderSetDotLoader() {
        Session.shared.readUsersCalendarOnlyDataFetching() ? self.dotLoader?.startAnimating() : self.dotLoader?.stopAnimating()
        self.viewLoadingGradient.isHidden = !Session.shared.readUsersCalendarOnlyDataFetching()
    }
    
    func addObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(usersCalendarOnlyDataFetched), name: NSNotification.Name(rawValue: Notifications.usersCalendarOnlyDataFetched), object: nil)
    }
    
    func removeObserver() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: Notifications.usersCalendarOnlyDataFetched), object: nil)
    }
    
    @objc func usersCalendarOnlyDataFetched() {
        DispatchQueue.main.asyncAfter(deadline: .now()+0.5) { [weak self] in
            guard let self = self else { return }
            self.dotLoader?.stopAnimating()
            self.viewLoadingGradient.isHidden = true
            let getUserCalendarAvailableType = self.getUserCalendarAvailableType()
            // set the disabled and selected flag
            let allUserAvailableCalendarTypes = self.userAvailableCalendarTypes.compactMap({ $0.calendars }).flatMap({ $0 })
            getUserCalendarAvailableType.compactMap({ $0.calendars }).flatMap({ $0 }).forEach { (eachGetUserCalendarVisibility) in
                if let filteredCalendar = allUserAvailableCalendarTypes.filter({ $0.calendar == eachGetUserCalendarVisibility.calendar }).first {
                    eachGetUserCalendarVisibility.disabled = filteredCalendar.disabled
                    eachGetUserCalendarVisibility.selected = filteredCalendar.selected
                }
            }
            self.userAvailableCalendarTypes = getUserCalendarAvailableType
            self.userCalendarTypes = self.userAvailableCalendarTypes
            self.tableView.reloadData()
        }
    }
    
    func startLottieAnimations() {
        self.viewFetchingData.isHidden = false
        self.lottieAnimationView.play(fromProgress: 0, toProgress: 0.1, loopMode: .loop, completion: nil)
    }
    
    func stopLottieAnimations() {
        self.viewFetchingData.isHidden = true
        if self.lottieAnimationView.isAnimationPlaying { self.lottieAnimationView.stop() }
    }
    
    func sendSelectedUsersAndCalendars() {
        let usersSelected = self.selectedUsers.filter({ return !$0.isSharedMiPlanItCalendar() })
        if !usersSelected.isEmpty {
            self.createWebServiceForFetchUserEvents(usersSelected)
        }
        else {
            self.updatedCalendars.removeAll()
            let usersCalendar = self.selectedUsers.filter({ return $0.isSharedMiPlanItCalendar() }).compactMap({ $0.planItCalendarShared })
            let selectedOptions = self.userAvailableCalendarTypes.flatMap({ return $0.calendars }).filter({ return $0.selected }).map({ return $0.calendar })
            self.navigationController?.popViewController(animated: true)
            self.delegate?.calendarListViewController(self, selectedOptions: selectedOptions + usersCalendar, selectedUsers: [])
        }
    }
    
    func toggleSearch() {
        self.imageViewNoResult?.isHidden = true
        self.constraintSearchHeight.constant = self.constraintSearchHeight.constant == 0.0 ? 45.0 : 0.0
        self.txtfldSearch.isHidden = self.constraintSearchHeight.constant == 0.0
        self.viewSearchBarContainer?.isHidden = self.constraintSearchHeight.constant == 0.0
        if self.constraintSearchHeight.constant == 0.0 {
            self.txtfldSearch.text = Strings.empty
            self.txtfldSearch.resignFirstResponder()
            self.userCalendarTypes = self.userAvailableCalendarTypes
            self.tableView.reloadData()
        }
        else {
            self.txtfldSearch.becomeFirstResponder()
        }
    }
    
    func updateCalendar(calendar: PlanItCalendar) {
        if !self.updatedCalendars.contains(calendar) { self.updatedCalendars.append(calendar) }
        self.tableView.reloadData()
    }
}
