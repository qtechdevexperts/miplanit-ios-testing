//
//  CreateDashboardViewController+Callback.swift
//  MiPlanIt
//
//  Created by Febin Paul on 24/11/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

extension CreateDashboardViewController: CustomDashboardTagCollectionViewCellDelegate {
    
    func customDashboardTagCollectionViewCell(_ customDashboardTagCollectionViewCell: CustomDashboardTagCollectionViewCell, select status: Bool) {
        self.buttonSelectAll.isSelected = self.showAddedTags.filter({ !$0.isSelected }).isEmpty
        self.collectionViewTags.reloadData()
    }
}

extension CreateDashboardViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
