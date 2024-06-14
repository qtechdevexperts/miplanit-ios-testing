//
//  CalendarListBaseViewController+List.swift
//  MiPlanIt
//
//  Created by Arun on 09/04/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit

extension CalendarListBaseViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.calanderList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.cell, for: indexPath) as! CalanderNameCell
        cell.configure(calander: self.calanderList[indexPath.row], indexPath: indexPath, callBack: self)
        return cell
    }
}
