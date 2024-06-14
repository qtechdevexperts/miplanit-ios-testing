//
//  CalanderDropDownListViewController+List.swift
//  MiPlanIt
//
//  Created by Febin Paul on 10/06/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation
import UIKit

extension CalanderDropDownBaseListViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.userCalendarTypes.count + (self.showingUsers.isEmpty ? 0 : 1) + (self.showingDisabledCalendars.isEmpty ? 0 : 1)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0..<self.userCalendarTypes.count:
            return self.userCalendarTypes[section].calendars.count
        case self.userCalendarTypes.count where !self.showingUsers.isEmpty:
            return self.showingUsers.count
        case self.userCalendarTypes.count + (self.showingUsers.isEmpty ? 0 : 1) where !self.showingDisabledCalendars.isEmpty:
            return self.showingDisabledCalendars.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0..<self.userCalendarTypes.count:
            let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.dropDownCellCalendar, for: indexPath) as! CalendarTableViewCell
            cell.configureCell(item: self.userCalendarTypes[indexPath.section].calendars[indexPath.row], indexPath: indexPath, calendarType: self.userCalendarTypes[indexPath.section].type, delegate: self)
            return cell
        case self.userCalendarTypes.count where !self.showingUsers.isEmpty:
            if self.showingUsers[indexPath.row].isSharedMiPlanItCalendar() {
                let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.dropDownCellCalendar, for: indexPath) as! CalendarTableViewCell
                let isSelected = self.selectedUsers.contains(where: { (user) -> Bool in
                    return user.planItCalendarShared == self.showingUsers[indexPath.row].planItCalendarShared
                })
                cell.configureCell(item: self.showingUsers[indexPath.row], isSelected: isSelected, indexPath: indexPath, delegate: self)
                return cell
            }
            else {
                let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.userCellCalendar, for: indexPath) as! UserTableViewCell
                cell.configureCell(item: self.showingUsers[indexPath.row], indexPath: indexPath, isSelected: self.selectedUsers.contains(where: { (user) -> Bool in
                    return user.userId == self.showingUsers[indexPath.row].userId
                }))
                return cell
            }
        case self.userCalendarTypes.count + (self.showingUsers.isEmpty ? 0 : 1) where !self.showingDisabledCalendars.isEmpty:
            let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.notifiedCellCalendar, for: indexPath) as! NotifiedCalendarTableViewCell
            cell.configureCell(item: self.showingDisabledCalendars[indexPath.row], indexPath: indexPath, delegate: self)
            self.imageViewNoResult?.isHidden = true
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0..<self.userCalendarTypes.count:
            let visibleCalendar = self.userCalendarTypes[indexPath.section].calendars[indexPath.row]
            if visibleCalendar.calendar.parentCalendarId != 0 && visibleCalendar.disabled && self.isFromEvent == .allCalendar { return }
            switch self.isFromEvent {
            case .eventCalendar:
                self.userAvailableCalendarTypes.forEach({ calendar in calendar.calendars.forEach({ $0.selected = false })})
            case .allCalendar:
                if visibleCalendar.calendar.parentCalendarId == 0 {
                    self.updateUserCalendarDisabledFlag(!visibleCalendar.selected)
                    self.userAvailableCalendarTypes.forEach({ calendar in calendar.calendars.forEach({
                        if $0.calendar.parentCalendarId == 0 {
                            $0.disabled = !visibleCalendar.selected
                        }
                        else {
                            $0.selected = false
                            $0.disabled = !visibleCalendar.selected
                        }
                    })})
                }
                else {
                    self.userAvailableCalendarTypes.forEach({ calendar in calendar.calendars.forEach({ if $0.calendar.parentCalendarId == 0 { $0.selected = false; $0.disabled = false } else { $0.disabled = false } })})
                }
            default: break
            }
            visibleCalendar.selected = !visibleCalendar.selected
        case self.userCalendarTypes.count where !self.showingUsers.isEmpty:
            guard !self.showingUsers[indexPath.row].isDisabled else { return }
            if let index = self.selectedUsers.firstIndex(of: self.showingUsers[indexPath.row]) {
                 self.selectedUsers.remove(at: index)
            }
            else {
                self.selectedUsers.append(self.showingUsers[indexPath.row])
            }
        default: break
        }
        self.tableView.reloadData()
    }
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.cellCalendarHeader) as! UserCalendarHeaderCell
        switch section {
        case 0..<self.userCalendarTypes.count:
            cell.configureHeader(self.userCalendarTypes[section], at: section, callback: self)
        case self.userCalendarTypes.count where !self.showingUsers.isEmpty:
            let userCalendarType = UserCalendarType.init(with:"4", title: "(Shared)", synced: false, calendars: [])
            cell.configureHeader(userCalendarType, at: section, callback: self)
        case self.userCalendarTypes.count + (self.showingUsers.isEmpty ? 0 : 1) where !self.showingDisabledCalendars.isEmpty:
            let userCalendarType = UserCalendarType.init(with:"5", title: "Shared for notifying events", synced: false, calendars: [])
            cell.configureHeader(userCalendarType, at: section, callback: self)
        default: break
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView.init(frame: CGRect.init(x: 0, y: 0, width: self.tableView.frame.size.width, height: 10))
        view.backgroundColor = UIColor(red: 245/255.0, green: 245/255.0, blue: 245/255.0, alpha: 0.3)
        return view
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        var totalCount = self.userCalendarTypes.count
        totalCount += !self.showingUsers.isEmpty ? 1 : 0
        totalCount += !self.showingDisabledCalendars.isEmpty ? 1: 0
        return section < totalCount - 1 ? 10.0 : 0
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        return UISwipeActionsConfiguration()
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        return UISwipeActionsConfiguration()
    }

}

extension CalanderDropDownBaseListViewController: CalendarTableViewCellDelegate {
    
    func calendarTableViewCell(_ userTableViewCell: CalendarTableViewCell, sharedUserClicked users: [CalendarUser], planItCalendar: PlanItCalendar) {
        self.performSegue(withIdentifier: Segues.toSharedUsers, sender: (planItCalendar, users))
    }
}

extension CalanderDropDownBaseListViewController: NotifiedCalendarTableViewCellDelegate {
    
    func notifiedCalendarTableViewCell(_ userTableViewCell: NotifiedCalendarTableViewCell, sharedUserClicked users: [CalendarUser], planItCalendar: PlanItCalendar) {
        self.performSegue(withIdentifier: Segues.toSharedUsers, sender: (planItCalendar, users))
    }
}

