//
//  ReOrderCategoryViewController+Action.swift
//  MiPlanIt
//
//  Created by Febin Paul on 28/04/21.
//  Copyright © 2021 Arun. All rights reserved.
//

import Foundation

extension ReOrderCategoryViewController {
    
    func initializeUI() {
        self.tableView.isEditing = true
    }
    
    func showOrHideDropDownOptions(_ show: Bool) {
        self.bottomDropDownConstraints.constant = show ? 0 : -500
        self.view.setNeedsUpdateConstraints()
        UIView.animate(withDuration: 0.25) {
            self.view.layoutIfNeeded()
        }
    }
}
