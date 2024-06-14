//
//  NotifyCalendarListViewController.swift
//  MiPlanIt
//
//  Created by Aneesh Asokan on 03/08/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation
import UIKit

protocol NotifyCalendarListSelectionViewControllerDelegate: AnyObject {
    func calendarListSelectionViewController(_ controller: NotifyCalendarListViewController, selectedOptions: [UserCalendarVisibility])
}

class NotifyCalendarListViewController: CalanderDropDownBaseListViewController {
    
    var selectedCalendars: [UserCalendarVisibility] = []
    var selectedCalendarForRemoval: [UserCalendarVisibility] = []
    weak var delegate: NotifyCalendarListSelectionViewControllerDelegate?
    
    @IBOutlet weak var viewNoCalendar: UIView?
    
    
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
        let calendars = DatabasePlanItCalendar().readAllPlanitCalendars().filter({ calendar in return calendar.canEdit && calendar.calendarType != 0 && calendar.calendarType != 3 && !self.selectedCalendarForRemoval.contains(where: { return $0.calendar == calendar
        })})
        let groupedCalendar = Dictionary(grouping: calendars, by: { $0.readValueOfCalendarType() + Strings.hyphen + $0.readValueOfCalendarTypeLabel() })
        self.viewNoCalendar?.isHidden = !groupedCalendar.isEmpty
        return groupedCalendar.map({ key, values in
            let splittedValues = key.components(separatedBy: Strings.hyphen)
            return UserCalendarType(with: splittedValues.first, title: splittedValues.last, calendars: values, selectedCalendars: self.selectedCalendars, visibility: 1)
        })
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.dropDownCellCalendar, for: indexPath) as! NotifiyCalendarTableViewCell
        cell.configureCell(item: self.userCalendarTypes[indexPath.section].calendars[indexPath.row], indexPath: indexPath, calendarType: self.userCalendarTypes[indexPath.section].type)
        return cell
    }
}
