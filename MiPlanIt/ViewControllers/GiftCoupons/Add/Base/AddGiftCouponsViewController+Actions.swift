//
//  AddPurchaseViewController+Actions.swift
//  MiPlanIt
//
//  Created by Aneesh Asokan on 30/04/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

extension AddGiftCouponsViewController {
    
    func initialiseUIComponents() {
        self.showAttachmentsCount()
        self.showTagsCount()
        if !self.giftCouponModel.couponServerId.isEmpty {
            self.labelHeaderCaption.text = Strings.editGiftCoupon
            self.txtfldCouponName.text = self.giftCouponModel.couponName
            self.txtfldCouponCode.text = self.giftCouponModel.couponCode
            self.txtfldCouponID.text = self.giftCouponModel.couponId
            self.txtfldReceivedFrom.text = self.giftCouponModel.recievedFrom
            self.txtfldAmount.text = "\(self.giftCouponModel.couponAmount)"
            self.txtfldAmount.placeholder = "Amount (\(self.giftCouponModel.currencySymbol))"
            self.buttonCurrencySymbol.setTitle(self.giftCouponModel.currencySymbol, for: .normal)
            self.txtfldIssuedBy.text = self.giftCouponModel.issuedBy
            self.textViewDescription.text = self.giftCouponModel.couponDescription
            if let stringdate = self.giftCouponModel.expiryDate.stringToDate(formatter: DateFormatters.MMDDYYYYHMMSSA)?.stringFromDate(format: DateFormatters.EEEEMMMDDYYYY) {
                self.labelBillDate.text = stringdate
            }
            else {
                self.labelBillDate.text = "Expiry Date"
            }
        }
        else {
            self.txtfldAmount.placeholder = "Amount (\(self.giftCouponModel.readCurrencySymbol()))"
        }
        self.setGiftCategoryName(self.giftCouponModel.readCategoryTypeName())
        self.updateTagCollectionViewHeight()
        self.dayDatePicker?.dataSource = self.dayDatePicker
        self.dayDatePicker?.delegate = self.dayDatePicker
        self.dayDatePicker?.dayDatePickerDelegate = self
        self.dayDatePicker?.setUpData()
        self.datePicker.setValue(UIColor.white, forKeyPath: "textColor")
        self.dayDatePicker?.setValue(UIColor.white, forKeyPath: "textColor")
    }
    
    func updateDatePickerValueChanges(_ date: Date) {
        self.giftCouponModel.setExpiryDate(date: date)
        self.labelBillDate.text = date.stringFromDate(format: DateFormatters.EEEEMMMDDYYYY)
    }
    
    func setGiftCategoryName(_ name: String) {
        self.buttonGiftType.setTitle(name, for: .normal)
    }
    
    func updateTagCollectionViewHeight(){
        self.view.layoutIfNeeded()
    }
    
    func showTagsCount() {
        self.labelTagCount.text = "\(self.giftCouponModel.tags.count)"
        self.labelTagCount.isHidden = self.giftCouponModel.tags.isEmpty
    }
    
    func showAttachmentsCount() {
        self.labelAttachmentCount.text = "\(self.giftCouponModel.attachments.count)"
        self.labelAttachmentCount.isHidden = self.giftCouponModel.attachments.isEmpty
    }
    
    func startUploadAttachment() {
        self.buttonSaveGiftCoupon.startAnimation()
        self.startPendingUploadOfAttachment()
    }
    
    func startPendingUploadOfAttachment() {
        if let pendingAttachMent = self.giftCouponModel.attachments.filter({ return $0.identifier.isEmpty }).first {
            self.createWebServiceToUploadAttachment(pendingAttachMent)
        }
        else {
            self.createServiceToAddGiftCoupon()
        }
    }
}

