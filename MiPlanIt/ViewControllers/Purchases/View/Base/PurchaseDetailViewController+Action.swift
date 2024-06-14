//
//  PurchaseDetailViewController+Action.swift
//  MiPlanIt
//
//  Created by Arun on 08/05/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation
import MapKit

extension PurchaseDetailViewController {
    
    func initialiseUIComponents() {
        let attachments = self.planitPurchase.readAllAttachments()
        self.labelAttachmentCount.text = "\(attachments.count)"
        self.labelAttachmentCount.isHidden = attachments.isEmpty
        self.labelProductName.text = self.planitPurchase.readProductName()
        self.labelAmount.text = "\(self.planitPurchase.readCurrencySymbol())\(self.planitPurchase.readAmount())"
        self.labelStoreName.text = self.planitPurchase.readStoreNameWithDefault()
        self.labelDescription.text = self.planitPurchase.readDescription()
        self.labelBillDate.text = self.planitPurchase.readBillDate()
        if self.planitPurchase.readPaymentType() == "1" {
            self.labelCardName.text = self.planitPurchase.readCardName()
            self.labelCardNumber.text = self.planitPurchase.readCardNumber()
        }
        else if  self.planitPurchase.readPaymentType() == "2"{
            self.labelCardName.text = Strings.cash
            self.labelCardNumber.text = Strings.empty
        }
        else {
            self.labelCardName.text = Strings.other
            self.labelCardNumber.text = self.planitPurchase.readPaymentDescription()
        }
        
        self.showTagsCount()
        self.setLocation()
        self.labelPurchaseCategoryType?.text = self.planitPurchase.purchaseCategoryType == 1 ? Strings.bills : Strings.receipts
    }
    
    func setLocation() {
        self.labelLocation.text = self.planitPurchase.readLocationName()
        let locatinData = self.planitPurchase.readLocation().split(separator: Strings.locationSeperator)
        self.buttonLocation?.isUserInteractionEnabled = locatinData.count > 2
        if locatinData.count > 2 {
            if #available(iOS 13.0, *) {
                self.labelLocation?.textColor = Color.link
            } else {
                self.labelLocation?.textColor = Color(red: 0, green: 0, blue: 238/255, alpha: 1.0)
            }
        }
    }
    
    func setLocationValue() {
        let locatinData = self.planitPurchase.readLocation().split(separator: Strings.locationSeperator)
        if let locationName = locatinData.first {
            self.labelLocation.text = String(locationName)
            self.buttonLocation.isUserInteractionEnabled = locatinData.count > 2
            if locatinData.count > 2 {
                if #available(iOS 13.0, *) {
                    self.labelLocation.textColor = Color.link
                } else {
                    self.labelLocation.textColor = Color(red: 0, green: 0, blue: 238/255, alpha: 1.0)
                }
            }
        }
    }
    
    func openMapForPlace() {
        let locatinData = self.planitPurchase.readLocation().split(separator: Strings.locationSeperator)
        guard locatinData.count > 2, let locationName = locatinData.first, let latitude = Double(locatinData[1]), let longitude = Double(locatinData[2]) else {
            return
        }
        let regionDistance:CLLocationDistance = 10000
        let coordinates = CLLocationCoordinate2DMake(latitude, longitude)
        let regionSpan = MKCoordinateRegion(center: coordinates, latitudinalMeters: regionDistance, longitudinalMeters: regionDistance)
        let options = [
            MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
            MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)
        ]
        let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = String(locationName)
        mapItem.openInMaps(launchOptions: options)
    }
    
    func showTagsCount() {
        let tag = self.planitPurchase.readAllTags()
        self.labelTagCount.text = "\(tag.count)"
        self.labelTagCount.isHidden = tag.isEmpty
    }
    
    func deletePurchase() {
        self.showAlertWithAction(message: Message.deletePurchaseConfirmation, title: Message.confirm, items: [Message.yes, Message.no], callback: { index in
            if index == 0 {
                self.deletePurchaseToServerUsingNetwotk()
            }
        })
    }
}
