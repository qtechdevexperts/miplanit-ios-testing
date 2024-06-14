//
//  PurchaseViewController+Actions.swift
//  MiPlanIt
//
//  Created by Aneesh Asokan on 29/04/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

extension PurchaseViewController {
    
    func initialUIComponents() {
        self.constraintSearchViewHeight.constant = 0
        self.refreshControl.tintColor = UIColor.white
        self.refreshControl.attributedTitle = NSAttributedString(string: "")
        self.refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        self.tableViewPurchasesList.addSubview(refreshControl)
    }
    
    
    @objc func refresh(_ sender: AnyObject) {
        self.createServiceToFetchUsersData()
    }
    
    
    func updateSearchHeight(sender: UIButton) {
        UIView.animate(withDuration: 0.5) {
            self.constraintSearchViewHeight.constant = self.constraintSearchViewHeight.constant == 45 ? 0 : 45
        }
    }
    
    func readAllUserPurchasesUsingFilterCriteria() {
        self.allPurchases = DatabasePlanItPurchase().readAllPurchasList()
    }
    
    func showPurchaseBasedOnSearchCriteria() {
        guard let text = self.textFieldSearch.text else { return }
        self.searchPurchasesUsingText(text:text, baseArray: self.allPurchases)
    }
    
    func showPurchaseBasedOnFilterCriteria(searchText: String = Strings.empty) {
        guard !filterCriteria.isEmpty else { self.userPurchases = self.allPurchases; return }
        var filteresData = self.allPurchases
        let prodFilter = filterCriteria.filter{$0.fieldName == .eProductName}
        if !prodFilter.isEmpty {
            filteresData = filteresData.filter({ return prodFilter[0].fieldType == 0 ? $0.readProductName().range(of: prodFilter[0].fieldValue, options: .caseInsensitive) != nil : $0.readProductName().lowercased().trimmingCharacters(in: .whitespacesAndNewlines) == prodFilter[0].fieldValue.lowercased()})
        }
        let storeFilter = filterCriteria.filter{$0.fieldName == .eStoreName}
        if !storeFilter.isEmpty {
            filteresData = filteresData.filter({ return storeFilter[0].fieldType == 0 ? $0.readStoreName().range(of: storeFilter[0].fieldValue, options: .caseInsensitive) != nil : $0.readStoreName().lowercased().trimmingCharacters(in: .whitespacesAndNewlines) == storeFilter[0].fieldValue.lowercased() })
        }
        let addressFilter = filterCriteria.filter{$0.fieldName == .eAddress}
        if !addressFilter.isEmpty {
            filteresData = filteresData.filter({ return addressFilter[0].fieldType == 0 ? $0.readLocation().range(of: addressFilter[0].fieldValue, options: .caseInsensitive) != nil : $0.readLocation().lowercased().trimmingCharacters(in: .whitespacesAndNewlines) == addressFilter[0].fieldValue.lowercased()})
        }
        let typeFilter = filterCriteria.filter{$0.fieldName == .ePaymentType}
        if !typeFilter.isEmpty {
            filteresData = filteresData.filter({ return $0.readPaymentType() == typeFilter[0].fieldValue})
        }
        let text = !searchText.isEmpty ? searchText : textFieldSearch.text ?? Strings.empty
        if !text.isEmpty {
            self.searchPurchasesUsingText(text: text, baseArray: filteresData)
        }
        else {
            self.userPurchases = filteresData
        }
    }
    func searchPurchasesUsingText(text: String, baseArray: [PlanItPurchase]) {
        self.buttonSearch.isSelected = !text.isEmpty
        self.buttonClearSearch.isHidden = text.isEmpty
        guard !text.isEmpty else { self.userPurchases = baseArray; return }
        self.userPurchases = baseArray.filter({ return $0.readProductName().range(of: text, options: .caseInsensitive) != nil || $0.readStoreName().range(of: text, options: .caseInsensitive) != nil })
    }
}
