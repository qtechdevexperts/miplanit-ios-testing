//
//  CreateEventsViewController+EventTagDelegate.swift
//  MiPlanIt
//
//  Created by Febin Paul on 09/04/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

extension AddPurchaseViewController: PurchaseTagCollectionViewCellDelegate {
    
    func purchaseTagCollectionViewCell(_ cell: PurchaseTagCollectionViewCell, removeItemAtIndexPath indexPath: IndexPath) {
        self.purchaseModel.removeTagAtIndex(indexPath.row)
    }
}

extension AddPurchaseViewController: PurchaseAddTagCollectionViewCellDelegate {

    func purchaseAddTagCollectionViewCell(_ cell: PurchaseAddTagCollectionViewCell, checkExisting tag: String) -> Bool {
        return self.purchaseModel.tags.contains(where: {$0.caseInsensitiveCompare(tag) == .orderedSame})
    }

    func purchaseAddTagCollectionViewCell(_ cell: PurchaseAddTagCollectionViewCell, addedNewTag tag: String) {
        self.purchaseModel.addTag(tag)
    }
}

extension AddPurchaseViewController: PaymentTypeViewControllerDelegate {
    
    func paymentTypeViewController(_ viewController: PaymentTypeViewController, selectedPayement payment: Int, with details: PurchaseCard?) {
        self.purchaseModel.savePayment(payment, card: details)
        self.buttonPaymentType.setTitle(self.purchaseModel.readPaymentCaption(), for: .normal)
    }
    
    func paymentTypeViewController(_ viewController: PaymentTypeViewController, selectedPayement payment: Int, with details: String) {
        self.purchaseModel.savePaymentOther(payment, description: details)
        self.buttonPaymentType.setTitle(self.purchaseModel.readPaymentCaption(), for: .normal)
    }
    
}

extension AddPurchaseViewController: AttachmentListViewControllerDelegate {
    
    func attachmentListViewController(_ viewController: AttachmentListViewController, updated items: [UserAttachment]) {
        self.purchaseModel.attachments = items
        self.showAttachmentsCount()
    }
}

extension AddPurchaseViewController: AddPurchaseTagViewControllerDelegate {
    
    func addPurchaseTagViewController(_ viewController: AddPurchaseTagViewController, updated tags: [String]) {
        self.purchaseModel.tags = tags
        self.showTagsCount()
    }
}

extension AddPurchaseViewController: GoogleMapViewControllerDelegate {
    
    func googleMapViewController(_ googleMapViewController: GoogleMapViewController, selectedLocation: String) {
        self.textFieldLocation.text = self.purchaseModel.setLocation(selectedLocation)
    }
}


extension AddPurchaseViewController: CommonMapViewControllerDelegate {
    
    func commonMapViewController(_ commonMapViewController: CommonMapViewController, selectedLocation: String, latitude: Double?, longitude: Double?) {
        self.textFieldLocation.text = self.purchaseModel.setLocationFromMap(locationName: selectedLocation, latitude: latitude, longitude: longitude)
    }
}

extension AddPurchaseViewController: PurchaseTypeDropDownViewControllerDelegate {
    
    func purchaseTypeDropDownViewController(_ controller: PurchaseTypeDropDownViewController, selectedOption: DropDownItem) {
        self.setPurchaseTypeName(selectedOption.title)
        switch selectedOption.dropDownType {
        case .eReceipt:
            self.purchaseModel.setPurchaseDataType(.receipt)
        case .eBill:
            self.purchaseModel.setPurchaseDataType(.bill)
        default:
            break
        }
    }
}
extension AddPurchaseViewController: CurrencyCodeViewControllerDelegate {
    
    func currencyCodeViewController(_ controller: CurrencyCodeViewController, selectedOption: String) {
        self.purchaseModel.currencySymbol = selectedOption.getLocalCurrencySymbol()
        self.buttonCurrencySymbol.setTitle(self.purchaseModel.currencySymbol, for: .normal)
        self.txtfldPrice.placeholder = "Amount (\(self.purchaseModel.currencySymbol))"
    }
}
