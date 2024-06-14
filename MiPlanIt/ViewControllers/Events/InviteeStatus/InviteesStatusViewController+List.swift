//
//  InviteesStatusViewController+List.swift
//  MiPlanIt
//
//  Created by Febin Paul on 16/04/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit

extension InviteesStatusViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.invitees.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.inviteesStatusTableViewCell, for: indexPath) as! InviteesStatusTableViewCell
        cell.configureCell(user: self.invitees[indexPath.row])
        return cell
    }
}
