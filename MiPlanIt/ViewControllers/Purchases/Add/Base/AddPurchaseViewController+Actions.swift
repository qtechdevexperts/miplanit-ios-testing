//
//  AddPurchaseViewController+Actions.swift
//  MiPlanIt
//
//  Created by Aneesh Asokan on 30/04/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

extension AddPurchaseViewController {
    
    func initialiseUIComponents() {
        self.lottieAnimationView.backgroundBehavior = .pauseAndRestore
        self.buttonPaymentType.setTitle(self.purchaseModel.readPaymentCaption(), for: .normal)
        self.showAttachmentsCount()
        self.showTagsCount()
        if !self.purchaseModel.purchaseId.isEmpty {
            self.labelHeaderCaption.text = Strings.editPurchase
            self.txtfldProductName.text = self.purchaseModel.productName
            self.txtfldStoreName.text = self.purchaseModel.storeName
            self.txtfldPrice.text = self.purchaseModel.amount
            self.txtfldPrice.placeholder = "Amount (\(self.purchaseModel.currencySymbol))"
            self.buttonCurrencySymbol.setTitle(self.purchaseModel.currencySymbol, for: .normal)
            self.textFieldLocation.text = self.purchaseModel.location
            self.textViewDescription.text = self.purchaseModel.purchaseDescription
            self.labelBillDate.text = self.purchaseModel.billDate?.stringFromDate(format: DateFormatters.EEEEMMMDDYYYY) ?? Strings.billDate
            self.buttonPaymentType.setTitle(self.purchaseModel.readPaymentCaption(), for: .normal)
        }
        else {
            self.txtfldPrice.placeholder = "Amount (\(self.purchaseModel.readCurrencySymbol()))"
        }
        self.setPurchaseTypeName(self.purchaseModel.readPurchaseTypeName())
        self.dayDatePicker?.dataSource = self.dayDatePicker
        self.dayDatePicker?.delegate = self.dayDatePicker
        self.dayDatePicker?.dayDatePickerDelegate = self
        self.dayDatePicker?.setUpData()
        self.datePicker.setValue(UIColor.white, forKeyPath: "textColor")
        self.dayDatePicker?.setValue(UIColor.white, forKeyPath: "textColor")
    }
    
    func updateDateChanged(_ date: Date) {
        self.purchaseModel.setBiilDate(date: date)
        self.labelBillDate.text = date.stringFromDate(format: DateFormatters.EEEEMMMDDYYYY)
        self.disableBillError()
    }
    
    func setPurchaseTypeName(_ name: String) {
        self.buttonPurchaseType.setTitle(name, for: .normal)
    }
    
    func showTagsCount() {
        self.labelTagCount.text = "\(self.purchaseModel.tags.count)"
        self.labelTagCount.isHidden = self.purchaseModel.tags.isEmpty
    }
    
    func showAttachmentsCount() {
        self.labelAttachmentCount.text = "\(self.purchaseModel.attachments.count)"
        self.labelAttachmentCount.isHidden = self.purchaseModel.attachments.isEmpty
    }
    
    func startUploadAttachment() {
        self.buttonSavePurchase.startAnimation()
        self.startPendingUploadOfAttachment()
    }
    
    func startPendingUploadOfAttachment() {
        if let pendingAttachMent = self.purchaseModel.attachments.filter({ return $0.identifier.isEmpty }).first {
            self.createWebServiceToUploadAttachment(pendingAttachMent)
        }
        else {
            self.createServiceToAddPurchase()
        }
    }
    
    func disableBillError() {
        self.viewBillBorder.backgroundColor = UIColor.init(red: 233/255.0, green: 233/255.0, blue: 233/255.0, alpha: 1)
        self.labelBillDateError.isHidden = true
    }
}

