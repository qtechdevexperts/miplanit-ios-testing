//
//  ListEventShareLinkViewController+Callback.swift
//  MiPlanIt
//
//  Created by Febin Paul on 29/03/21.
//  Copyright © 2021 Arun. All rights reserved.
//

import Foundation


extension ListEventShareLinkViewController: EventShareLinkTableViewCellDelegate {
    
    func eventShareLinkTableViewCell(_ EventShareLinkTableViewCell: EventShareLinkTableViewCell, shareLink: PlanItShareLink, onDeleteIndex index: IndexPath) {
        if let cell = self.tableView.cellForRow(at: index) as? EventShareLinkTableViewCell {
            self.deleteShareLinkToServerUsingNetwotk(shareLink, cell: cell)
        }
    }
    
    func eventShareLinkTableViewCell(_ EventShareLinkTableViewCell: EventShareLinkTableViewCell, shareLink: PlanItShareLink, warningItem index: IndexPath) {
        self.showWarningAlertForShareLink(shareLink, onIndex: index)
    }
}


extension ListEventShareLinkViewController: ShareLinkFilterViewControllerDelegate {
    
    func shareLinkFilterViewControllerResetAllOptions(_ viewController: ShareLinkFilterViewController) {
        self.filterCriteria = nil
    }
    
    func shareLinkFilterViewController(_ viewController: ShareLinkFilterViewController, selected option: DropDownItem) {
        self.filterCriteria = option.dropDownType
    }
}

extension ListEventShareLinkViewController: CreateShareLinkViewControllerDelegate {
    
    func createShareLinkViewControllerDataUpdated(_ createShareLinkViewController: CreateShareLinkViewController) {
        self.showListBasedOnFilterCriteria()
    }
}
