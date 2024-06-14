//
//  UserCalendarListSelectionViewController.swift
//  MiPlanIt
//
//  Created by Febin Paul on 15/04/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation
import UIKit

protocol CalendarListSelectionViewControllerDelegate: AnyObject {
    func calendarListSelectionViewController(_ controller: UserCalendarListSelectionViewController, selectedOptions: [UserCalendarVisibility])
}

class UserCalendarListSelectionViewController: CalanderDropDownBaseListViewController {
    
    var selectedCalendars: [UserCalendarVisibility] = []
    weak var delegate: CalendarListSelectionViewControllerDelegate?
    var switchOnlyMiCalendars: Bool = false
    
    override func doneButtonClicked(_ sender: UIButton) {
        let selectedOptions = self.userAvailableCalendarTypes.flatMap({ return $0.calendars }).filter({ return $0.selected })
        self.delegate?.calendarListSelectionViewController(self, selectedOptions: selectedOptions)
        self.navigationController?.popViewController(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func readAllAvailableCalendars() -> [UserCalendarType] {
        var calendars = DatabasePlanItCalendar().readAllPlanitCalendars().filter({ return $0.canEdit && ($0.calendarType == 0 || ($0.createdBy?.readValueOfUserId() == Session.shared.readUserId() && $0.calendarType != 3)) })
        if self.switchOnlyMiCalendars {
            calendars = calendars.filter({ $0.calendarType == 0.0 })
        }
        let groupedCalendar = Dictionary(grouping: calendars, by: { $0.readValueOfCalendarType() + Strings.hyphen + $0.readValueOfCalendarTypeLabel() })
        return groupedCalendar.map({ key, values in
            let splittedValues = key.components(separatedBy: Strings.hyphen)
            return UserCalendarType(with: splittedValues.first, title: splittedValues.last, calendars: values, selectedCalendars: self.selectedCalendars, visibility: 0)
        })
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.dropDownCellCalendar, for: indexPath) as! SelectCalendarTableViewCell
        cell.configureCell(item: self.userCalendarTypes[indexPath.section].calendars[indexPath.row], indexPath: indexPath, calendarType: self.userCalendarTypes[indexPath.section].type, delegate: self)
        return cell
    }
}


extension UserCalendarListSelectionViewController: SelectCalendarTableViewCellDelegate {
    
    func selectCalendarTableViewCell(_ selectCalendarTableViewCell: SelectCalendarTableViewCell, invitees: [Any]) {
        var users: [CalendarUser] = []
        invitees.forEach { (data) in
            if let invitees = data as? PlanItInvitees {
                users.append(CalendarUser(invitees))
            }
            else if let creator = data as? PlanItCreator {
                users.append(CalendarUser(creator))
            }
            else if let creator = data as? OtherUser {
                users.append(CalendarUser(creator))
            }
        }
        if !users.isEmpty {
            self.performSegue(withIdentifier: Segues.showInviteeStatus, sender: users)
        }
    }
    
}
