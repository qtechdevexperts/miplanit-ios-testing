//
//  GiftFilterViewController+Callback.swift
//  MiPlanIt
//
//  Created by Aneesh Asokan on 10/05/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation
extension GiftFilterViewController: FilterDropDownViewControllerDelegate {
    func filterDropDownViewController(_ controller: FilterDropDownViewController, selectedOption: DropDownItem) {
        switch self.selectedButtonTag {
        case 1:
            txtfldCouponName.dropDownInput = true
            txtfldCouponName.text = selectedOption.title
        case 2:
            txtfldCouponCode.dropDownInput = true
            txtfldCouponCode.text = selectedOption.title
        case 3:
            txtfldCouponID.dropDownInput = true
            txtfldCouponID.text = selectedOption.title
        case 4:
            txtfldIssuedBy.dropDownInput = true
            txtfldIssuedBy.text = selectedOption.title
        case 5:
            txtfldReceivedFrom.dropDownInput = true
            txtfldReceivedFrom.text = selectedOption.title
        default:
            break
        }
    }
}
