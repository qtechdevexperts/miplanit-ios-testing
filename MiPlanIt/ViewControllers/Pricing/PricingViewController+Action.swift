//
//  PricingViewController+Action.swift
//  MiPlanIt
//
//  Created by Febin Paul on 09/02/21.
//  Copyright © 2021 Arun. All rights reserved.
//

import Foundation
import StoreKit

extension PricingViewController {
    
    func setView(){
        buttonRestore.isHidden = !isAlreadySubscribed
    }
    
    func intiatePricingProducts() {
        self.showPricingLoader()
        Session.shared.readUser()?.savePurchase(nil)
        InAppPurchase.shared.itunesPricingModel { product, resultPrice, resultCode, error in
            DispatchQueue.main.async {
                guard error == nil, product != nil else { self.stopPricingLoader(); return }
                self.activeProduct = product
                self.priceFormat = resultCode
                self.stopPricingLoader()
                if !self.isAlreadySubscribed  {
                    if #available(iOS 11.2, *) {
                        if let intoOffer = product?.introductoryPrice, intoOffer.paymentMode == .freeTrial {
                            self.labelBuyBottomName.text = "\(resultCode ?? Strings.empty) " + (resultPrice ?? Strings.empty) + " / \(self.getSubscriptionPeriodUnit(product))"
                            return
                        }
                    }
                }
                self.labelBuyBottomName.text = (resultCode ?? Strings.empty) + " " + (resultPrice ?? Strings.empty) + " / \(self.getSubscriptionPeriodUnit(product))"
            }
        }
        self.setUpMonthlySubscription()
        }
    
    func setUpMonthlySubscription(){
        self.showPricingLoader2()
        InAppPurchase2.shared.itunesPricingModelMonthly { product, resultPrice, resultCode, error in
            DispatchQueue.main.async {
                guard error == nil, product != nil else { self.stopPricingLoader2(); return }
                self.activeProduct2 = product
                self.priceFormat2 = resultCode
                self.stopPricingLoader2()
                if !self.isAlreadySubscribed2  {
                    if #available(iOS 11.2, *) {
                        if let intoOffer = product?.introductoryPrice, intoOffer.paymentMode == .freeTrial {
                            self.labelBuyBottomName2.text = "\(resultCode ?? Strings.empty) " + (resultPrice ?? Strings.empty) + " / \(self.getSubscriptionPeriodUnit(product))"
                            return
                        }
                    }
                }
                self.labelBuyBottomName2.text = (resultCode ?? Strings.empty) + " " + (resultPrice ?? Strings.empty) + " / \(self.getSubscriptionPeriodUnit(product))"
            }
        }
    }
    
    func getSubscriptionPeriodUnit(_ unit: SKProduct?) -> String {
        if #available(iOS 11.2, *) {
            switch unit?.subscriptionPeriod?.unit {
            case .some(SKProduct.PeriodUnit.year):
                return "Year"
            case .some(SKProduct.PeriodUnit.day):
                return "Day"
            case .some(SKProduct.PeriodUnit.week):
                return "Week"
            case .some(SKProduct.PeriodUnit.month):
                return "Month"
            default:
                return "Year"
            }
        }
        return "Year"
    }
    
    func initiateView() {
        if let view = viewGradientLayer {
            viewGradientLayer1.createGradientLayer(colours: [#colorLiteral(red: 53/255.0, green: 173/255.0, blue: 195/255.0, alpha: 1.0), #colorLiteral(red: 137/255.0, green: 213/255.0, blue: 227/255.0, alpha: 1.0), #colorLiteral(red: 240/255.0, green: 182/255.0, blue: 111/255.0, alpha: 1.0)], locations: [0,0.4,1.0], startPOint: CGPoint(x: 0.2, y: 0.0), endPoint: CGPoint(x: 0.8, y: 1.0))
        }
//        viewButtonGradientLayer.createGradientLayer(colours: [#colorLiteral(red: 255/255.0, green: 100/255.0, blue: 39/255.0, alpha: 1.0), #colorLiteral(red: 255/255.0, green: 220/255.0, blue: 132/255.0, alpha: 1.0)], locations: [0,1.0], startPOint: CGPoint(x: 0.0, y: 0.5), endPoint: CGPoint(x: 1.0, y: 0.5))
    }
    
    func autoRenewSubscription() {
        InAppPurchase.shared.doSuddenAutoRenewSubscription { (response, date, transactionIdExist, error) in
            DispatchQueue.main.async {
                if transactionIdExist ?? false {
                    self.switchTransactionToUser(onPurchase: true)
                }
                else if let status = response, status {
                    Session.shared.readUser()?.savePurchase(date)
                    self.delegate?.pricingViewController(self, purchaseStatus: true)
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
    
    func unitName(unitRawValue:UInt, numberOfPeriods: Int) -> String {
        switch unitRawValue {
        case 0: return numberOfPeriods > 1 ? "Days" : "Day"
        case 1: return numberOfPeriods > 1 ? "Weeks" : "Week"
        case 2: return numberOfPeriods > 1 ? "Months" : "Month"
        case 3: return numberOfPeriods > 1 ? "Years" : "Year"
        default: return ""
        }
    }
    
    func switchTransactionToUser(onPurchase: Bool) {
        self.view.isUserInteractionEnabled = true
        UIApplication.shared.endIgnoringInteractionEvents()
        self.showAlertWithAction(message: Message.switchTransactionPermission, title: Message.transactionPermission, items: [Message.cancel, Message.yes], callback: { index in
            if index == 0 {
                let animateButton = onPurchase ? self.buttonPurchase : self.buttonRestore
                animateButton?.stopAnimation(animationStyle: .shake, revertAfterDelay: 0) {
                    if onPurchase {
                        self.viewPriceContainer.isHidden = false
                    }
                }
            }
            else {
                InAppPurchase.shared.switchTransactionReceipt { (purchaseStatus, date, isTransactionExist, error) in
                    if let status = purchaseStatus, status {
                        self.donePurchaseUpdateButton(onPurchase ? self.buttonPurchase : self.buttonRestore, expiryDate: date)
                    }
                    else {
                        self.cancelPurchaseUpdateButton(with: error, button: onPurchase ? self.buttonPurchase : self.buttonRestore)
                    }
                }
            }
        })
    }
    func switchTransactionToUser2(onPurchase: Bool) {
        self.view.isUserInteractionEnabled = true
        UIApplication.shared.endIgnoringInteractionEvents()
        self.showAlertWithAction(message: Message.switchTransactionPermission, title: Message.transactionPermission, items: [Message.cancel, Message.yes], callback: { index in
            if index == 0 {
                let animateButton = onPurchase ? self.buttonPurchase2 : self.buttonRestore
                animateButton?.stopAnimation(animationStyle: .shake, revertAfterDelay: 0) {
                    if onPurchase {
                        self.viewPriceContainer.isHidden = false
                    }
                }
            }
            else {
                InAppPurchase2.shared.switchTransactionReceipt { (purchaseStatus, date, isTransactionExist, error) in
                    if let status = purchaseStatus, status {
                        self.donePurchaseUpdateButton2(onPurchase ? self.buttonPurchase2 : self.buttonRestore, expiryDate: date)
                    }
                    else {
                        self.cancelPurchaseUpdateButton2(with: error, button: onPurchase ? self.buttonPurchase2 : self.buttonRestore)
                    }
                }
            }
        })
    }
    
    func donePurchaseUpdateButton(_ button: ProcessingButton, expiryDate: Date?) {
        if button == self.buttonRestore {
            button.clearButtonTitleForAnimation()
        }
        button.stopAnimation(animationStyle: .normal, revertAfterDelay: 0) {
            button.showTickAnimation { (results) in
                Session.shared.readUser()?.savePurchase(expiryDate)
                self.delegate?.pricingViewController(self, purchaseStatus: true)
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: Notifications.updateAdSenceView), object: nil)
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    func donePurchaseUpdateButton2(_ button: ProcessingButton, expiryDate: Date?) {
        if button == self.buttonRestore {
            button.clearButtonTitleForAnimation()
        }
        button.stopAnimation(animationStyle: .normal, revertAfterDelay: 0) {
            button.showTickAnimation { (results) in
                Session.shared.readUser()?.savePurchase(expiryDate)
                self.delegate?.pricingViewController(self, purchaseStatus: true)
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: Notifications.updateAdSenceView), object: nil)
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    func cancelPurchaseUpdateButton(with error: String?, button: ProcessingButton) {
        button.stopAnimation(animationStyle: .shake, revertAfterDelay: 0) {
            if button == self.buttonPurchase {
                self.viewPriceContainer.isHidden = false
            }
            self.performSegue(withIdentifier: Segues.toMessageScreen, sender: [Message.error, error])
        }
    }
    func cancelPurchaseUpdateButton2(with error: String?, button: ProcessingButton) {
        button.stopAnimation(animationStyle: .shake, revertAfterDelay: 0) {
            if button == self.buttonPurchase2 {
                self.viewPriceContainer2.isHidden = false
            }
            self.performSegue(withIdentifier: Segues.toMessageScreen, sender: [Message.error, error])
        }
    }
    
    func showPricingLoader() {
        self.buttonPurchase.startAnimation()
        self.viewPriceContainer.isHidden = true
    }
    func showPricingLoader2() {
        self.buttonPurchase2.startAnimation()
        self.viewPriceContainer2.isHidden = true
    }
    func stopPricingLoader() {
        self.buttonPurchase.stopAnimation()
        self.viewPriceContainer.isHidden = false
    }
    func stopPricingLoader2() {
        self.buttonPurchase2.stopAnimation()
        self.viewPriceContainer2.isHidden = false
    }
    func openURL(_ url: URL?) {
        guard let bURL = url, UIApplication.shared.canOpenURL(bURL) else { return }
        UIApplication.shared.open(bURL, options: [:], completionHandler: nil)
    }
    
}
