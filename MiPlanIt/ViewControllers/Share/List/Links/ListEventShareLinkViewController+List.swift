//
//  ListEventShareLinkViewController+List.swift
//  MiPlanIt
//
//  Created by Febin Paul on 29/03/21.
//  Copyright © 2021 Arun. All rights reserved.
//

import Foundation

extension ListEventShareLinkViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.showShareListLists.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.eventShareLinkCell, for: indexPath) as! EventShareLinkTableViewCell
        cell.configCell(self.showShareListLists[indexPath.row], delegate: self, index: indexPath)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.showShareLinkDetail(on: indexPath)
    }
}
