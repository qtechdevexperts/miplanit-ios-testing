//
//  ViewCalendarDetailViewController+List.swift
//  MiPlanIt
//
//  Created by Febin Paul on 20/08/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

extension ViewCalendarDetailViewController: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? self.calendar.fullAccesUsers.count : self.calendar.partailAccesUsers.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return self.calendar.fullAccesUsers.isEmpty ? 70 : 20
        }
        else {
            return self.calendar.partailAccesUsers.isEmpty ? 70 : 20
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 20
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier:CellIdentifier.calendarInvitiesCell) as! CalendarInvitiesCell
        cell.configure(indexPath.section == 0 ? self.calendar.fullAccesUsers[indexPath.row] : self.calendar.partailAccesUsers[indexPath.row], indexPath: indexPath, callBack: self)
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.cellUserHeader) as! CalendarInviteHeaderCell
        cell.labelHeader.text = section == 0 ? Strings.fullAccess : Strings.particalAccess
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footer = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 0))
        footer.backgroundColor = UIColor.clear
        return footer
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }
    
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
}

