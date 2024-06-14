//
//  CalanderDropDownListViewController+SearchTextfield.swift
//  MiPlanIt
//
//  Created by Aneesh Asokan on 15/07/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit

extension CalanderDropDownBaseListViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let searchText = (textField.text as NSString?)?.replacingCharacters(in: range, with: string) ?? Strings.empty
        if searchText.isEmpty {
            self.userCalendarTypes = self.userAvailableCalendarTypes
            self.showingUsers = self.allUsers
            self.showingDisabledCalendars = self.allDisabledCalendars
        }
        else {
            let searchResultUsers = self.allUsers.filter({ if let calendar = $0.planItCalendarShared {  return calendar.readValueOfCalendarName().range(of: searchText, options: .caseInsensitive) != nil || "\($0.name)'s MiPlaniT".range(of: searchText, options: .caseInsensitive) != nil } else { return "\($0.name)'s MiPlaniT".range(of: searchText, options: .caseInsensitive) != nil } })
            self.showingUsers = searchResultUsers
            let calendars = self.userAvailableCalendarTypes.flatMap({ return $0.calendars })
            let searchResult = calendars.filter({ return $0.calendar.readValueOfCalendarName().range(of: searchText, options: .caseInsensitive) != nil})
            let groupedCalendar = Dictionary(grouping: searchResult, by: { $0.calendar.readValueOfCalendarType() + Strings.hyphen + $0.calendar.readValueOfCalendarTypeLabel() })
            self.userCalendarTypes = groupedCalendar.map({ key, values in
                let splittedValues = key.components(separatedBy: Strings.hyphen)
                let type = splittedValues.first ?? Strings.empty
                return UserCalendarType(with: type, title: splittedValues.last, synced: self.userAvailableCalendarTypes.filter({ return $0.type == type}).first?.synced ?? false, calendars: values)
            }).sorted(by: { return $0.type < $1.type })
            
        }
        self.tableView.reloadData()
        self.imageViewNoResult?.isHidden = !self.showingUsers.isEmpty || !self.userCalendarTypes.isEmpty
        return true
    }
}
