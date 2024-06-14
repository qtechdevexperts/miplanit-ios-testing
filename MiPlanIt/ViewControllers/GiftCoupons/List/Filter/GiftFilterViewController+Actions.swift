//
//  GiftFilterViewController+Actions.swift
//  MiPlanIt
//
//  Created by Aneesh Asokan on 10/05/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

extension GiftFilterViewController {
    
    
    func updateExistingFilters() {
        self.selectedFilters.forEach { (filter) in
            switch filter.fieldName {
                case .eCouponName:
                    txtfldCouponName.text = filter.fieldValue
                case .eCouponCode:
                    txtfldCouponCode.text = filter.fieldValue
                case .eCouponID:
                    txtfldCouponID.text = filter.fieldValue
                case .eIssuedBy:
                    txtfldIssuedBy.text = filter.fieldValue
                case .eReceivedFrom:
                    txtfldReceivedFrom.text = filter.fieldValue
            default:
                break
            }
        }
        self.selectedFilters.removeAll()
    }
    
    func getFiltersFromTextFields() -> [Filter]{
        if let couponName = self.txtfldCouponName.text?.trimmingCharacters(in: .whitespacesAndNewlines), couponName.length > 0
        {
            selectedFilters.append(Filter(with: .eCouponName, value: couponName, type: txtfldCouponName.dropDownInput == true ? 1 : 0))
        }
        if let couponCode = txtfldCouponCode.text?.trimmingCharacters(in: .whitespacesAndNewlines), couponCode.length > 0
        {
            selectedFilters.append(Filter(with: .eCouponCode, value: couponCode, type: txtfldCouponCode.dropDownInput == true ? 1 : 0))
        }
        if let couponId = txtfldCouponID.text?.trimmingCharacters(in: .whitespacesAndNewlines), couponId.length > 0
        {
            selectedFilters.append(Filter(with: .eCouponID, value: couponId, type: txtfldCouponID.dropDownInput == true ? 1 : 0))
        }
        if let recievedFrom = txtfldReceivedFrom.text?.trimmingCharacters(in: .whitespacesAndNewlines), recievedFrom.length > 0
        {
            selectedFilters.append(Filter(with: .eReceivedFrom, value: recievedFrom, type: txtfldReceivedFrom.dropDownInput == true ? 1 : 0))
        }
        if let issuedBy = txtfldIssuedBy.text?.trimmingCharacters(in: .whitespacesAndNewlines), issuedBy.length > 0
        {
            selectedFilters.append(Filter(with: .eIssuedBy, value: issuedBy, type: txtfldIssuedBy.dropDownInput == true ? 1 : 0))
        }
        return selectedFilters
    }
    
    func getValuesForDropDown(sender: UIButton) -> [DropDownItem]{
        switch self.selectedButtonTag {
        case 1:
            var duplicateRecords: [String] = []
            return self.giftCoupons.compactMap({ if duplicateRecords.contains($0.readCouponName()) || $0.readCouponName().isEmpty { return nil } else { duplicateRecords.append($0.readCouponName()); return DropDownItem(name: $0.readCouponName(), type: DropDownOptionType.eDefault) } })
        case 2:
            var duplicateRecords: [String] = []
            return self.giftCoupons.compactMap({ if duplicateRecords.contains($0.readCouponCode()) || $0.readCouponCode().isEmpty { return nil } else { duplicateRecords.append($0.readCouponCode()); return DropDownItem(name: $0.readCouponCode(), type: DropDownOptionType.eDefault) } })
        case 3:
            var duplicateRecords: [String] = []
            return self.giftCoupons.compactMap({ if duplicateRecords.contains($0.readCouponID()) || $0.readCouponID().isEmpty { return nil } else { duplicateRecords.append($0.readCouponID()); return DropDownItem(name: $0.readCouponID(), type: DropDownOptionType.eDefault) } })
        case 4:
            var duplicateRecords: [String] = []
            return self.giftCoupons.compactMap({ if duplicateRecords.contains($0.readIssuedBy()) || $0.readIssuedBy().isEmpty { return nil } else { duplicateRecords.append($0.readIssuedBy()); return DropDownItem(name: $0.readIssuedBy(), type: DropDownOptionType.eDefault) } })
        case 5:
            var duplicateRecords: [String] = []
            return self.giftCoupons.compactMap({ if duplicateRecords.contains($0.readReceivedFrom()) || $0.readReceivedFrom().isEmpty { return nil } else { duplicateRecords.append($0.readReceivedFrom()); return DropDownItem(name: $0.readReceivedFrom(), type: DropDownOptionType.eDefault) } })
        default:
            break
        }
        return []
    }
    
    func updateResetButtonStatus() {
        self.buttonResetFilter.isSelected = self.selectedFilters.count != 0
        self.buttonResetFilter.backgroundColor = self.selectedFilters.count == 0 ? UIColor.clear : UIColor(red: 86/255.0, green: 173/255.0, blue: 189/255.0, alpha: 1.0)
    }
    
}
