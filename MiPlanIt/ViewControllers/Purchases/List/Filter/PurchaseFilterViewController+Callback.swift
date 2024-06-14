//
//  PurchaseFilterViewController+Callback.swift
//  MiPlanIt
//
//  Created by Aneesh Asokan on 10/05/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation
extension PurchaseFilterViewController : PurchaseFilterDropDownViewControllerDelegate {
    func purchaseFilterDropDownViewController(_ controller: PurchaseFilterDropDownViewController, selectedOption: DropDownItem) {
        switch self.selectedButtonTag {
        case 1:
            txtfldProductName.dropDownInput = true
            txtfldProductName.text = selectedOption.title
        case 2:
            txtfldStoreName.dropDownInput = true
            txtfldStoreName.text = selectedOption.title
        case 3:
            txtfldPaymentType.dropDownInput = true
            txtfldPaymentType.text = selectedOption.title
        case 4:
            txtfldAddress.dropDownInput = true
            txtfldAddress.text = selectedOption.title
        default:
            break
        }
    }

}
