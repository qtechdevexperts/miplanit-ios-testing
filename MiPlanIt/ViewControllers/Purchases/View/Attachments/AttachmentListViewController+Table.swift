//
//  AttachmentListViewController+Table.swift
//  MiPlanIt
//
//  Created by Aneesh Asokan on 02/05/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit

extension AttachmentListViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.attachments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.cellAttachments, for: indexPath) as! AttachmentListTableViewCell
        cell.configureAttachment(self.attachments[indexPath.row], activityType: self.activityType, atIndexPath: indexPath, callback: self)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: Segues.toAttachmentDetail, sender: self.attachments[indexPath.row])
    }
}

