//
//  PurchaseFilterViewController+Actions.swift
//  MiPlanIt
//
//  Created by Aneesh Asokan on 10/05/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation
extension PurchaseFilterViewController {
    
    func updateExistingFilters() {
        self.selectedFilters.forEach { (filter) in
            switch filter.fieldName {
                case .eProductName:
                    txtfldProductName.text = filter.fieldValue
                case .eStoreName:
                    txtfldStoreName.text = filter.fieldValue
                case .eAddress:
                    txtfldAddress.text = filter.fieldValue
                case .ePaymentType:
                    txtfldPaymentType.text = filter.fieldValue == "1" ? Strings.card : filter.fieldValue == "2" ? Strings.cash : Strings.other
            default:
                break
            }
        }
        self.selectedFilters.removeAll()
    }
    
    
    func getFiltersFromTextFields() -> [Filter]{
        if let productName = self.txtfldProductName.text?.trimmingCharacters(in: .whitespacesAndNewlines), productName.length > 0
        {
            selectedFilters.append(Filter(with: .eProductName, value: productName, type: txtfldProductName.dropDownInput == true ? 1 : 0))
        }
        if let storeName = txtfldStoreName.text?.trimmingCharacters(in: .whitespacesAndNewlines), storeName.length > 0
        {
            selectedFilters.append(Filter(with: .eStoreName, value: storeName, type: txtfldStoreName.dropDownInput == true ? 1 : 0))
        }
        if let location = txtfldAddress.text?.trimmingCharacters(in: .whitespacesAndNewlines), location.length > 0
        {
            selectedFilters.append(Filter(with: .eAddress, value: location, type: txtfldAddress.dropDownInput == true ? 1 : 0))
        }
        if let paymentType = txtfldPaymentType.text?.trimmingCharacters(in: .whitespacesAndNewlines), paymentType.length > 0
        {
            selectedFilters.append(Filter(with: .ePaymentType, value: paymentType == Strings.cash ? "2" : paymentType == Strings.card ? "1" : "3", type: 1))
        }
        return selectedFilters
    }
    
    func getValuesForDropDown(sender: UIButton) -> [DropDownItem]{
        switch self.selectedButtonTag {
        case 1:
            var duplicateRecords: [String] = []
            return self.purchases.compactMap({
                let productName = $0.readProductName().trimmingCharacters(in: .whitespacesAndNewlines)
                if duplicateRecords.contains(where: { (product) -> Bool in
                    product.lowercased() == productName.lowercased()
                }) || productName.isEmpty { return nil } else { duplicateRecords.append(productName); return DropDownItem(name: productName, type: DropDownOptionType.eDefault) }
            })
        case 2:
            var duplicateRecords: [String] = []
            return self.purchases.compactMap({
                let storeName = $0.readStoreName().trimmingCharacters(in: .whitespacesAndNewlines)
                if duplicateRecords.contains(where: { (store) -> Bool in
                    store.lowercased() == storeName.lowercased()
                }) || storeName.isEmpty { return nil } else { duplicateRecords.append(storeName); return DropDownItem(name: storeName, type: DropDownOptionType.eDefault) }
            })
        case 3:
            return [DropDownItem(name: Strings.cash, identifier: "2", type: DropDownOptionType.eDefault), DropDownItem(name: Strings.card, identifier: "1", type: DropDownOptionType.eDefault), DropDownItem(name: Strings.other, identifier: "3", type: DropDownOptionType.eDefault)]
        case 4:
            var duplicateRecords: [String] = []
            return self.purchases.compactMap({
                let locationName = $0.readLocation().trimmingCharacters(in: .whitespacesAndNewlines)
                if duplicateRecords.contains(where: { (location) -> Bool in
                    location.lowercased() == locationName.lowercased()
                }) || locationName.isEmpty { return nil } else { duplicateRecords.append(locationName); return DropDownItem(name: locationName, type: DropDownOptionType.eDefault) }
            })
        default:
            break
        }
        return []
    }
    
    func updateResetButtonStatus() {
        self.buttonResetFilter.isSelected = self.selectedFilters.count != 0
//        self.buttonResetFilter.backgroundColor = self.selectedFilters.count == 0 ? UIColor.clear : UIColor(red: 86/255.0, green: 173/255.0, blue: 189/255.0, alpha: 1.0)
    }
    
}
