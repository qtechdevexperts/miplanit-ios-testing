//
//  PurchaseViewController+Actions.swift
//  MiPlanIt
//
//  Created by Aneesh Asokan on 29/04/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

extension GiftCouponsViewController {
    
    func initialUIComponents() {
        self.viewCouponStatusSelection.delegate = self
        self.constraintSearchViewHeight.constant = 0
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
//                self.viewCouponStatusSelection.collectionView.scrollToItem(at: IndexPath(item: 1, section: 0), at: .left, animated: true)
//        }
        self.refreshControl.tintColor = UIColor.white
        self.refreshControl.attributedTitle = NSAttributedString(string: "")
        self.refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        self.tableViewGiftCouponsList.addSubview(refreshControl)
    }
    
    
    @objc func refresh(_ sender: AnyObject) {
        self.createServiceToFetchUsersData()
    }
    
    func updateSearchHeight(sender: UIButton) {
        UIView.animate(withDuration: 0.5) {
            self.constraintSearchViewHeight.constant = self.constraintSearchViewHeight.constant == 45 ? 0 : 45
        }
    }
    
    func readAllUserGiftCouponsUsingFilterCriteria() {
        self.allGiftCoupons = DatabasePlanItGiftCoupon().readAllGiftCouponsList()
    }
    
    func readUserGiftCouponWithCategory() -> [PlanItGiftCoupon] {
        switch self.selectedCategory {
        case .active:
            return self.allGiftCoupons.filter { (giftCoupon) -> Bool in
                if !giftCoupon.readExpiryDate().isEmpty, giftCoupon.readExpiryDate().checkExpiry() != "Expired" && giftCoupon.readRedeemDate().isEmpty {
                    return true
                }
                else if giftCoupon.readExpiryDate().isEmpty {
                    return true
                }
                return false
            }
        case .redeemed:
            return self.allGiftCoupons.filter { (giftCoupon) -> Bool in
                if  !giftCoupon.readRedeemDate().isEmpty {
                    return true
                }
                return false
            }
        case .expired:
            return self.allGiftCoupons.filter { (giftCoupon) -> Bool in
                if !giftCoupon.readExpiryDate().isEmpty, giftCoupon.readExpiryDate().checkExpiry() == "Expired" && giftCoupon.readRedeemDate().isEmpty {
                    return true
                }
                return false
            }
        }
    }
    
    func showGiftCouponsBasedOnSearchCriteria() {
        guard let text = self.textFieldSearch.text else { return }
        self.searchGiftCouponsUsingText(text: text, baseArray: self.readUserGiftCouponWithCategory())
    }
    
    func showGiftCouponsBasedOnFilterCriteria(searchText: String = Strings.empty) {
        guard !filterCriteria.isEmpty else { self.userGiftCoupons = self.readUserGiftCouponWithCategory(); return }
        var filteresData = self.readUserGiftCouponWithCategory()
        let nameFilter = filterCriteria.filter{$0.fieldName == .eCouponName}
        if !nameFilter.isEmpty {
            filteresData = filteresData.filter({ return nameFilter[0].fieldType == 0 ? $0.readCouponName().range(of: nameFilter[0].fieldValue, options: .caseInsensitive) != nil : $0.readCouponName() == nameFilter[0].fieldValue})
        }
        let codeFilter = filterCriteria.filter{$0.fieldName == .eCouponCode}
        if !codeFilter.isEmpty {
            filteresData = filteresData.filter({ return codeFilter[0].fieldType == 0 ? $0.readCouponCode().range(of: codeFilter[0].fieldValue, options: .caseInsensitive) != nil : $0.readCouponCode() == codeFilter[0].fieldValue })
        }
        let idFilter = filterCriteria.filter{$0.fieldName == .eCouponID}
        if !idFilter.isEmpty {
            filteresData = filteresData.filter({ return idFilter[0].fieldType == 0 ? $0.readCouponID().range(of: idFilter[0].fieldValue, options: .caseInsensitive) != nil : $0.readCouponID() == idFilter[0].fieldValue})
        }
        let issueFilter = filterCriteria.filter{$0.fieldName == .eIssuedBy}
        if !issueFilter.isEmpty {
            filteresData = filteresData.filter({ return issueFilter[0].fieldType == 0 ? $0.readIssuedBy().range(of: issueFilter[0].fieldValue, options: .caseInsensitive) != nil : $0.readIssuedBy() == issueFilter[0].fieldValue})
        }
        let receiveFilter = filterCriteria.filter{$0.fieldName == .eReceivedFrom}
        if !receiveFilter.isEmpty {
            filteresData = filteresData.filter({ return receiveFilter[0].fieldType == 0 ? $0.readReceivedFrom().range(of: receiveFilter[0].fieldValue, options: .caseInsensitive) != nil : $0.readReceivedFrom() == receiveFilter[0].fieldValue})
        }
        let text = !searchText.isEmpty ? searchText : textFieldSearch.text ?? Strings.empty
        if !text.isEmpty {
            self.searchGiftCouponsUsingText(text: text, baseArray: filteresData)
        }
        else {
            self.userGiftCoupons = filteresData
        }
    }
    
    func searchGiftCouponsUsingText(text: String, baseArray: [PlanItGiftCoupon]) {
        self.buttonSearch.isSelected = !text.isEmpty
        self.buttonClearSearch.isHidden = text.isEmpty
        guard !text.isEmpty else { self.userGiftCoupons = baseArray; return }
        self.userGiftCoupons = baseArray.filter({ return $0.readCouponName().range(of: text, options: .caseInsensitive) != nil || $0.readCouponCode().range(of: text, options: .caseInsensitive) != nil ||
            $0.readCouponID().range(of: text, options: .caseInsensitive) != nil
        })
    }
    
}
